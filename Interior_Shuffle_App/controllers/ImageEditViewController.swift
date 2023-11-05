import UIKit

// Define the delegate protocol
protocol ImageEditViewControllerDelegate: AnyObject {
    func didRequestRetake()
}

class ImageEditViewController: UIViewController {

    var eraserView: EraserView!
    var originalImage: UIImage?
    weak var delegate: ImageEditViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        eraserView = EraserView(frame: self.view.bounds, image: originalImage)
        view.addSubview(eraserView)

        // Ensure the original image is loaded before assigning it to EraserView
        if let originalImage = originalImage {
            eraserView.currentImage = originalImage
        }

        // Add a "Upload" button to the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(uploadButtonTapped))
    }

    @objc func uploadButtonTapped() {
        guard let image = eraserView.currentImage else { return }
        sendImageToServer(image: image)
    }

    func sendImageToServer(image: UIImage) {
        // Convert image to Data
        guard let imageData = image.pngData() else { return }
        
        // Use URLSession to send image data to your server
        let url = URL(string: "Your server endpoint here")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("image/png", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
            // Handle the response from the server here
            if let error = error {
                print("Error sending image: \(error)")
                return
            }
            // Assuming the server returns the path to the modified image
            if let data = data, let imagePath = String(data: data, encoding: .utf8) {
                self.downloadImageFromPath(imagePath)
            }
        }
        task.resume()
    }

    func downloadImageFromPath(_ path: String) {
        guard let url = URL(string: path) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                if let newImage = UIImage(data: data) {
                    self.eraserView.currentImage = newImage
                }
            }
        }
        task.resume()
    }

    // This function can be called to go back to the camera view.
    func resetToCamera() {
        delegate?.didRequestRetake()
    }
}
