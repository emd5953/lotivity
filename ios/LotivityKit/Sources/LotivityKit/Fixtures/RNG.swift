import Foundation

/// Deterministic PRNG (mulberry32). Fixtures must be identical on every machine
/// so tests are stable and the demo looks the same everywhere.
///
/// The arithmetic mirrors the JavaScript original bit for bit — `Math.imul` and
/// `>>> 0` map onto `UInt32` wrapping operators — so the Swift world is the same
/// world the web app generates from the same seed.
public final class RNG {
    private var a: UInt32

    public init(seed: UInt32) {
        self.a = seed
    }

    public func next() -> Double {
        a = a &+ 0x6d2b_79f5
        var t = a
        t = (t ^ (t >> 15)) &* (t | 1)
        t ^= t &+ ((t ^ (t >> 7)) &* (t | 61))
        return Double(t ^ (t >> 14)) / 4_294_967_296
    }

    public func int(_ minInclusive: Int, _ maxInclusive: Int) -> Int {
        minInclusive + Int(floor(next() * Double(maxInclusive - minInclusive + 1)))
    }

    public func pick<T>(_ items: [T]) -> T {
        precondition(!items.isEmpty, "pick() called with an empty list")
        return items[int(0, items.count - 1)]
    }

    /// n distinct items, or all of them if n exceeds the list length.
    public func sample<T>(_ items: [T], _ n: Int) -> [T] {
        var pool = items
        var out: [T] = []
        let count = min(n, pool.count)
        for _ in 0..<count {
            out.append(pool.remove(at: int(0, pool.count - 1)))
        }
        return out
    }

    public func chance(_ probability: Double) -> Bool {
        next() < probability
    }

    /// Float in [min, max).
    public func float(_ min: Double, _ max: Double) -> Double {
        min + next() * (max - min)
    }
}
