import SwiftUI

struct ContentView: View {
    // State for the image captured from the camera
    @State private var capturedImage: UIImage?
    @State private var isShowingEditView = false

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            CameraView(image: $capturedImage) { capturedImage in
                            self.capturedImage = capturedImage
                            self.isShowingEditView = true
                        }
                        .tabItem {
                            Image(systemName: "camera.viewfinder")
                            Text("Camera")
                        }
                        .sheet(isPresented: $isShowingEditView) {
                            // Present your Image Edit View here
                            ImageEditViewWrapper(image: $capturedImage)
                        }

            SavedDesignsView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Saved")
                }
        }
    }
}
struct ImageEditViewWrapper: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> ImageEditViewController {
        let imageEditViewController = ImageEditViewController()
        // Assign the image from the binding to the view controller's property
        imageEditViewController.originalImage = self.image
        return imageEditViewController
    }

    func updateUIViewController(_ uiViewController: ImageEditViewController, context: Context) {
        // If the bound image changes, update the view controller's property
        uiViewController.originalImage = self.image
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
