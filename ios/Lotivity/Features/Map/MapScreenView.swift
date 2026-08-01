import LotivityKit
import MapKit
import SwiftUI

/// The categorical palette (DESIGN_SPEC §1.5) — muted so a dense map still reads
/// as Lotivity. Olive is absent on purpose: it means "alive", not "category".
/// No orange, ever.
private func pinColor(_ filter: MapFilter) -> Color {
    switch filter {
    case .events: .moss
    case .clubs: .slate
    case .workshops: .plum
    case .food: .sand
    }
}

private let radiusStops: [Double] = [0.5, 1, 2, 5, 10]

struct MapScreenView: View {
    @Environment(AppState.self) private var state
    @State private var locationProvider = LocationProvider()

    @State private var radiusIndex: Double = 2
    @State private var filters: Set<MapFilter> = Set(MapFilter.allCases)
    @State private var items: [MapItem] = []
    @State private var trail: [MapItem] = []
    @State private var showTrail = false
    @State private var selected: MapItem?
    @State private var camera: MapCameraPosition = .automatic

    private var radiusMi: Double { radiusStops[Int(radiusIndex)] }
    private var visible: [MapItem] { showTrail ? items + trail : items }
    private var geoDenied: Bool { locationProvider.outcome == .unavailable }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            map.padding(.top, 16)
            controls.padding(.top, 16)
        }
        .task {
            locationProvider.request()
            await reload()
        }
        .onChange(of: locationProvider.outcome) { _, outcome in
            if case .fixed(let point) = outcome {
                state.setLocation(point, label: "Your location")
            }
        }
        .task(id: TaskKey(center: state.location, radius: radiusMi, filters: filters)) {
            await reload()
        }
        .sheet(item: $selected) { item in
            detail(item)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("Around you").screenTitleStyle()
                Spacer(minLength: 0)
                Text("\(items.count) within \(radiusLabel) mi")
                    .chipLabelStyle()
            }
            Text(geoDenied ? "Showing \(defaultCenterLabel)" : state.locationLabel)
                .secondaryStyle()
        }
        .padding(.top, 28)
    }

    private var map: some View {
        Map(position: $camera) {
            // The radius the user chose, drawn rather than implied.
            MapCircle(center: state.location.clCoordinate, radius: radiusMi * 1_609.34)
                .foregroundStyle(Color.olive.opacity(0.06))
                .stroke(Color.olive.opacity(0.45), lineWidth: 1)

            ForEach(visible) { item in
                Annotation(item.title, coordinate: item.location.clCoordinate) {
                    Circle()
                        .fill(pinColor(item.filter))
                        // An ink ring, not a white one — pins separate from each
                        // other by a luminance step, like everything else.
                        .stroke(Color.ink, lineWidth: 2)
                        .frame(width: 14, height: 14)
                        .onTapGesture { selected = item }
                        .accessibilityLabel(item.title)
                }
                .annotationTitles(.hidden)
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(Ramp.ringSoft, lineWidth: 1)
        )
        .onChange(of: MapFrame(center: state.location, radius: radiusMi)) { _, frame in
            recenter(frame)
        }
        .onAppear { recenter(MapFrame(center: state.location, radius: radiusMi)) }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 16) {
            BubbleGroup(legend: "Show") {
                ForEach(MapFilter.allCases, id: \.self) { filter in
                    let count = items.filter { $0.filter == filter }.count
                    Bubble(
                        label: count > 0 ? "\(filterLabel(filter)) (\(count))" : filterLabel(filter),
                        isSelected: filters.contains(filter),
                        size: .small
                    ) {
                        if filters.contains(filter) { filters.remove(filter) } else { filters.insert(filter) }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Radius — \(radiusLabel) mi").eyebrowStyle()
                Slider(value: $radiusIndex, in: 0...Double(radiusStops.count - 1), step: 1)
                    .tint(.olive)
                    .accessibilityLabel("Radius in miles")
                    .accessibilityValue("\(radiusLabel) miles")
                HStack {
                    ForEach(radiusStops, id: \.self) { stop in
                        Text(format(stop)).numeralStyle(size: 10.5, color: Ramp.faint)
                        if stop != radiusStops.last { Spacer() }
                    }
                }
            }

            Bubble(
                label: trail.isEmpty
                    ? "Where my network has been"
                    : "Where my network has been (\(trail.count))",
                isSelected: showTrail,
                size: .small
            ) {
                showTrail.toggle()
            }

            if geoDenied {
                SurfaceCard {
                    Text("We couldn't use your location, so you're seeing \(defaultCenterLabel). Everything still works — drag the map to look around.")
                        .secondaryStyle()
                }
            }

            Button("Recenter") {
                state.setLocation(defaultCenter, label: defaultCenterLabel)
            }
            .buttonStyle(GhostButtonStyle())
        }
    }

    private func detail(_ item: MapItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule().fill(Color.cream.opacity(0.20))
                .frame(width: 40, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .padding(.bottom, 20)

            Text(item.kind.rawValue).eyebrowStyle()
            Text(item.title).sectionTitleStyle().padding(.top, 6)
            Text(item.subtitle).secondaryStyle().padding(.top, 4)
            Text(String(format: "%.1f mi away", item.distanceMi))
                .numeralStyle(color: Color.cream.opacity(0.6))
                .padding(.top, 12)

            Spacer(minLength: 0)

            Button("Close") { selected = nil }
                .buttonStyle(GhostButtonStyle())
                .padding(.bottom, 8)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lotSoft)
        .presentationDetents([.height(280)])
        .presentationBackground(Color.lotSoft)
        .preferredColorScheme(.dark)
    }

    // MARK: -

    private var radiusLabel: String { format(radiusMi) }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }

    private func filterLabel(_ filter: MapFilter) -> String {
        switch filter {
        case .events: "Events"
        case .clubs: "Clubs"
        case .workshops: "Workshops"
        case .food: "Food"
        }
    }

    /// Keeps the viewport matched to the radius so the control feels connected.
    private func recenter(_ frame: MapFrame) {
        let (sw, ne) = boundsForRadius(frame.center, radiusMi: frame.radius)
        camera = .region(
            MKCoordinateRegion(
                center: frame.center.clCoordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: (ne.lat - sw.lat) * 1.3,
                    longitudeDelta: (ne.lng - sw.lng) * 1.3
                )
            )
        )
    }

    private func reload() async {
        let nearby = await Repo.mapItems(
            center: state.location,
            radiusMi: radiusMi,
            filters: filters
        )
        let networkTrail = state.profile == nil
            ? []
            : await Repo.networkTrail(userId: "user:1")
        items = nearby
        trail = networkTrail
    }
}

private struct TaskKey: Equatable {
    let center: GeoPoint
    let radius: Double
    let filters: Set<MapFilter>
}

private struct MapFrame: Equatable {
    let center: GeoPoint
    let radius: Double
}

extension GeoPoint {
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
