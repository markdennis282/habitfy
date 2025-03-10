

import SwiftUI
import MapKit
import CoreLocation

struct AnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct LocationPickerView: View {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    //intiial map
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.3444, longitude: -6.2577),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    //display map where user can swipe and select location
    var body: some View {
        VStack {
            Map(
                coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: false,
                annotationItems: annotationItems()
            ) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Label("Pin", systemImage: "mappin.circle.fill")
                        .foregroundColor(.red)
                }
            }

            .onTapGesture {
                DispatchQueue.main.async {
                    selectedCoordinate = region.center
                }
            }
            .ignoresSafeArea()
            
            if let coord = selectedCoordinate {
                Text("Selected: \(String(format: "%.4f", coord.latitude)), \(String(format: "%.4f", coord.longitude))")
                    .padding()
            } else {
                Text("Tap the map to select a location")
                    .padding()
            }
        }
        .navigationTitle("Select Location")
    }
    
    private func annotationItems() -> [AnnotationItem] {
        if let coordinate = selectedCoordinate {
            return [AnnotationItem(coordinate: coordinate)]
        }
        return []
    }
}
