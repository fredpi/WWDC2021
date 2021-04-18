
import Helpers
import Model

public struct saw: Signal {
    private let argument: Argument
    public let maxAbsValue: Double = 1
    public let period: Period
    public var longDescription: String { "saw(\((argument - pi).description))" }

    public init(_ argument: Argument) {
        self.argument = argument + pi
        let frequency = abs((argument(1) - argument(0))) / _2pi
        period = frequency == 0 ? .infinite : .finite(1/frequency)
    }

    public func value(for time: Double) -> Double {
        let progress = (argument(time)/_2pi).modulo(1)
        return 2 * progress - 1
    }
}
