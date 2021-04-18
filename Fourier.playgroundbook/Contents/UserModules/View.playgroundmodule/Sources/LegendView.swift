
import Model
import Signals
import UIKit

class LegendView: UIView {
    // MARK: - Properties: View
    private let legendItemViews: [LegendItemView]

    // MARK: Model
    private var signalsWithColors: [SignalWithColor]
    private let relativeLineWidth: CGFloat = 0.002
    private var lineWidth: CGFloat { min(2, max(1.5, relativeLineWidth*frame.width)) }

    // MARK: - Initializers
    init(signalsWithColors: [SignalWithColor]) {
        self.signalsWithColors = signalsWithColors
        legendItemViews = (0..<signalsWithColors.count).map { _ in LegendItemView() }

        super.init(frame: .zero)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("Unavailable!")
    }

    // MARK: - Methods
    func replace(_ oldSignal: Signal, with newSignal: Signal, animationDuration: Double = 0.2) {
        guard let index = getIndex(of: oldSignal) else { return print("⚠️ Couldn't find old signal") }
        signalsWithColors[index].signal = newSignal
        UIView.transition(
            with: self,
            duration: animationDuration,
            options: .transitionCrossDissolve,
            animations: { [weak self] in self?.setLegendItemViewModels() }
        )
    }

    private func getIndex(of signal: Signal) -> Int? {
        var enumeratedSignals = signalsWithColors.enumerated().map { (index: $0, signal: $1.signal) }

        var attempt: Int = 0
        while true {
            attempt += 1
            let sampleTime = Double.random(in: 0..<1)
            let signalAtSampleTime = signal.value(for: sampleTime)
            enumeratedSignals = enumeratedSignals.filter { $0.signal.value(for: sampleTime) == signalAtSampleTime }

            if enumeratedSignals.count == 1 || attempt > 10 {
                return enumeratedSignals.first?.index
            }
        }
    }

    private func setLegendItemViewModels() {
        for (view, signalWithColor) in zip(legendItemViews, signalsWithColors) {
            view.viewModel = .init(color: signalWithColor.color, description: signalWithColor.signal.longDescription)
        }
    }

    private func setupView() {
        layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        setLegendItemViewModels()
        legendItemViews.forEach { addSubview($0) }

        var constraints: [NSLayoutConstraint] = [legendItemViews.last!.bottomAnchor.constraint(equalTo: bottomAnchor)]
        for (index, view) in legendItemViews.enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            constraints.append(
                contentsOf: [
                    view.leftAnchor.constraint(equalTo: leftAnchor),
                    view.rightAnchor.constraint(equalTo: rightAnchor),
                    view.topAnchor.constraint(equalTo: index == 0 ? topAnchor : legendItemViews[index-1].bottomAnchor),
                    view.heightAnchor.constraint(equalTo: legendItemViews[(index + 1) % legendItemViews.count].heightAnchor)
                ]
            )
        }

        NSLayoutConstraint.activate(constraints)
    }
}
