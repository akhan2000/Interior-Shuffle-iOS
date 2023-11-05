// EraserView.swift
import UIKit

enum Shape {
    case circle(radius: CGFloat)
    case rectangle(width: CGFloat, height: CGFloat)
}

class EraserShapeLayer: CAShapeLayer {
    var shape: Shape
    init(shape: Shape) {
        self.shape = shape
        super.init()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EraserView: UIView {
    var currentImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    private var shapeLayers: [EraserShapeLayer] = []

    init(frame: CGRect, image: UIImage?) {
        self.currentImage = image
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func addShape(_ shape: Shape, at location: CGPoint) {
        let shapeLayer = EraserShapeLayer(shape: shape)
        shapeLayer.position = location
        switch shape {
        case .circle(let radius):
            shapeLayer.path = UIBezierPath(ovalIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2)).cgPath
        case .rectangle(let width, let height):
            shapeLayer.path = UIBezierPath(rect: CGRect(x: -width/2, y: -height/2, width: width, height: height)).cgPath
        }
        shapeLayers.append(shapeLayer)
        layer.addSublayer(shapeLayer)
    }

    func processErasure(completion: @escaping () -> Void) {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        currentImage?.draw(in: bounds)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setBlendMode(.clear)
        for shapeLayer in shapeLayers {
            context.addPath(shapeLayer.path!)
            context.drawPath(using: .fill)
        }
        currentImage = UIGraphicsGetImageFromCurrentImageContext()
        completion()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        currentImage?.draw(in: bounds)
    }
}
