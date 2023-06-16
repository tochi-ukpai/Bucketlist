//
//  EditView-ViewModel.swift
//  Bucketlist
//
//  Created by Theós on 16/06/2023.
//

import Foundation

extension EditView {
    enum LoadingState {
        case loading, loaded, failed
    }
    
    class ViewModel: ObservableObject {
        @Published private(set) var loadingState = LoadingState.loading
        @Published private(set) var pages = [Page]()
        
        func fetchPlacesNearby(location: Location) async {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"

            guard let url = URL(string: urlString) else {
                print("Bad URL: \(urlString)")
                return
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let items = try JSONDecoder().decode(Result.self, from: data)
                pages = items.query.pages.values.sorted()
                loadingState = .loaded
            } catch {
                loadingState = .failed
            }
        }
    }
}
