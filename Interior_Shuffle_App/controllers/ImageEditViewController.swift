import UIKit

class ImageEditViewController: UIViewController {

    var imageView: UIImageView!
    var originalImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        

        imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        view.addSubview(imageView)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.addGestureRecognizer(tapGestureRecognizer)

        // Ensure the original image is loaded before assigning it to imageView
        if let originalImage = originalImage {
            imageView.image = originalImage
        }
    }


    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedPoint = tapGestureRecognizer.location(in: imageView)
        erasePixel(at: tappedPoint)
    }

    func erasePixel(at point: CGPoint) {
        guard let cgImage = originalImage?.cgImage else { return }
        let scale = UIScreen.main.scale
        let x = Int(point.x * scale)
        let y = Int(point.y * scale)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(data: nil, width: cgImage.width, height: cgImage.height, bitsPerComponent: 8, bytesPerRow: cgImage.width * 4, space: colorSpace, bitmapInfo: bitmapInfo) else { return }
        
        context.translateBy(x: 0, y: CGFloat(cgImage.height))
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))

        let rect = CGRect(x: x, y: y, width: 10, height: 10) // Adjust size as needed
        context.clear(rect)
        
        guard let newCgImage = context.makeImage() else { return }
        let newImage = UIImage(cgImage: newCgImage)
        imageView.image = newImage
        originalImage = newImage
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
                self.imageView.image = UIImage(data: data)
            }
        }
        task.resume()
    }
}
