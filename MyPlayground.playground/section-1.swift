// Playground - noun: a place where people can play

import UIKit

let padawans = ["Knox", "Avitla", "Mennaus"]
let fdf = 435

padawans.map({
    (padawan: String) -> String in
    "\(padawan)"
})


let pads = padawans.map({
    (padawan: String) -> String in
    "\(padawan) has been trained!"
})

println(pads)


func tralala(number: Int, closure: () -> Int) {
     closure()
}








func measure(title: String!, call: () -> Void) {
    let startTime = CACurrentMediaTime()
    call()
    let endTime = CACurrentMediaTime()
    if let title = title {
        print("\(title): ")
    }
    println("Time - \(endTime - startTime)")
}


measure("Array") {
    var ar = [String]()
    for i in 0...100 {
        ar.append("New elem \(i)")
    }
}


