import UIKit

class EraserView: UIView {
    var currentPath: CGMutablePath?
    var currentImage: UIImage?
    var eraserLineWidth: CGFloat = 25
    var eraserLineCap: CGLineCap = .round
    var panRecognizer: UIPanGestureRecognizer!

    // Initializer to allow setting the image at the time of view creation
    init(frame: CGRect, image: UIImage?) {
        self.currentImage = image
        super.init(frame: frame)
        setupGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestureRecognizers()
    }

    func setupGestureRecognizers() {
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panRecognizer)
    }

    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: self)
        if recognizer.state == .began {
            currentPath = CGMutablePath()
            currentPath?.move(to: point)
        } else if recognizer.state == .changed {
            currentPath?.addLine(to: point)
            erase(at: point)
        } else if recognizer.state == .ended {
            currentPath = nil
        }
    }

    func erase(at point: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        
        currentImage?.draw(in: bounds)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Failed to get graphics context")
            return
        }
        
        context.setBlendMode(.clear)
        context.setLineWidth(eraserLineWidth)
        context.setLineCap(eraserLineCap)
        
        context.beginPath()
        if let currentPath = currentPath {
            context.addPath(currentPath)
        }
        context.strokePath()
        
        currentImage = UIGraphicsGetImageFromCurrentImageContext()
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        currentImage?.draw(in: bounds)
    }
}
