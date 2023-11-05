//
//  HomeView.swift
//  Interior_Shuffle_App
//
//  Created by Asfandyar Khan on 11/4/23.
//

import SwiftUI


    
 

struct HomeView: View {
    @State private var roomImages: [RoomImage] = (1...7).map { RoomImage(id: $0, imageName: "room\($0)", isSaved: false) }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(roomImages) { roomImage in
                        Image(roomImage.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(10)
                            .onTapGesture {
                                // Handle the tap to save or interact with the image
                                saveImage(roomImage)
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Select a Room")
        }
    }
    
    private func saveImage(_ roomImage: RoomImage) {
        if let index = roomImages.firstIndex(where: { $0.id == roomImage.id }) {
            roomImages[index].isSaved.toggle()
            // Implement the logic to actually save the image or mark it as saved
        }
    }
}

// Assuming RoomImage is something like this
struct RoomImage: Identifiable {
    let id: Int
    var imageName: String
    var isSaved: Bool
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


