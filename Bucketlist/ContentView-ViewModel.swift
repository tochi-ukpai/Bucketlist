//
//  ContentView-ViewModel.swift
//  Bucketlist
//
//  Created by Theós on 16/06/2023.
//

import Foundation
import LocalAuthentication
import MapKit

extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
        
        @Published private(set) var locations: [Location]
        @Published var selectedPlace: Location?
        @Published var isUnlocked = false
        @Published var biometricError = ""
        @Published var isAlertPresented = false
        
        init() {
            locations = (try? FileManager.default.readContent(of: savePath)) ?? []
        }
        
        func save() {
            try? FileManager.default.writeContents(of: locations, to: savePath)
        }
        
//    MARK: User Intent(s)
            
        func addLocation() {
            let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
            locations.append(newLocation)
            save()
        }
        
        func update(location: Location) {
            guard let selectedPlace else { return }
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
                save()
            }
        }
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places."

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in

                    Task { @MainActor in
                        if success {
                            self.isUnlocked = true
                        } else {
                            self.biometricError = authenticationError?.localizedDescription ?? "Unknown error."
                            self.isAlertPresented = true
                        }
                    }
                    
                }
            } else {
                biometricError = "Please enable biometrics and approve permission."
                isAlertPresented = true
            }
        }
    }
}
