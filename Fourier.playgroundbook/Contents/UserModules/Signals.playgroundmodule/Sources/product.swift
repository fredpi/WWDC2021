
import Model

fileprivate extension Signal {
    var needsBrackets: Bool { self is sum || self is fourier }
}

fileprivate extension String {
    // This only switches the signs outside the argument, because within the argument + and - is used without a space
    var switchedSigns: String {
        self
            .replacingOccurrences(of: " + ", with: "<plus>")
            .replacingOccurrences(of: " - ", with: "<minus>")
            .replacingOccurrences(of: "<minus>", with: " + ")
            .replacingOccurrences(of: "<plus>", with: " - ")
    }
}

internal struct product: Signal {
    private let signals: [Signal]
    internal let maxAbsValue: Double
    internal let period: Period

    public var shortDescription: String { "product of \(signals.count) signals" }
    public var longDescription: String {
        if let first = signals.first {
            let firstDescription = first.longDescription
            let signalsWithoutFirst = signals.dropFirst()
            let startValue = first.needsBrackets && signalsWithoutFirst.contains { $0.longDescription != "1" } ? "(\(firstDescription))" : firstDescription
            return signalsWithoutFirst.reduce(startValue) {
                let appendix = $1.longDescription
                return $0 == "1" ? appendix : appendix == "1" ? $0 :
                    $0 == "-1" ? "-\(appendix.switchedSigns)" : appendix == "-1" ? "-\($0.switchedSigns)" :
                    $1.needsBrackets ? "\($0)•(\(appendix))" : "\($0)•\(appendix)"
            }
        }

        return "0"
    }

    internal init(_ signals: Signal...) {
        self.signals = signals.contains { $0 as? Double == 0 } ? [0] : signals.filter { ($0 as? Double) != 1 }

        maxAbsValue = signals.reduce(1) { $0 * $1.maxAbsValue } // Conservative estimate
        period = signals.filter { $0.period == .infinite }.count <= 1 // Only determine period if one sig is multiplied by constants (infinite period)
            ? signals.first { $0.period != .infinite }?.period ?? .unknown
            : .unknown
    }

    internal func value(for time: Double) -> Double {
        signals.reduce(1) { $0 * $1.value(for: time) }
    }
}
