import UIKit

class LetterTracingView: UIView {

    private var letter: String = ""
    private let drawingLayer = CAShapeLayer()
    private var currentPath = UIBezierPath()
    private var hasBeenTraced = false
    private var hasNotifiedTraced = false
    var onTracingCompleted: (() -> Void)?

    private let letterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Andika-Bold", size: 110) ?? UIFont.systemFont(ofSize: 110, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor.systemGray5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor

        addSubview(letterLabel)
        NSLayoutConstraint.activate([
            letterLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            letterLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            letterLabel.widthAnchor.constraint(equalTo: widthAnchor),
            letterLabel.heightAnchor.constraint(equalTo: heightAnchor)
        ])

        // Setup drawing layer
        drawingLayer.strokeColor = UIColor.systemBlue.cgColor
        drawingLayer.fillColor = UIColor.clear.cgColor
        drawingLayer.lineWidth = 8
        drawingLayer.lineCap = .round
        drawingLayer.lineJoin = .round
        layer.addSublayer(drawingLayer)

        currentPath.lineWidth = 8
        currentPath.lineCapStyle = .round
        currentPath.lineJoinStyle = .round
    }

    func setLetter(_ letter: String) {
        self.letter = letter
        letterLabel.text = letter.lowercased()
        letterLabel.font = UIFont(name: "Andika-Bold", size: 110) ?? UIFont.systemFont(ofSize: 110, weight: .bold)
        letterLabel.transform = CGAffineTransform(scaleX: horizontalScale(for: letter), y: 1.0)
        clearDrawing()
    }

    private func horizontalScale(for letter: String) -> CGFloat {
        switch letter.lowercased() {
        case "j":
            return 1.0
        case "f", "r", "t":
            return 1.0
        default:
            return 1.0
        }
    }

    func clearDrawing() {
        currentPath.removeAllPoints()
        drawingLayer.path = nil
        hasBeenTraced = false
        hasNotifiedTraced = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        currentPath.move(to: point)
        hasBeenTraced = true
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        currentPath.addLine(to: point)
        drawingLayer.path = currentPath.cgPath
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if hasBeenTraced && !hasNotifiedTraced {
            hasNotifiedTraced = true
            onTracingCompleted?()
        }
    }

    func hasDrawing() -> Bool {
        return hasBeenTraced
    }
}
