
import Foundation
import Helpers
import Model

internal struct sum: Signal {
    private let signals: [Signal]
    public let period: Period

    private let maxAbsValueCache = MutableDouble()
    internal var maxAbsValue: Double {
        if let value = maxAbsValueCache.value {
            return value
        } else {
            var maxAbsValue: Double

            if (signals.flatMap { ($0 as? sum)?.signals ?? [$0] }.filter { !($0 is const) }).count <= 1 {
                // Only 0 or 1 non-const signals -> conservative estimate is the correct one
                maxAbsValue = signals.reduce(0) { $0 + $1.maxAbsValue }
            } else {
                switch period {
                case let .finite(finitePeriod):
                    let max = 100
                    let periodThroughMax = finitePeriod / Double(max)
                    maxAbsValue = (0..<max).map { abs(value(for: Double($0) * periodThroughMax)) }.max() ?? 1
                    maxAbsValue = round(11 * maxAbsValue)/10 // scale by 1.1

                default:
                    // Conservative estimate
                    maxAbsValue = signals.reduce(0) { $0 + $1.maxAbsValue }
                }
            }

            maxAbsValueCache.value = maxAbsValue
            return maxAbsValue
        }
    }

    public var shortDescription: String { "sum of \(signals.count) signals" }
    public var longDescription: String {
        if let first = signals.first {
            return signals.dropFirst().reduce(first.longDescription) {
                let appendix = $1.longDescription
                return appendix.starts(with: "-") ? "\($0) - \(appendix.dropFirst())" : "\($0) + \(appendix)"
            }
        }

        return "0"
    }

    internal init(_ signals: Signal...) {
        self.signals = signals.filter { ($0 as? Double) != 0 }

        let periods = signals.map(\.period)
        if periods.contains(.unknown) {
            period = .unknown
        } else {
            let finitePeriods = periods.compactMap { (period: Period) -> Double? in if case let .finite(value) = period { return value }; return nil }
            period = finitePeriods.isEmpty
                ? .infinite
                : .finite(min(Double.lcm(finitePeriods), Double.lcm(finitePeriods.map { $0 / pi }) * pi))
        }
    }

    internal func value(for time: Double) -> Double {
        signals.reduce(0) { $0 + $1.value(for: time) }
    }
}
