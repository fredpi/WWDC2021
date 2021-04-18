
import Model
import Signals
import UIKit

class DiagramView: UIView {
    // MARK: - Properties
    private var signalsWithColors: [SignalWithColor]
    private let maxAbsValue: Double
    private let maxTime: Double
    private let relativeLineWidth: CGFloat = 0.004
    private var lineWidth: CGFloat { min(3.5, max(1.5, relativeLineWidth*frame.width)) }
    private let signalLayers: [CAShapeLayer]

    // MARK: - Initializers
    init(signalsWithColors: [SignalWithColor], maxAbsValue: Double, maxTime: Double = 2) {
        self.signalsWithColors = signalsWithColors
        self.maxAbsValue = maxAbsValue
        self.maxTime = maxTime
        signalLayers = (0..<signalsWithColors.count).map { _ in CAShapeLayer() }

        super.init(frame: .zero)

        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("Unavailable!")
    }

    // MARK: - Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        draw()
    }

    func replace(_ oldSignal: Signal, with newSignal: Signal, animationDuration: Double? = 0.2) {
        guard let index = getIndex(of: oldSignal) else { return print("⚠️ Couldn't find old signal") }

        signalsWithColors[index].signal = newSignal

        let width = frame.width
        let height = frame.height
        guard width > 0, height > 0 else { return }

        let scale = UIScreen.main.scale
        let pixels = Int(frame.width * scale)
        let color = signalsWithColors[index].color

        render(signal: newSignal, in: color, on: signalLayers[index], pixels: pixels, scale: scale, width: width, height: height, animationDuration: animationDuration)
    }

    private func getIndex(of signal: Signal) -> Int? {
        var enumeratedSignals = signalsWithColors.enumerated().map { (index: $0, signal: $1.signal) }

        var attempt: Int = 0
        while true {
            attempt += 1
            let sampleTime = Double.random(in: 0..<maxTime)
            let signalAtSampleTime = signal.value(for: sampleTime)
            enumeratedSignals = enumeratedSignals.filter { $0.signal.value(for: sampleTime) == signalAtSampleTime }

            if enumeratedSignals.count == 1 || attempt > 10 {
                return enumeratedSignals.first?.index
            }
        }
    }

    private func draw() {
        let width = frame.width
        let height = frame.height
        guard width > 0, height > 0 else { return }

        let scale = UIScreen.main.scale
        let pixels = Int(frame.width * scale)

        for (signalWithColor, signalLayer) in zip(signalsWithColors, signalLayers) {
            render(signal: signalWithColor.signal, in: signalWithColor.color, on: signalLayer, pixels: pixels, scale: scale, width: width, height: height)
        }
    }

    private func render(
        signal: Signal,
        in color: UIColor,
        on signalLayer: CAShapeLayer,
        pixels: Int,
        scale: CGFloat,
        width: CGFloat,
        height: CGFloat,
        animationDuration: Double? = nil
    ) {
        var points: [CGPoint]

        switch signal.period {
        case .infinite:
            // This means the signal is constant
            let value = height * (1/2 - CGFloat(signal.value(for: 0))/CGFloat(maxAbsValue)/2) // constant value
            points = (0...pixels).map { CGPoint(x: CGFloat($0)/scale, y: value) }

        case let .finite(period):
            // Rendering leveraging signal periodicity
            let periodInPixels = CGFloat(period / maxTime) * width * scale
            let ceiledPeriodInPixels: Int = Int(ceil(periodInPixels))
            let periodThroughCeiledPeriodInPixels = period / Double(ceiledPeriodInPixels)
             points = (0..<min(ceiledPeriodInPixels, pixels+1)).map { pixel in
                CGPoint(
                    x: CGFloat(pixel)/scale,
                    y: height * (1/2 - CGFloat(signal.value(for: Double(pixel)*periodThroughCeiledPeriodInPixels)/maxAbsValue/2))
                )
            }

            if ceiledPeriodInPixels < pixels {
                for pixel in ceiledPeriodInPixels...pixels {
                    points.append(.init(x: CGFloat(pixel)/scale, y: points[pixel % ceiledPeriodInPixels].y))
                }
            }

        case .unknown:
            // Rendering without leveraging signal periodicity
            points = (0...pixels).map { pixel -> CGPoint in
                CGPoint(
                    x: CGFloat(pixel)/scale,
                    y: height * (1/2 - CGFloat(signal.value(for: Double(pixel)/Double(pixels)*maxTime)/maxAbsValue/2))
                )
            }
        }

        let path = CGMutablePath()
        path.move(to: points.first!)
        _ = points.dropFirst()
        points.forEach { path.addLine(to: $0) }

        if let animationDuration = animationDuration {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = signalLayer.path
            animation.toValue = path
            animation.duration = animationDuration
            signalLayer.add(animation, forKey: "path")
        }

        signalLayer.path = path
        signalLayer.lineWidth = lineWidth

        if signalLayer.superlayer == nil {
            signalLayer.strokeColor = color.cgColor
            signalLayer.fillColor = .none
            signalLayer.disableAnimations()
            layer.addSublayer(signalLayer)
        }
    }
}
