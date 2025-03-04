//
//  LocationPickerView.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 20/01/2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct AnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct LocationPickerView: View {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.3444, longitude: -6.2577),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    
    var body: some View {
        VStack {
            // Map with the older initializer (compatible with watchOS or older iOS versions)
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
                // Update selectedCoordinate to the map's current center
                selectedCoordinate = region.center
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
