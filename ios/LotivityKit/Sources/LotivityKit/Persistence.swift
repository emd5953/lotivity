import Foundation

/// On-device storage. A JSON file per key rather than `UserDefaults` because
/// voice-memo blobs land here later and would be the wrong shape for defaults.
///
/// Every operation is best-effort: losing persistence is acceptable, crashing
/// the app is not (NFR-8).
public struct PersistenceKey: RawRepresentable, Hashable, Sendable {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    public static let profile = PersistenceKey(rawValue: "profile")
    public static let draft = PersistenceKey(rawValue: "onboarding-draft")
    public static let seenEvents = PersistenceKey(rawValue: "seen-events")
    public static let mapPrefs = PersistenceKey(rawValue: "map-prefs")
}

public struct Store: Sendable {
    public static let shared = Store()

    private let directoryName = "Lotivity"

    private var directory: URL? {
        guard let base = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else { return nil }
        let dir = base.appendingPathComponent(directoryName, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func url(for key: PersistenceKey) -> URL? {
        directory?.appendingPathComponent("\(key.rawValue).json")
    }

    public func load<T: Decodable>(_ type: T.Type, for key: PersistenceKey) -> T? {
        guard let url = url(for: key), let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder.lotivity.decode(type, from: data)
    }

    public func save<T: Encodable>(_ value: T, for key: PersistenceKey) {
        guard let url = url(for: key), let data = try? JSONEncoder.lotivity.encode(value) else { return }
        try? data.write(to: url, options: .atomic)
    }

    public func remove(_ key: PersistenceKey) {
        guard let url = url(for: key) else { return }
        try? FileManager.default.removeItem(at: url)
    }

    /// Backs the "Reset demo" control (FR-APP-5).
    public func clearAll() {
        guard let directory else { return }
        try? FileManager.default.removeItem(at: directory)
    }
}

extension JSONEncoder {
    static let lotivity: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        // Key order is otherwise unspecified, which makes two encodings of the
        // same value differ byte for byte and stored files churn needlessly.
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()
}

extension JSONDecoder {
    static let lotivity: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
