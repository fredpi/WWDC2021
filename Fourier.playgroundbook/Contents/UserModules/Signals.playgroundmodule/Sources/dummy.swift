
import Foundation
import Model

/// A dummy signal that gets filtered out when passed to the SignalViewController
public struct dummy: Signal {
    public var period: Period = .infinite
    public var maxAbsValue: Double = 0
    public var longDescription: String = ""
    public func value(for time: Double) -> Double { 0 }

    public init() { }
}
