
import Foundation
import Model

public struct sin: Signal {
    private let argument: Argument
    public let maxAbsValue: Double = 1
    public let period: Period
    public var longDescription: String { "sin(\(argument.description))" }

    public init(_ argument: Argument) {
        self.argument = argument
        let frequency = abs((argument(1) - argument(0))) / _2pi
        period = frequency == 0 ? .infinite : .finite(1/frequency)
    }

    public func value(for time: Double) -> Double {
        Foundation.sin(argument(time))
    }
}
