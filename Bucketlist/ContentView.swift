//
//  ContentView.swift
//  Bucketlist
//
//  Created by Theós on 15/06/2023.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            mapView
            if viewModel.isUnlocked {
                controlsView
            } else {
                unlockView
            }
        }
        .sheet(item: $viewModel.selectedPlace) { place in
            EditView(location: place) { viewModel.update(location: $0) }
        }
        .alert("Biometric Error", isPresented: $viewModel.isAlertPresented) {
            Button("Ok") { }
        } message: {
            Text(viewModel.biometricError)
        }
    }
    
    @ViewBuilder
    var controlsView: some View {
        Circle()
            .fill(.blue)
            .opacity(0.3)
            .frame(width: 32, height: 32)
        
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    viewModel.addLocation()
                } label: {
                    Image(systemName: "plus")
                        .padding()
                        .background(.black.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding(.trailing)
                }
            }
        }
    }
    
    @ViewBuilder
    var unlockView: some View {
        Color.white
            .opacity(0.90)
            .ignoresSafeArea()
        
        Button("Unlock Places") {
            withAnimation {
                viewModel.authenticate()
            }
        }
        .padding()
        .background(.blue)
        .foregroundColor(.white)
        .clipShape(Capsule())
    }
    
    var mapView: some View {
        Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.isUnlocked ? viewModel.locations : []) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    VStack {
                        Image(systemName: "star.circle")
                            .resizable()
                            .foregroundColor(.red)
                            .frame(width: 44, height: 44)
                            .background(.white)
                            .clipShape(Circle())
                        
                        Text(location.name)
                            .fixedSize()
                    }
                    .onTapGesture {
                        viewModel.selectedPlace = location
                    }
                }
            }
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
