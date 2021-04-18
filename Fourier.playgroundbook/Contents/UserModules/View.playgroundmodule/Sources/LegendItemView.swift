
import Model
import UIKit

class LegendItemView: UIView {
    // MARK: - Subtypes
    struct ViewModel {
        var color: UIColor
        var description: String
    }

    // MARK: - Properties: UI
    let colorView = UIView()
    let descriptionLabel = UILabel()

    var colorViewRightConstraint: NSLayoutConstraint!

    // MARK: Model
    var viewModel: ViewModel? {
        didSet {
            colorView.backgroundColor = viewModel?.color
            descriptionLabel.text = viewModel?.description
        }
    }

    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("Unavailable!")
    }

    // MARK: - Methods
    override func layoutSubviews() {
        super.layoutSubviews()

        colorView.layer.cornerRadius = colorView.frame.width / 2
        colorViewRightConstraint.constant = -colorView.frame.width / 2

        descriptionLabel.font = UIFont.systemFont(ofSize: descriptionLabel.frame.height / 1.5, weight: .light)
    }

    private func setupView() {
        colorView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        colorView.layer.masksToBounds = true

        descriptionLabel.textAlignment = .left
        descriptionLabel.minimumScaleFactor = 0.5
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.textColor = UIColor.black.withAlphaComponent(0.8)

        addSubview(colorView)
        addSubview(descriptionLabel)

        colorViewRightConstraint = colorView.rightAnchor.constraint(equalTo: descriptionLabel.leftAnchor, constant: 0)

        let constraints = [
            colorViewRightConstraint!,
            colorView.widthAnchor.constraint(equalTo: colorView.heightAnchor),
            colorView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),
            colorView.leftAnchor.constraint(equalTo: leftAnchor),
            colorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            descriptionLabel.rightAnchor.constraint(equalTo: rightAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
