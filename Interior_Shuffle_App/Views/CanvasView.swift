import SwiftUI
import UIKit

// A UIViewRepresentable is used to wrap a UIKit view that will handle the drawing.
struct CanvasView: UIViewRepresentable {
    class Coordinator: NSObject {
        var canvas: Canvas?
        
        func setCanvas(_ newCanvas: Canvas) {
            self.canvas = newCanvas
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> Canvas {
        let canvas = Canvas()
        context.coordinator.setCanvas(canvas)
        return canvas
    }
    
    func updateUIView(_ uiView: Canvas, context: Context) {}
}

class Canvas: UIImageView {
    private var lastPoint: CGPoint = .zero // Keep track of the last point touched
    private var brushWidth: CGFloat = 25 // Set the brush width
    private var opacity: CGFloat = 1.0 // Set the opacity
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true // Allow user interaction
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            lastPoint = touch.location(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            erase(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    func erase(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        image?.draw(in: bounds)
        
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        
        context.setLineCap(.round)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(UIColor.clear.cgColor) // Set the stroke color to clear
        context.setBlendMode(.clear) // Use blend mode clear to erase
        
        context.strokePath()
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}

