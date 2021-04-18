
import Foundation

public protocol Signal: CustomDebugStringConvertible {
    var period: Period { get }
    var maxAbsValue: Double { get }
    var longDescription: String { get }
    var shortDescription: String { get }
    
    func value(for time: Double) -> Double
}

public extension Signal {
    var shortDescription: String { longDescription }
    var debugDescription: String { longDescription }
}
