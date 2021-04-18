
import Helpers
import Model

public struct rect: Signal {
    private let argument: Argument
    public let maxAbsValue: Double = 1
    public let period: Period
    public var longDescription: String { "rect(\(argument.description))" }

    public init(_ argument: Argument) {
        self.argument = argument
        let frequency = abs((argument(1) - argument(0))) / _2pi
        period = frequency == 0 ? .infinite : .finite(1/frequency)
    }

    public func value(for time: Double) -> Double {
        let progress = (argument(time)/_2pi).modulo(1)
        return progress < 0.5 ? 1 : -1
    }
}
