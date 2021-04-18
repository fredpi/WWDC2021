//#-hidden-code

import Foundation
import PlaygroundSupport

//#-end-hidden-code
/*:
 # 🤖 Welcome!
 Welcome to this playground! Within 5 steps it will show you the beauty of the **fourier series**.

 ## 🔉 What's a signal?
 To understand what a fourier series is, it's good to first understand what a signal is. In this playground, we'll just use the following definition: **A signal is a function that assigns a value to each point in time**.

 Here, we don't care what that value means physically, we just look at it from a **mathematical perspective**. But if it helps, you can think of sound as a signal: For each point in time, there is a specific sound pressure.

 The simplest signal one could think of is a **constant signal**: It just assigns the exact same value to each point in time. Run the code to see how it looks like.
*/
var signal: Signal = 1
/*:
 Apart from the constant signal, all other signals we are talking about here are **periodic signals**. Periodic signals repeat themselves after some time: the so called **period duration T**. The inverse of the period duration is called the **frequency f** = 1/T. You can think of the frequency as the number of signal repetitions within a second's time.

 The (arguably) most important periodic signal is the so called **sinus signal**. To see how it looks like, uncomment the line where it gets set and run the code.

 - Note:
 If you want to get a better understanding of the influence of the **frequency f**, you may also try and change that value to something else (e. g. 0.5 or 2).
*/
let f: Double = 1 // The frequency
// signal = sin(2*pi*f*t)
/*:
 And then, there are many more **basic signals**, that you can try out by uncommenting the corresponding lines in the code and then running the code:
 * The cosinus signal
 * The rectangle signal
 * The triangle signal
 * The saw signal

 - Note:
 This is just for you to try, you **don't have to remember** how every signal looks like exactly.
*/
// signal = cos(2*pi*f*t)
// signal = rect(2*pi*f*t)
// signal = saw(2*pi*f*t)
// signal = triangle(2*pi*f*t)
/*:
 When you're done, [let's go to the next step](@next) where we sum up signals!
 */
//#-hidden-code

let vc = SignalViewController(signal)
PlaygroundPage.current.liveView = vc
vc.start()

//#-end-hidden-code
