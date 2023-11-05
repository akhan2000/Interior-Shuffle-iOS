import UIKit

class ResizableCircle: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinchGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        let translation = gesture.translation(in: superview)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gesture.setTranslation(.zero, in: superview)
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale
        frame.size = CGSize(width: frame.width * scale, height: frame.height * scale)
        gesture.scale = 1.0
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineWidth(2)
        context.setStrokeColor(UIColor.red.cgColor)
        context.addEllipse(in: rect.insetBy(dx: 2, dy: 2))
        context.strokePath()
    }
}

protocol EraserViewDelegate: AnyObject {
    func didTapProcess()
    func didTapSubmit()
}

class EraserView: UIView {
    var currentImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    private var circles: [ResizableCircle] = []
    private var promptLabel: UILabel!
    private var processButton: UIButton!
    weak var delegate: EraserViewDelegate?
    private var submitButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
        
        promptLabel = UILabel()
        promptLabel.text = "Tap to draw circles around areas you want to erase."
        promptLabel.numberOfLines = 0
        promptLabel.textAlignment = .center
        promptLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        promptLabel.frame = CGRect(x: 0, y: 20, width: bounds.width, height: 80)
        addSubview(promptLabel)
        
        processButton = UIButton(type: .system)
        processButton.setTitle("Process", for: .normal)
        processButton.addTarget(self, action: #selector(processButtonTapped), for: .touchUpInside)
        processButton.frame = CGRect(x: bounds.width - 110, y: bounds.height - 60, width: 100, height: 30)
        addSubview(processButton)
        
        submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        submitButton.frame = CGRect(x: 10, y: bounds.height - 60, width: 100, height: 30)
        addSubview(submitButton)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        addCircle(at: location)
    }

    private func addCircle(at location: CGPoint) {
        let circle = ResizableCircle(frame: CGRect(x: location.x - 50, y: location.y - 50, width: 100, height: 100))
        addSubview(circle)
        circles.append(circle)
    }

    @objc private func processButtonTapped() {
        processErasure {
            self.delegate?.didTapProcess()
        }
    }
    
    @objc private func submitButtonTapped() {
        delegate?.didTapSubmit()
    }
    
    func processErasure(completion: @escaping () -> Void) {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        currentImage?.draw(in: bounds)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setBlendMode(.clear)
        for circle in circles {
            context.addEllipse(in: circle.frame)
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
