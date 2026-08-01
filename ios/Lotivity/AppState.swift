import Foundation
import LotivityKit
import SwiftUI

/// The app's single store — the Swift equivalent of the web app's Zustand store.
/// Persisting on every draft change is what lets someone quit mid-onboarding and
/// resume in place (FR-PROF-14).
@Observable
@MainActor
final class AppState {
    private(set) var hydrated = false
    private(set) var profile: User?
    var draft = OnboardingDraft()
    private(set) var location: GeoPoint = defaultCenter
    private(set) var locationLabel = defaultCenterLabel

    private let store = Store.shared

    /// Guests see the real feed, ranked by what's actually close (PRD §9.3).
    var effectiveProfile: User {
        profile ?? guestProfile(location: location)
    }

    var isGuest: Bool { profile == nil }

    func hydrate() {
        guard !hydrated else { return }
        profile = store.load(User.self, for: .profile)
        draft = store.load(OnboardingDraft.self, for: .draft) ?? OnboardingDraft()
        if let profile { location = profile.location }
        hydrated = true
    }

    func updateDraft(_ mutate: (inout OnboardingDraft) -> Void) {
        mutate(&draft)
        store.save(draft, for: .draft)
    }

    @discardableResult
    func completeOnboarding() -> User {
        let user = draft.toUser(location: location)
        profile = user
        store.save(user, for: .profile)
        return user
    }

    func setLocation(_ point: GeoPoint, label: String) {
        location = point
        locationLabel = label
    }

    /// Backs the "Reset demo" control (FR-APP-5).
    func resetDemo() {
        store.clearAll()
        profile = nil
        draft = OnboardingDraft()
        location = defaultCenter
        locationLabel = defaultCenterLabel
    }
}
