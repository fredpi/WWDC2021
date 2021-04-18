//#-hidden-code

import Foundation
import PlaygroundSupport

//#-end-hidden-code
/*:
 # 🏁 The End

 We have reached the final page and time is probably running out – hopefully you were able to gain some insights from this playground.

 **Just in case** that you are interested in trying out your own signals and fourier formulas: You can do so below! To give you some inspiration, there's a fourier approximation formula for the **saw signal** which you can just try out by running the code.
*/
let baseFrequency: Double = 1
let equalPart: Double = 0
let cosCoefficientFormula: (Int) -> Double = { _ in 0 }
let sinCoefficientFormula: (Int) -> Double = { k in
    2/pi/Double(k)*pow(-1, Double(k+1))
}

let vc = SignalViewController(
    saw(2*pi*baseFrequency*t),
    // sin(4*pi*t-pi/2), // To give you some inspiration
    // triangle(20*pi*t) + cos(2*pi*t), // To give you some inspiration
    evolvingSignal: { evolutionIndex -> Signal in // You can comment these lines out to get rid of the evolving signal
        fourier(
            equalPart: equalPart,
            baseAngularFrequency: 2*pi*baseFrequency,
            sinCoefficientFormula: sinCoefficientFormula,
            cosCoefficientFormula: cosCoefficientFormula,
            upToCoefficient: evolutionIndex
        )
    }, maxCoefficient: 50
)

//#-hidden-code
PlaygroundPage.current.liveView = vc
vc.start()
//#-end-hidden-code
