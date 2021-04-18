
import UIKit

class BackgroundView: UIView {
    // MARK: - Properties
    private let backgroundImageView = UIImageView()
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    // MARK: - Initializers
    init() {
        super.init(frame: .zero)

        backgroundImageView.image = UIImage(named: "background.png")

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backgroundImageView)
        addSubview(visualEffectView)

        let constraints = [
            backgroundImageView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: rightAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            visualEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            visualEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("Unavailable!")
    }
}
