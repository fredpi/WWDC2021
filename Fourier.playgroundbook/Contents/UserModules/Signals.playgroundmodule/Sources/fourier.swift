
import Foundation
import Helpers
import Model

public struct fourier: Signal {
    public typealias CoefficientFormula = (Int) -> Double
    private struct Coefficients: Hashable {
        var equal: Double
        var sin: [Double]
        var cos: [Double]

        init(equal: Double, sin: [Double], cos: [Double]) {
            self.equal = equal
            self.sin = sin.reversed().drop { $0 == 0 }.reversed() // drop trailing zeros
            self.cos = cos.reversed().drop { $0 == 0 }.reversed() // drop trailing zeros
        }
    }

    private let coefficients: Coefficients
    private let baseAngularFrequency: Double
    private let maxAbsValueCache = MutableDouble()
    public var maxAbsValue: Double {
        if let value = maxAbsValueCache.value {
            return value
        } else {
            var maxAbsValue: Double

            switch period {
            case let .finite(finitePeriod):
                let max = 100
                let periodThroughMax = finitePeriod / Double(max)
                maxAbsValue = (0..<max).map { abs(value(for: Double($0) * periodThroughMax)) }.max() ?? 1

            default:
                maxAbsValue = abs(value(for: 0))
            }

            maxAbsValue = round(11 * maxAbsValue)/10 // scale by 1.1
            maxAbsValueCache.value = maxAbsValue
            return maxAbsValue
        }
    }

    public let period: Period
    public var shortDescription: String { "fourier signal up to coefficient \(coefficients.sin.count)" }
    public var longDescription: String {
        var summands: [String] = []

        if coefficients.equal != 0 {
            summands.append(coefficients.equal.asString())
        }

        enum BaseAngularFrequency { case pi(timesFactor: Double), other(factor: Double) }

        let baseAngFreqThroughPi = baseAngularFrequency / pi
        let baseAngFreq: BaseAngularFrequency = baseAngFreqThroughPi.isRational ? .pi(timesFactor: baseAngFreqThroughPi) : .other(factor: baseAngularFrequency)

        let sinCount = coefficients.sin.count
        let cosCount = coefficients.cos.count
        let bound = max(sinCount, cosCount)
        if bound >= 1 {
            for index in 1...bound {
                let sin = index <= sinCount ? coefficients.sin[index-1] : 0
                let cos = index <= cosCount ? coefficients.cos[index-1] : 0

                let argument: String
                switch baseAngFreq {
                case let .pi(factor):
                    argument = "\((Double(index)*factor).asString().emptyIf1AndOnlyMinusIfMinus1)𝜋t"
                case let .other(factor):
                    argument = "\((Double(index)*factor).asString().emptyIf1AndOnlyMinusIfMinus1)t"
                }

                if sin != 0 {
                    let factorString = sin.asString()
                    summands.append("\(factorString == "1" ? "" : factorString == "-1" ? "-" : "\(factorString)•")sin(\(argument))")
                }

                if cos != 0 {
                    let factorString = cos.asString()
                    summands.append("\(factorString == "1" ? "" : factorString == "-1" ? "-" : "\(factorString)•")cos(\(argument))")
                }
            }
        }

        func concatenate(summands: [String]) -> String {
            guard !summands.isEmpty else { return "0" }

            return summands.dropFirst().reduce(summands.first!) {
                $1.starts(with: "-") ? "\($0) - \($1.dropFirst())" : "\($0) + \($1)"
            }
        }

        return summands.count <= 4 ?
            concatenate(summands: summands) :
            concatenate(summands: Array(summands[0...1] + ["..."] + summands.reversed()[0...1].reversed()))
    }

    public init(
        equalPart: Double = 0,
        baseAngularFrequency: Double,
        sinCoefficients: [Double] = [],
        cosCoefficients: [Double] = []
    ) {
        coefficients = .init(equal: equalPart, sin: sinCoefficients, cos: cosCoefficients)
        self.baseAngularFrequency = baseAngularFrequency
        period = baseAngularFrequency == 0 ? .infinite : .finite(_2pi/abs(baseAngularFrequency))
    }

    public init(
        equalPart: Double = 0,
        baseAngularFrequency: Double,
        sinCoefficientFormula: CoefficientFormula = { _ in 0 },
        cosCoefficientFormula: CoefficientFormula = { _ in 0 },
        upToCoefficient maxCoefficient: Int
    ) {
        let maxCoefficient = max(0, min(100, maxCoefficient)) // Cap at 100

        let cosCoefficients: [Double] = maxCoefficient < 1 ? [] : (1...maxCoefficient).map(cosCoefficientFormula)
        let sinCoefficients: [Double] = maxCoefficient < 1 ? [] : (1...maxCoefficient).map(sinCoefficientFormula)

        coefficients = .init(equal: equalPart, sin: sinCoefficients, cos: cosCoefficients)
        self.baseAngularFrequency = baseAngularFrequency
        period = baseAngularFrequency == 0 ? .infinite : .finite(_2pi/abs(baseAngularFrequency))
    }

    public func value(for time: Double) -> Double {
        return coefficients.equal
            + coefficients.sin.enumerated().reduce(0) { $0 + $1.1 * Foundation.sin(baseAngularFrequency*Double($1.0+1)*time) }
            + coefficients.cos.enumerated().reduce(0) { $0 + $1.1 * Foundation.cos(baseAngularFrequency*Double($1.0+1)*time) }
    }
}

// MARK: - Hashable
extension fourier: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(coefficients)
        hasher.combine(baseAngularFrequency)
    }

    public static func ==(lhs: fourier, rhs: fourier) -> Bool {
        lhs.coefficients == rhs.coefficients && lhs.baseAngularFrequency == rhs.baseAngularFrequency
    }
}
