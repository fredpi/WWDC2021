
import Helpers
import Model

public struct triangle: Signal {
    private let argument: Argument
    public let maxAbsValue: Double = 1
    public let period: Period
    public var longDescription: String { "triangle(\((argument - pi/2).description))" }

    public init(_ argument: Argument) {
        self.argument = argument + pi/2
        let frequency = abs((argument(1) - argument(0))) / _2pi
        period = frequency == 0 ? .infinite : .finite(1/frequency)
    }

    public func value(for time: Double) -> Double {
        let progress = (argument(time)/_2pi).modulo(1)
        return progress < 0.5 ? 4 * progress - 1 : 3 - 4 * progress
    }
}
