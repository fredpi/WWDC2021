
import Foundation
import UIKit

public extension String {
    var emptyIf1AndOnlyMinusIfMinus1: String { self == "1" ? "" : self == "-1" ? "-" : self }
}

public extension CALayer {
    func disableAnimations() {
        actions = [
            "onOrderIn": NSNull(),
            "onOrderOut": NSNull(),
            "sublayers": NSNull(),
            "contents": NSNull(),
            "bounds": NSNull(),
            "position": NSNull(),
            "transform": NSNull()
        ]
    }
}

public extension Int {
    func gcd(with other: Int) -> Int {
        var (a, b) = (self, other)
        while b != 0 { (a, b) = (b, a % b) }
        return abs(a)
    }

    func lcm(with other: Int) -> Int {
        (self / gcd(with: other)) * other
    }

    static func gcd(_ values: [Int]) -> Int {
        values.reduce(0) { $0.gcd(with: $1) }
    }

    static func gcd(_ values: Int...) -> Int {
        gcd(values)
    }

    static func lcm(_ values: [Int]) -> Int {
        values.reduce(1) { $0.lcm(with: $1) }
    }

    static func lcm(_ values: Int...) -> Int {
        lcm(values)
    }
}

public extension Double {
    private struct Rational {
        let num: Int
        let den: Int

        var asDouble: Double { Double(num) / Double(den) }

        init(double: Double, precision eps: Double = 1.0e-6) {
            var x = double
            var a = floor(x)
            var (h1, k1, h, k) = (1, 0, Int(a), 1)

            while x - a > eps * Double(k) * Double(k) {
                x = 1.0/(x - a)
                a = floor(x)
                (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
            }

            num = h
            den = k
        }
    }

    /// Better modulo: [0, modulus) instead of (-modulus, modulus)
    func modulo(_ modulus: Double) -> Double {
        let value = truncatingRemainder(dividingBy: modulus)
        return value < 0 ? value + modulus : value
    }

    var sign: Double { self >= 0 ? 1 : -1 }

    /// Tells whether Double is rational when using an eps of 1.0e-6
    var isRational: Bool { self == Rational(double: self, precision: 1.0e-6).asDouble }

    func asString(roundedTo decimalPlace: Int = 2, strippingTrailingZeros stripTrailingZeros: Bool = true, avoidZeroForNonZeros: Bool = true) -> String {
        let decimalPlace = Double(max(0, decimalPlace))
        let factor = pow(10, decimalPlace)
        let rounded = Foundation.round(self*factor)/factor
        if avoidZeroForNonZeros && rounded == 0 && self != 0 {
            return String(sign*pow(10, -decimalPlace))
        } else {
            let string = String(rounded)
            return stripTrailingZeros ? String(string.reversed().drop { $0 == "0" }.drop { $0 == "." }.reversed()) : string
        }
    }

    func gcd(with other: Double) -> Double { Double.gcd(self, other) }
    func lcm(with other: Double) -> Double { Double.lcm(self, other) }

    static func lcm(_ values: [Double]) -> Double {
        let rationals = values.map { Rational(double: $0) }
        return Double(Int.lcm(rationals.map(\.num)))/Double(Int.gcd(rationals.map(\.den)))
    }

    static func lcm(_ values: Double...) -> Double { lcm(values) }

    static func gcd(_ values: [Double]) -> Double {
        let rationals = values.map { Rational(double: $0) }
        return Double(Int.gcd(rationals.map(\.num)))/Double(Int.lcm(rationals.map(\.den)))
    }

    static func gcd(_ values: Double...) -> Double { gcd(values) }
}
