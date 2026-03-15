import UIKit

class WordItemView: UIView {

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 60)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let wordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let tracingView: LetterTracingView = {
        let view = LetterTracingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(emojiLabel)
        containerView.addSubview(wordLabel)
        containerView.addSubview(tracingView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emojiLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            emojiLabel.heightAnchor.constraint(equalToConstant: 70),

            wordLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            wordLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            tracingView.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 12),
            tracingView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            tracingView.widthAnchor.constraint(equalToConstant: 132),
            tracingView.heightAnchor.constraint(equalToConstant: 154),
            tracingView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with wordItem: WordItem) {
        emojiLabel.text = wordItem.emoji
        wordLabel.text = wordItem.word
        tracingView.setLetter(wordItem.firstLetter)
    }

    func resetTracing() {
        tracingView.clearDrawing()
    }
}
