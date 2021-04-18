
import Model
import Signals
import PlaygroundSupport
import UIKit

public class SignalViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    // MARK: - Properties: UI
    private let backgroundView = BackgroundView()
    private let containerView = UIView()
    private let diagramView: DiagramView
    private let coordinateView: CoordinateView
    private let legendView: LegendView

    // MARK: Model
    private var displayLink: CADisplayLink?
    private var simulationStartTime: Double = 0
    private var lastSimulationTime: Double = 0
    private var evolvingSignalEvolutions: [Signal]
    private var removedSignalsCount: Int
    private var signalsCount: Int
    private let finishCompletion: (() -> Void)?

    private var diagramViewLeftAnchorConstraint: NSLayoutConstraint!
    private var diagramViewRightAnchorConstraint: NSLayoutConstraint!
    private var coordinateViewLeftAnchorConstraint: NSLayoutConstraint!
    private var coordinateViewRightAnchorConstraint: NSLayoutConstraint!
    private var coordinateViewTopAnchorConstraint: NSLayoutConstraint!
    private var coordinateViewBottomAnchorConstraint: NSLayoutConstraint!
    private var containerViewLeftAnchorConstraint: NSLayoutConstraint!
    private var containerViewRightAnchorConstraint: NSLayoutConstraint!
    private var containerViewLeftAnchorConstraint2: NSLayoutConstraint!
    private var containerViewRightAnchorConstraint2: NSLayoutConstraint!
    private var containerViewTopAnchorConstraint: NSLayoutConstraint!
    private var containerViewBottomAnchorConstraint: NSLayoutConstraint!
    private var legendViewLeftAnchorConstraint: NSLayoutConstraint!
    private var legendViewRightAnchorConstraint: NSLayoutConstraint!
    private var legendViewBottomAnchorConstraint: NSLayoutConstraint!
    private var legendViewHeightConstraint: NSLayoutConstraint!

    // MARK: Constants
    private let relativeRightDiagramMargin: CGFloat = 0.05
    private let relativeDiagramHeight: CGFloat = 0.85
    private let relativeCoordinateViewLeftRightMargin: CGFloat = 0.03
    private let relativeCoordinateViewTopBottomMargin: CGFloat = 0.03
    private let relativeCornerRadius: CGFloat = 0.02
    private let containerViewRelativeMarging: CGFloat = 0.05
    private let relativeLineWidth: CGFloat = 0.002
    private var lineWidth: CGFloat { min(2, max(1.5, relativeLineWidth*view.frame.width)) }

    private static let signalColors: [UIColor] = [
        UIColor(red: 17/255, green: 7/255, blue: 222/255, alpha: 1),
        UIColor(red: 225/255, green: 5/255, blue: 245/255, alpha: 1),
        UIColor(red: 222/255, green: 34/255, blue: 7/255, alpha: 1),
        UIColor(red: 6/255, green: 167/255, blue: 212/255, alpha: 1),
        UIColor(red: 250/255, green: 148/255, blue: 2/255, alpha: 1),
    ]
    private static let maxSignalCount = 5

    // MARK: - Initializers
    public init(_ signals: Signal..., finishCompletion: (() -> Void)? = nil) {
        let signals = signals.filter { !($0 is dummy) }
        let signalsWithColors = Self.process(signals: signals)

        evolvingSignalEvolutions = []
        signalsCount = signalsWithColors.count
        removedSignalsCount = signals.count - signalsCount
        self.finishCompletion = finishCompletion

        let maxAbsValue = max(signalsWithColors.max { $0.signal.maxAbsValue < $1.signal.maxAbsValue }?.signal.maxAbsValue ?? 1, 1)
        diagramView = DiagramView(signalsWithColors: signalsWithColors, maxAbsValue: maxAbsValue)
        coordinateView = CoordinateView(maxAbsValue: maxAbsValue, relativeDiagramHeight: relativeDiagramHeight, relativeRightDiagramMargin: relativeRightDiagramMargin)
        legendView = LegendView(signalsWithColors: signalsWithColors)

        super.init(nibName: nil, bundle: nil)

        coordinateView.delegate = self
    }

    public init(_ fixedSignals: Signal..., evolvingSignal: @escaping (Int) -> Signal, maxCoefficient: Int, finishCompletion: (() -> Void)? = nil) {
        let fixedSignals = fixedSignals.filter { !($0 is dummy) }
        let maxCoefficient = max(0, min(100, maxCoefficient))
        var signalEvolutions = (0...maxCoefficient).map(evolvingSignal)
        if let fourierOnlyEvolutions = signalEvolutions as? [fourier] {
            // If all evolutions are fourier signals, we can use fourier's Hashable conformance to remove signals
            // that are identical across multiple evolutions (e. g. when the signal only changes for odd evolution numbers)
            signalEvolutions = NSOrderedSet(array: fourierOnlyEvolutions).map { $0 as! fourier }
        }
        let signalsWithColors = Self.process(signals: fixedSignals, evolvingSignalEvolutions: signalEvolutions)

        evolvingSignalEvolutions = signalEvolutions
        signalsCount = signalsWithColors.count
        removedSignalsCount = fixedSignals.count + (signalEvolutions.isEmpty ? 0 : 1) - signalsCount
        self.finishCompletion = finishCompletion

        let maxAbsValue = max(1, (signalsWithColors.map(\.signal) + signalEvolutions).max { $0.maxAbsValue < $1.maxAbsValue }?.maxAbsValue ?? 1)
        diagramView = DiagramView(signalsWithColors: signalsWithColors, maxAbsValue: maxAbsValue)
        coordinateView = CoordinateView(maxAbsValue: maxAbsValue, relativeDiagramHeight: relativeDiagramHeight, relativeRightDiagramMargin: relativeRightDiagramMargin)
        legendView = LegendView(signalsWithColors: signalsWithColors)

        super.init(nibName: nil, bundle: nil)

        coordinateView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("Unavailable!")
    }

    // MARK: - Methods
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width = view.frame.width

        coordinateViewLeftAnchorConstraint.constant = relativeCoordinateViewLeftRightMargin * width
        coordinateViewRightAnchorConstraint.constant = relativeCoordinateViewLeftRightMargin * width
        coordinateViewTopAnchorConstraint.constant = relativeCoordinateViewTopBottomMargin * width
        coordinateViewBottomAnchorConstraint.constant = relativeCoordinateViewTopBottomMargin * width

        legendViewBottomAnchorConstraint.constant = relativeCoordinateViewTopBottomMargin * width
        legendViewHeightConstraint.constant = 0.038 * min(width, UIScreen.main.bounds.width) * CGFloat(signalsCount)

        containerViewLeftAnchorConstraint.constant = containerViewRelativeMarging * width
        containerViewRightAnchorConstraint.constant = containerViewRelativeMarging * width
        containerViewLeftAnchorConstraint2.constant = containerViewRelativeMarging * width
        containerViewRightAnchorConstraint2.constant = containerViewRelativeMarging * width
        containerViewTopAnchorConstraint.constant = containerViewRelativeMarging * width
        containerViewBottomAnchorConstraint.constant = containerViewRelativeMarging * width

        containerView.layer.cornerRadius = relativeCornerRadius * width
    }

    // MARK: Starting
    /// This method must be called so that the view can be seen
    public func start() {
        if removedSignalsCount == 0 {
            renderSignalEvolution(signalEvolutions: evolvingSignalEvolutions, finishCompletion: finishCompletion)
        } else {
            let alert = UIAlertController(title: "Max. \(Self.maxSignalCount) signals", message: "A maximum of \(Self.maxSignalCount) signals can be presented.\n\nThis is why \(removedSignalsCount) \(removedSignalsCount == 1 ? "signal" : "signals") of the \(removedSignalsCount+Self.maxSignalCount) signals you specified \(removedSignalsCount == 1 ? "has" : "have") been removed.", preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.renderSignalEvolution(signalEvolutions: self.evolvingSignalEvolutions, finishCompletion: self.finishCompletion)
                }
            )
            self.present(alert, animated: true)
        }
    }

    private static func process(signals: [Signal], evolvingSignalEvolutions: [Signal] = []) -> [SignalWithColor] {
        var signals = signals
        if let first = evolvingSignalEvolutions.first { signals = [first] + signals }
        let chosenSignals = signals[0..<min(maxSignalCount, signals.count)]
        return chosenSignals.enumerated().map { (signal: $1, color: signalColors[$0]) }
    }

    // MARK: Evolving Signal
    private func renderSignalEvolution(signalEvolutions: [Signal], finishCompletion: (() -> Void)? = nil) {
        var currentEvolutionNumber = 1
        let animationDuration = 0.2

        func loop() {
            if currentEvolutionNumber < signalEvolutions.count {
                let stepDuration = currentEvolutionNumber == 1 ? 0.8 : min(0.6, max(0.3, 0.75-0.03*Double(currentEvolutionNumber)))
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + stepDuration) { [weak self] in
                    guard let self = self else { return }
                    self.diagramView.replace(signalEvolutions[currentEvolutionNumber-1], with: signalEvolutions[currentEvolutionNumber], animationDuration: animationDuration)
                    self.legendView.replace(signalEvolutions[currentEvolutionNumber-1], with: signalEvolutions[currentEvolutionNumber], animationDuration: animationDuration)
                    currentEvolutionNumber += 1
                    loop()
                }
            } else {
                finishCompletion?()
            }
        }

        loop()
    }

    // MARK: View Setup
    private func setupView() {
        // Only setup once
        guard view.subviews.isEmpty else { return }

        // Disable autoresizing mask
        containerView.translatesAutoresizingMaskIntoConstraints = false
        coordinateView.translatesAutoresizingMaskIntoConstraints = false
        diagramView.translatesAutoresizingMaskIntoConstraints = false
        legendView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        // Configure backgroundColor
        containerView.layer.backgroundColor = UIColor.white.withAlphaComponent(0.5).cgColor

        // Configure white overlay view
        backgroundView.layer.zPosition = -100

        // Add views
        containerView.addSubview(coordinateView)
        containerView.addSubview(diagramView)
        containerView.addSubview(legendView)
        view.addSubview(containerView)
        view.addSubview(backgroundView)

        // Define fixed constraints
        diagramViewLeftAnchorConstraint = diagramView.leftAnchor.constraint(equalTo: coordinateView.leftDiagramAnchor, constant: 0)
        diagramViewRightAnchorConstraint = diagramView.rightAnchor.constraint(equalTo: coordinateView.rightAnchor, constant: 0)

        coordinateViewLeftAnchorConstraint = coordinateView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0)
        coordinateViewRightAnchorConstraint = containerView.rightAnchor.constraint(equalTo: coordinateView.rightAnchor, constant: 0)
        coordinateViewTopAnchorConstraint = coordinateView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0)
        coordinateViewBottomAnchorConstraint = legendView.topAnchor.constraint(equalTo: coordinateView.bottomAnchor, constant: 0)

        containerViewLeftAnchorConstraint = containerView.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0)
        containerViewRightAnchorConstraint = view.safeAreaLayoutGuide.rightAnchor.constraint(greaterThanOrEqualTo: containerView.rightAnchor, constant: 0)
        containerViewLeftAnchorConstraint2 = containerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0)
        containerViewRightAnchorConstraint2 = view.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0)
        containerViewTopAnchorConstraint = containerView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        containerViewBottomAnchorConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: containerView.bottomAnchor, constant: 0)

        legendViewLeftAnchorConstraint = legendView.leftAnchor.constraint(equalTo: diagramView.leftAnchor, constant: 0)
        legendViewRightAnchorConstraint = diagramView.rightAnchor.constraint(equalTo: legendView.rightAnchor, constant: 0)
        legendViewBottomAnchorConstraint = containerView.bottomAnchor.constraint(equalTo: legendView.bottomAnchor, constant: 0)
        legendViewHeightConstraint = legendView.heightAnchor.constraint(equalToConstant: 100)

        let constraints = [
            // Constraint coordinate view relative to container view
            coordinateViewLeftAnchorConstraint!,
            coordinateViewRightAnchorConstraint!,
            coordinateViewTopAnchorConstraint!,
            coordinateViewBottomAnchorConstraint!,

            // Constraint diagram view
            diagramViewLeftAnchorConstraint!,
            diagramViewRightAnchorConstraint!,
            diagramView.centerYAnchor.constraint(equalTo: coordinateView.centerYAnchor),
            diagramView.heightAnchor.constraint(equalTo: coordinateView.heightAnchor, multiplier: relativeDiagramHeight),
            diagramView.widthAnchor.constraint(equalTo: diagramView.heightAnchor, multiplier: 2),

            // Legend view
            legendViewLeftAnchorConstraint!,
            legendViewRightAnchorConstraint!,
            legendViewBottomAnchorConstraint!,
            legendViewHeightConstraint!,

            // Container View
            containerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            containerViewLeftAnchorConstraint!,
            containerViewRightAnchorConstraint!,
            containerViewTopAnchorConstraint!,
            containerViewBottomAnchorConstraint!,

            // White overlay view
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        let lessPrioConstraints: [NSLayoutConstraint] = [
            containerViewLeftAnchorConstraint2!,
            containerViewRightAnchorConstraint2!,
        ].map { $0.priority = UILayoutPriority(rawValue: 950); return $0 }

        NSLayoutConstraint.activate(constraints)
        NSLayoutConstraint.activate(lessPrioConstraints)
    }
}

// MARK: - CoordinateViewDelegate
extension SignalViewController: CoordinateViewDelegate {
    func coordinateViewDidUpdate(width: CGFloat) {
        diagramViewRightAnchorConstraint?.constant = -relativeRightDiagramMargin * width
    }
}
