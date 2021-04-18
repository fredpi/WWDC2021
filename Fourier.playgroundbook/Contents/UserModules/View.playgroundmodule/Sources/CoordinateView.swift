
import Model
import UIKit

protocol CoordinateViewDelegate: class {
    func coordinateViewDidUpdate(width: CGFloat)
}

class CoordinateView: UIView {
    // MARK: - Properties: UI
    private let xAxis = UIView(frame: .zero)
    private let yAxis = UIView(frame: .zero)
    private let xAxisArrow = UIView(frame: .zero)
    private let yAxisArrow = UIView(frame: .zero)
    private let xAxisTimeLabel = UILabel(frame: .zero)
    private let yAxisMaxValueLabel = UILabel(frame: .zero)
    private let yAxisMinValueLabel = UILabel(frame: .zero)
    private let xAxisMaxValueLabel = UILabel(frame: .zero)
    private let xAxisMinValueLabel = UILabel(frame: .zero)

    private let xAxisMarks = CAShapeLayer()
    private let yAxisMarks = CAShapeLayer()

    private var yAxisHeightConstraint: NSLayoutConstraint!
    private var yAxisWidthConstraint: NSLayoutConstraint!
    private var xAxisHeightConstraint: NSLayoutConstraint!
    private var xAxisWidthConstraint: NSLayoutConstraint!
    private var yAxisMinValueLabelWidthConstraint: NSLayoutConstraint!
    private var yAxisMinValueLabelRightAnchorConstraint: NSLayoutConstraint!
    private var yAxisMaxValueLabelCenterYConstraint: NSLayoutConstraint!
    private var yAxisMinValueLabelCenterYConstraint: NSLayoutConstraint!
    private var xAxisMinValueLabelRightAnchorConstraint: NSLayoutConstraint!
    private var xAxisMaxValueLabelLeftAnchorConstraint: NSLayoutConstraint!
    private var xAxisLeftAnchorConstraint: NSLayoutConstraint!

    internal var leftDiagramAnchor: NSLayoutXAxisAnchor { yAxis.centerXAnchor }

    // MARK: Model
    private let maxAbsValue: Double
    private let relativeDiagramHeight: CGFloat
    private let relativeRightDiagramMargin: CGFloat
    internal weak var delegate: CoordinateViewDelegate?

    // MARK: Constants
    private let relativeAxisMarksLength: CGFloat = 0.015
    private let relativeArrowWidth: CGFloat = 0.02
    private let relativeLineWidth: CGFloat = 0.002
    private var lineWidth: CGFloat { min(2, max(1.5, relativeLineWidth*frame.width)) }
    internal static let lineColor: UIColor = UIColor(red: 68/255, green: 58/255, blue: 65/255, alpha: 1)

    // MARK: - Initializers
    init(maxAbsValue: Double, relativeDiagramHeight: CGFloat, relativeRightDiagramMargin: CGFloat) {
        self.maxAbsValue = maxAbsValue
        self.relativeDiagramHeight = relativeDiagramHeight
        self.relativeRightDiagramMargin = relativeRightDiagramMargin
        let maxValueAsString = maxAbsValue.asString(roundedTo: 1, strippingTrailingZeros: false)
        yAxisMaxValueLabel.text = maxValueAsString
        yAxisMinValueLabel.text = "-\(maxValueAsString)"
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("Unavailable!")
    }

    // MARK: - Methods
    override func layoutSubviews() {
        super.layoutSubviews()

        yAxisHeightConstraint.constant = frame.height
        xAxisHeightConstraint.constant = lineWidth
        yAxisWidthConstraint.constant = lineWidth

        xAxisTimeLabel.font = .systemFont(ofSize: max(14, frame.width * 0.023), weight: .regular)
        xAxisMaxValueLabel.font = .systemFont(ofSize: max(12, frame.width * 0.018), weight: .regular)
        xAxisMinValueLabel.font = .systemFont(ofSize: max(12, frame.width * 0.018), weight: .regular)
        yAxisMaxValueLabel.font = .systemFont(ofSize: max(12, frame.width * 0.018), weight: .regular)
        yAxisMinValueLabel.font = .systemFont(ofSize: max(12, frame.width * 0.018), weight: .regular)

        xAxisTimeLabel.sizeToFit()
        xAxisMinValueLabel.sizeToFit()

        // This is quite hacky, but using sizeToFit() it doesn't work
        yAxisMinValueLabelWidthConstraint.isActive = false
        yAxisMinValueLabel.sizeToFit()
        let width = yAxisMinValueLabel.frame.width
        yAxisMinValueLabelWidthConstraint.constant = width
        yAxisMinValueLabelWidthConstraint.isActive = true

        yAxisMaxValueLabelCenterYConstraint.constant = (1 - relativeDiagramHeight) * frame.height / 2
        yAxisMinValueLabelCenterYConstraint.constant = (relativeDiagramHeight - 1) * frame.height / 2

        yAxisMinValueLabelRightAnchorConstraint.constant = -relativeAxisMarksLength * 0.75 * frame.width

        xAxisMinValueLabelRightAnchorConstraint.constant = 0.005 * frame.width
        xAxisMaxValueLabelLeftAnchorConstraint.constant = (1-relativeRightDiagramMargin+0.005) * frame.width

        xAxisLeftAnchorConstraint.constant = yAxis.frame.midX * 0.7
        xAxisWidthConstraint.constant = max(0, frame.width - xAxisLeftAnchorConstraint.constant)

        drawArrows()
        drawAxisMarks()

        delegate?.coordinateViewDidUpdate(width: frame.width)
    }

    private func drawArrows() {
        yAxisArrow.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        xAxisArrow.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let arrowWidth = relativeArrowWidth * frame.width
        let arrowOffset = arrowWidth / 15

        let yAxisArrowLayer = CAShapeLayer()
        let yAxisArrowPath = CGMutablePath()
        yAxisArrowPath.move(to: .init(x: 0, y: arrowWidth/sqrt(2)-arrowOffset))
        yAxisArrowPath.addLine(to: .init(x: arrowWidth/2, y: -arrowOffset))
        yAxisArrowPath.addLine(to: .init(x: arrowWidth, y: arrowWidth/sqrt(2)-arrowOffset))
        yAxisArrowLayer.path = yAxisArrowPath
        yAxisArrowLayer.fillColor = .none
        yAxisArrowLayer.strokeColor = Self.lineColor.cgColor
        yAxisArrowLayer.lineWidth = lineWidth
        yAxisArrow.layer.addSublayer(yAxisArrowLayer)

        let xAxisArrowLayer = CAShapeLayer()
        let xAxisArrowPath = CGMutablePath()
        xAxisArrowPath.move(to: .init(x: arrowOffset + arrowWidth*(1-1/sqrt(2)), y: 0))
        xAxisArrowPath.addLine(to: .init(x: arrowWidth + arrowOffset, y: arrowWidth/2))
        xAxisArrowPath.addLine(to: .init(x: arrowOffset + arrowWidth*(1-1/sqrt(2)), y: arrowWidth))
        xAxisArrowLayer.path = xAxisArrowPath
        xAxisArrowLayer.fillColor = .none
        xAxisArrowLayer.strokeColor = Self.lineColor.cgColor
        xAxisArrowLayer.lineWidth = lineWidth
        xAxisArrow.layer.addSublayer(xAxisArrowLayer)
    }

    private func drawAxisMarks() {
        guard frame.width > 0, frame.height > 0 else { return }

        // General specification
        let markLength = relativeAxisMarksLength * frame.width

        // X axis marks
        let xMin = yAxis.frame.midX
        let xMax = (1-relativeRightDiagramMargin) * frame.width
        let xSteps: CGFloat = 4
        let xDistance = (xMax-xMin)/xSteps
        let xAxisPath = CGMutablePath()

        for x in stride(from: xMin+xDistance, to: xMax+0.001, by: xDistance) {
            xAxisPath.move(to: .init(x: x, y: frame.height/2-markLength/2))
            xAxisPath.addLine(to: .init(x: x, y: frame.height/2+markLength/2))
        }

        xAxisMarks.path = xAxisPath
        xAxisMarks.fillColor = .none
        xAxisMarks.strokeColor = Self.lineColor.cgColor
        xAxisMarks.lineWidth = lineWidth

        if xAxisMarks.superlayer == nil {
            layer.addSublayer(xAxisMarks)
        }

        // Y axis marks
        let yMin = (1 - relativeDiagramHeight) * frame.height / 2
        let yMax = frame.height - yMin
        let ySteps: CGFloat = 4
        let yDistance = (yMax-yMin)/ySteps
        let yAxisPath = CGMutablePath()

        for (index, y) in stride(from: yMin, to: yMax+0.001, by: yDistance).enumerated() {
            guard CGFloat(index) != ySteps/2 else { continue } // Don't display middle mark (already indicated by x axis)
            yAxisPath.move(to: .init(x: xMin-markLength/2, y: y))
            yAxisPath.addLine(to: .init(x: xMin+markLength/2, y: y))
        }

        yAxisMarks.path = yAxisPath
        yAxisMarks.fillColor = .none
        yAxisMarks.strokeColor = Self.lineColor.cgColor
        yAxisMarks.lineWidth = lineWidth

        if yAxisMarks.superlayer == nil {
            layer.addSublayer(yAxisMarks)
        }
    }

    private func setupView() {
        xAxis.translatesAutoresizingMaskIntoConstraints = false
        yAxis.translatesAutoresizingMaskIntoConstraints = false
        xAxisArrow.translatesAutoresizingMaskIntoConstraints = false
        yAxisArrow.translatesAutoresizingMaskIntoConstraints = false
        xAxisTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        yAxisMaxValueLabel.translatesAutoresizingMaskIntoConstraints = false
        yAxisMinValueLabel.translatesAutoresizingMaskIntoConstraints = false
        xAxisMaxValueLabel.translatesAutoresizingMaskIntoConstraints = false
        xAxisMinValueLabel.translatesAutoresizingMaskIntoConstraints = false

        yAxisHeightConstraint = yAxis.heightAnchor.constraint(equalToConstant: frame.height)
        xAxisWidthConstraint = xAxis.widthAnchor.constraint(equalToConstant: frame.width)
        xAxisHeightConstraint = xAxis.heightAnchor.constraint(equalToConstant: lineWidth)
        yAxisWidthConstraint = yAxis.widthAnchor.constraint(equalToConstant: lineWidth)

        yAxisMinValueLabelWidthConstraint = yAxisMinValueLabel.widthAnchor.constraint(equalToConstant: 0)
        yAxisMinValueLabelRightAnchorConstraint = yAxisMinValueLabel.rightAnchor.constraint(equalTo: yAxis.leftAnchor, constant: 0)
        yAxisMaxValueLabelCenterYConstraint = yAxisMaxValueLabel.centerYAnchor.constraint(equalTo: topAnchor, constant: 0)
        yAxisMinValueLabelCenterYConstraint = yAxisMinValueLabel.centerYAnchor.constraint(equalTo: bottomAnchor, constant: 0)

        xAxisMinValueLabelRightAnchorConstraint = yAxis.leftAnchor.constraint(equalTo: xAxisMinValueLabel.rightAnchor, constant: 0)
        xAxisMaxValueLabelLeftAnchorConstraint = xAxisMaxValueLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)

        xAxisLeftAnchorConstraint = xAxis.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)

        xAxis.backgroundColor = Self.lineColor
        yAxis.backgroundColor = Self.lineColor
        xAxisArrow.backgroundColor = .clear
        yAxisArrow.backgroundColor = .clear

        drawArrows()
        drawAxisMarks()

        xAxisTimeLabel.text = "t"
        xAxisMinValueLabel.text = "0"
        xAxisMaxValueLabel.text = "2"

        xAxisTimeLabel.textAlignment = .right
        xAxisMinValueLabel.textAlignment = .right
        xAxisMaxValueLabel.textAlignment = .left
        yAxisMaxValueLabel.textAlignment = .right
        yAxisMinValueLabel.textAlignment = .right

        xAxisTimeLabel.textColor = Self.lineColor
        xAxisMinValueLabel.textColor = Self.lineColor
        xAxisMaxValueLabel.textColor = Self.lineColor
        yAxisMaxValueLabel.textColor = Self.lineColor
        yAxisMinValueLabel.textColor = Self.lineColor

        addSubview(xAxis)
        addSubview(yAxis)
        addSubview(xAxisArrow)
        addSubview(yAxisArrow)
        addSubview(xAxisTimeLabel)
        addSubview(yAxisMaxValueLabel)
        addSubview(yAxisMinValueLabel)
        addSubview(xAxisMinValueLabel)
        addSubview(xAxisMaxValueLabel)

        let constraint = yAxisMaxValueLabel.widthAnchor.constraint(equalToConstant: 50)
        constraint.priority = UILayoutPriority(500)
        constraint.isActive = true

        let constraints = [
            xAxisHeightConstraint!,
            yAxisWidthConstraint!,
            yAxisHeightConstraint!,
            xAxisWidthConstraint!,
            yAxisMinValueLabelWidthConstraint!,
            yAxisMinValueLabelRightAnchorConstraint!,
            yAxisMaxValueLabel.leftAnchor.constraint(equalTo: leftAnchor),
            yAxisMinValueLabel.leftAnchor.constraint(equalTo: leftAnchor),
            yAxisMinValueLabel.rightAnchor.constraint(equalTo: yAxisMaxValueLabel.rightAnchor),
            yAxisMaxValueLabelCenterYConstraint!,
            yAxisMinValueLabelCenterYConstraint!,
            xAxisMinValueLabel.topAnchor.constraint(equalTo: xAxis.bottomAnchor, constant: 2),
            xAxisMaxValueLabel.topAnchor.constraint(equalTo: xAxisMinValueLabel.topAnchor),
            xAxisMaxValueLabel.bottomAnchor.constraint(equalTo: xAxisMinValueLabel.bottomAnchor),
            xAxisMaxValueLabelLeftAnchorConstraint!,
            xAxisMinValueLabelRightAnchorConstraint!,
            xAxis.centerYAnchor.constraint(equalTo: centerYAnchor),
            xAxisLeftAnchorConstraint!,
            yAxis.topAnchor.constraint(equalTo: topAnchor),
            yAxisArrow.widthAnchor.constraint(equalTo: widthAnchor, multiplier: relativeArrowWidth),
            yAxisArrow.heightAnchor.constraint(equalTo: widthAnchor, multiplier: relativeArrowWidth),
            xAxisArrow.widthAnchor.constraint(equalTo: widthAnchor, multiplier: relativeArrowWidth),
            xAxisArrow.heightAnchor.constraint(equalTo: widthAnchor, multiplier: relativeArrowWidth),
            yAxisArrow.centerXAnchor.constraint(equalTo: yAxis.centerXAnchor),
            yAxisArrow.topAnchor.constraint(equalTo: topAnchor),
            xAxisArrow.rightAnchor.constraint(equalTo: rightAnchor),
            xAxisArrow.centerYAnchor.constraint(equalTo: xAxis.centerYAnchor),
            xAxisTimeLabel.rightAnchor.constraint(equalTo: rightAnchor),
            xAxisTimeLabel.topAnchor.constraint(equalTo: xAxisArrow.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
