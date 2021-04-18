//#-hidden-code

import Foundation
import PlaygroundSupport

var signal2: Signal = dummy()
var differenceSignal: Signal = dummy()

//#-end-hidden-code
/*:
 # 🤯 Summing Up Signals

 Here we're gonna do exactly what the title says: Summing up multiple signals to get a new signal, a so-called **sum signal**.

 Give the first sum signal a try by running the code. Also try the other signals by uncommenting their respective code line.
*/
var signal: Signal = 1 + sin(2*pi*t)
// signal = sin(2*pi*t) + cos(pi*t)
// signal = saw(4*pi*t) + rect(2*pi*t)
/*:
 **Weighted signal sums** are also possible. Try it out by uncommenting the following line of code:
*/
// signal = -1.5*sin(2*pi*t) + 3*cos(pi*t)
/*:
 ### 🔎 An interesting observation
 Try out the following **weighted sum signal** by uncommenting the line of code:
*/
// signal = 0.81057*sin(2*pi*t) - 0.09006*sin(6*pi*t) + 0.03242*sin(10*pi*t) - 0.02252*sin(14*pi*t)
/*:
 It looks astonishingly similar to the **triangle signal**, right? To compare it with the original triangle signal, uncomment the following two lines of code!
*/
// signal2 = triangle(2*pi*t)
// differenceSignal = signal2 - signal
/*:
 This observation is no coincidence, and [on the next page](@next) you're going to understand why!
 */
//#-hidden-code

let vc = SignalViewController(signal2, signal, differenceSignal)
PlaygroundPage.current.liveView = vc
vc.start()

//#-end-hidden-code
