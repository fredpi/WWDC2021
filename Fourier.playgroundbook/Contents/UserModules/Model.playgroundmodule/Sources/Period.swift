
import Foundation

public enum Period: Equatable {
    case finite(Double)
    case infinite // For constant signals
    case unknown
}
