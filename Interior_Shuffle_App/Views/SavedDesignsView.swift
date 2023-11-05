//
//  SavedDesignsView.swift
//  Interior_Shuffle_App
//
//  Created by Asfandyar Khan on 11/4/23.
//

import SwiftUI

struct SavedDesignsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(0..<10) { item in
                        Image("rooms\(item)")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Saved Designs")
        }
    }
}


struct SavedDesignsView_Previews: PreviewProvider {
    static var previews: some View {
        SavedDesignsView()
    }
}
