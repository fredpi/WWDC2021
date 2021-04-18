
import Model

internal typealias const = Double

extension Double: Signal {
    public var period: Period { .infinite }
    public var maxAbsValue: Double { abs(self) }
    public var longDescription: String { asString() }
    public func value(for time: Double) -> Double { self }
}
