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
                                    ImageEditViewWrapper(image: $capturedImage, isShowingEditView: $isShowingEditView)  // Pass the binding here
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
    @Binding var isShowingEditView: Bool  // Bind to the state controlling the sheet presentation

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ImageEditViewControllerDelegate {
        var parent: ImageEditViewWrapper

        init(_ parent: ImageEditViewWrapper) {
            self.parent = parent
        }

        func didRequestRetake() {
            parent.isShowingEditView = false  // This will dismiss the sheet when the user requests a retake
        }
    }

    func makeUIViewController(context: Context) -> ImageEditViewController {
        let imageEditViewController = ImageEditViewController()
        imageEditViewController.originalImage = self.image
        imageEditViewController.delegate = context.coordinator  // Set the delegate
        return imageEditViewController
    }

    func updateUIViewController(_ uiViewController: ImageEditViewController, context: Context) {
        uiViewController.originalImage = self.image
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
