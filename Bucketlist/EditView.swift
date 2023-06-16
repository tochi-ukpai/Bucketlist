//
//  EditView.swift
//  Bucketlist
//
//  Created by Theós on 16/06/2023.
//

import SwiftUI

struct EditView: View {
    
    @Environment(\.dismiss) var dismiss
    var location: Location
    var onSave: (Location) -> Void
    
    @StateObject private var viewModel = ViewModel()

    @State private var name: String
    @State private var description: String

    var body: some View {
       NavigationView {
           Form {
               Section {
                   TextField("Place name", text: $name)
                   TextField("Description", text: $description)
               }
               
               Section("Nearby…") {
                   switch viewModel.loadingState {
                   case .loaded:
                       ForEach(viewModel.pages, id: \.pageid) { page in
                           Text(page.title)
                               .font(.headline)
                           + Text(": ")
                           + Text(page.description)
                               .italic()
                       }
                   case .loading:
                       Text("Loading…")
                   case .failed:
                       Text("Please try again later.")
                   }
               }
           }
           .navigationTitle("Place details")
           .toolbar {
               Button("Save") {
                   save()
               }
           }
           .task {
               await viewModel.fetchPlacesNearby(location: location)
           }
       }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave

        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
    }
    
    func save() {
        var newLocation = location
        newLocation.id = UUID()
        newLocation.name = name
        newLocation.description = description
        onSave(newLocation)
        dismiss()
    }
    
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(location: Location.example) { _ in }
    }
}
