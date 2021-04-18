//#-hidden-code

import Foundation
import PlaygroundSupport

//#-end-hidden-code
/*:
 # 🎛 The Fourier Series

 Apart from one category of exceptions (more about that on the next page), **every arbitrary periodic signal** with frequency f can be represented as a weighted sum of ∞ sinus and cosinus signals of multiples of the **frequency f** (a so-called **Fourier series**). The cool thing about that: There's even a formula to calculate the weights (the so-called *coefficients*) for every periodic signal we want to represent like that.

 - Note:
 If you want to learn more about Fourier series, head over to [Wikipedia](https://en.wikipedia.org/wiki/Fourier_series). The process to obtain the coefficient calculation formula for an arbitrary signal is beyond the scope of this introductory playground.

 You get the idea right? As soon as we obtained the formula to calculate the *coefficients*, we're done and can represent our signal as follows:

 *signal = a_0 + a_1•cos(1•2•pi•f•t) + b_1•sin(1•2•pi•f•t) + a_2•cos(2•2•pi•f•t) + b_2•sin(2•2•pi•f•t) + a_3•cos(3•2•pi•f•t) + b_3•sin(3•2•pi•f•t) + ... until ∞*

 - Note:
 We refer to a_0 as the **equal part**, a_k as the **cos coefficients**, and b_k as the **sin coefficients**.

 Run the code which contains the formulas for the equal part, the cos coefficients and the sin coefficients to replicate the triangle signal from the last step. Of course we **cannot factor in ∞ coefficients**, but you will see how the replication gets *better* as more coefficients are taken into account.
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
        return 8/pi/pi/Double(k)/Double(k)*pow(-1.0, Double((k-1)/2))
    }
}
/*:
 There's just one little problem with the Fourier series and we'll get to know it [on the next page](@next)!
 */

//#-hidden-code

let vc = SignalViewController(
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
