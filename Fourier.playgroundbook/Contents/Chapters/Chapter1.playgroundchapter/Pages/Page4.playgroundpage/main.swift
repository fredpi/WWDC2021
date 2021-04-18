//#-hidden-code

import Foundation
import PlaygroundSupport

//#-end-hidden-code
/*:
 # 💡 The Gibbs Phenomenon
 On this page, we use new coefficient formulas: this time trying to create a Fourier series **replicating the rect signal**.

 Run the code and see how the Fourier series evolves as more coefficients are taken into account each step.
*/
let baseFrequency: Double = 1
let equalPart: Double = 0
let cosCoefficientFormula: (Int) -> Double = { _ in 0 }
let sinCoefficientFormula: (Int) -> Double = { k in
    if k % 2 == 0 {
        // Even index
        return 0
    } else {
        // Odd index
        return 4/pi/Double(k)
    }
}
/*:
 As you can see, this signal cannot be exactly replicated via its Fourier series – **there's always an overshoot** at those places where the rect signal jumps from -1 to 1 or vice versa (*even if ∞ coefficients were to be taken into account*). And that's the **Gibbs Phenomenon**!

 This behavior means that an exact representation of periodic signals as a Fourier series is only possible **if the signal is continuous** which means that it doesn't suddenly jump from one point to another (as the rect signal does e. g.)

 - Note:
 [Wikipedia](https://en.wikipedia.org/wiki/Gibbs_phenomenon) has more information on the Gibbs phenomenon.
*/

/*:
 Now we're nearing the completion of this playground. [Go ahead to the final page](@next)!
 */
//#-hidden-code

let vc = SignalViewController(
    rect(2*pi*baseFrequency*t),
    evolvingSignal: { evolutionIndex -> Signal in
        fourier(
            equalPart: equalPart,
            baseAngularFrequency: 2*pi*baseFrequency,
            sinCoefficientFormula: sinCoefficientFormula,
            cosCoefficientFormula: cosCoefficientFormula,
            upToCoefficient: evolutionIndex
        )
    },
    maxCoefficient: 50
)
PlaygroundPage.current.liveView = vc
vc.start()

//#-end-hidden-code
