import SwiftUI

struct ContentView: View {
    @State private var capturedImage: UIImage?
    @State private var isShowingEditView = false

    var body: some View {
        NavigationView {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                
                VStack {
                    if isShowingEditView {
                        ImageEditViewWrapper(image: $capturedImage, isShowingEditView: $isShowingEditView)
                    } else {
                        CameraView(image: $capturedImage) { capturedImage in
                            self.capturedImage = capturedImage
                            withAnimation {
                                self.isShowingEditView = true
                            }
                        }
                    }
                }
                .tabItem {
                    Image(systemName: "camera.viewfinder")
                    Text("Camera")
                }


                SavedDesignsView()
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Saved")
                    }
            }
        }
    }
}

struct ImageEditViewWrapper: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isShowingEditView: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ImageEditViewControllerDelegate {
        var parent: ImageEditViewWrapper

        init(_ parent: ImageEditViewWrapper) {
            self.parent = parent
        }

        func didRequestRetake() {
            parent.isShowingEditView = false
        }
    }

    func makeUIViewController(context: Context) -> ImageEditViewController {
        let imageEditViewController = ImageEditViewController()
        imageEditViewController.originalImage = self.image
        imageEditViewController.delegate = context.coordinator
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
