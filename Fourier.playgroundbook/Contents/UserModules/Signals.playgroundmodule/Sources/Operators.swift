
import Model

// Allows signal summation & subtraction
public func +(lhs: Signal, rhs: Signal) -> Signal { sum(lhs, rhs) }
public func -(lhs: Signal, rhs: Signal) -> Signal { sum(lhs, product(-1, rhs)) }

// Allows signal additive inversion
public prefix func -(rhs: Signal) -> Signal { product(-1, rhs) }

// Allows signal scaling
public func *(lhs: Double, rhs: Signal) -> Signal { product(lhs, rhs) }
public func *(lhs: Signal, rhs: Double) -> Signal { product(lhs, rhs) }

// Allow division of signal by const (Double) signal
public func /(lhs: Signal, rhs: Double) -> Signal { lhs * (1/rhs) }
