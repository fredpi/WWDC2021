
import Foundation
import Helpers

public struct Argument {
    fileprivate let factor: Double
    fileprivate let phase: Double
    public let description: String

    fileprivate init(factor: Double = 1, phase: Double = 0) {
        self.factor = factor
        self.phase = phase

        let factorThroughPi = factor / pi
        let factorDescription: String = factorThroughPi.isRational ? "\(factorThroughPi.asString().emptyIf1AndOnlyMinusIfMinus1)𝜋" : factor.asString().emptyIf1AndOnlyMinusIfMinus1
        let phaseThroughPi = phase / pi
        let phaseDescription: String = phaseThroughPi.isRational ? "\(phaseThroughPi.asString().emptyIf1AndOnlyMinusIfMinus1)𝜋" : phase.asString().emptyIf1AndOnlyMinusIfMinus1
        description = phase == 0 ? "\(factorDescription)t" : "\(factorDescription)t\(phaseDescription.first == "-" ? "": "+")\(phaseDescription)"
    }

    public func callAsFunction(_ time: Double) -> Double { factor * time + phase }
}

// The constant always needed to construct any Argument
public let t = Argument()

let argument = 2*t
let bla = argument(1)

// Allows sin(2*pi*t) syntax f. i.
public func *(lhs: Double, rhs: Argument) -> Argument { .init(factor: lhs * rhs.factor, phase: lhs * rhs.phase) }
public func *(lhs: Argument, rhs: Double) -> Argument { rhs * lhs }

// Allows sin(t/2) syntax f. i.
public func /(lhs: Argument, rhs: Double) -> Argument { (1/rhs) * lhs }

// Allows sin(2*pi*t+pi) syntax f. i.
public func +(lhs: Double, rhs: Argument) -> Argument { .init(factor: rhs.factor, phase: rhs.phase + lhs) }
public func +(lhs: Argument, rhs: Double) -> Argument { rhs + lhs }
public func -(lhs: Double, rhs: Argument) -> Argument { -rhs + lhs }
public func -(lhs: Argument, rhs: Double) -> Argument { -rhs + lhs }

// Allows sin(-(2*pi*t)) syntax
public prefix func -(rhs: Argument) -> Argument { .init(factor: -rhs.factor, phase: -rhs.phase) }
