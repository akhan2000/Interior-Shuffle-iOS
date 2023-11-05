import UIKit

protocol ImageEditViewControllerDelegate: AnyObject {
    func didRequestRetake()
}

class ImageEditViewController: UIViewController, EraserViewDelegate {
    
    var eraserView: EraserView!
    var originalImage: UIImage? {
        didSet {
            // Save the original image to the user's photo library when it is set
            if let originalImage = originalImage {
                UIImageWriteToSavedPhotosAlbum(originalImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    weak var delegate: ImageEditViewControllerDelegate?
    var isEditingMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let eraserViewFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 100)
        eraserView = EraserView(frame: eraserViewFrame)
        eraserView.delegate = self
        view.addSubview(eraserView)
        
        if let originalImage = originalImage {
            eraserView.currentImage = originalImage
        }
    }
    
    func didTapProcess() {
        if let processedImage = self.eraserView.currentImage {
            self.saveImage(image: processedImage)
        }
    }
    
    func didTapSubmit() {
        if let processedImage = self.eraserView.currentImage {
            // Save the processed image to the user's photo library
            UIImageWriteToSavedPhotosAlbum(processedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle error
            print("Error Saving Image: \(error)")
        } else {
            print("Image Saved Successfully")
        }
    }
    
    @objc func uploadButtonTapped() {
        if let original = originalImage, let processed = eraserView.currentImage {
            sendImageToServer(image: original, imageState: "original")
            sendImageToServer(image: processed, imageState: "processed")
        }
    }
    func saveImage(image: UIImage) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = UUID().uuidString
        let fileURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("png")
        if let data = image.pngData() {
            do {
                try data.write(to: fileURL)
                print("Image saved to \(fileURL)")
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }
    
    func sendImageToServer(image: UIImage, imageState: String) {
        // Convert image to Data
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        
        
        let url = URL(string: "http://192.168.1.2:5001/process-images")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Construct the multipart/form-data request
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(imageState)\"; filename=\"\(imageState).jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
            } else if let httpResponse = response as? HTTPURLResponse {
                print("Upload response status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                        print("Server Response: \(responseString)")
                    }
                } else {
                    // Handle server-side error
                    print("Server error occurred")
                }
            }
        }
        task.resume()

        
        

        
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
        
        func resetToCamera() {
            delegate?.didRequestRetake()
        }
    }
}
