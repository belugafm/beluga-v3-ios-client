// https://blog.personal-factory.com/2021/01/30/how-to-create-clubhouse-super-ellipse-by-swiftui/
import Foundation
import GameplayKit
import SwiftUI

struct UInt64RandomNumberGenerator: RandomNumberGenerator {
    mutating func next() -> UInt64 {
        // GKRandom produces values in [INT32_MIN, INT32_MAX] range; hence we need two numbers to produce 64-bit value.
        let next1 = UInt64(bitPattern: Int64(gkrandom.nextInt()))
        let next2 = UInt64(bitPattern: Int64(gkrandom.nextInt()))
        return next1 ^ (next2 << 32)
    }

    init(seed: UInt64) {
        self.gkrandom = GKMersenneTwisterRandomSource(seed: seed)
    }

    private let gkrandom: GKRandom
}

func randomColor(seed: Int) -> UIColor {
    var generator = UInt64RandomNumberGenerator(seed: UInt64(seed))
    let hue = Float.random(in: 0 ... 1, using: &generator)
    return UIColor(hue: CGFloat(hue), saturation: 0.5, brightness: 1, alpha: 1)
}

struct SuperEllipseShape: Shape {
    let rate: CGFloat
    func path(in rect: CGRect) -> Path {
        let handleX: CGFloat = rect.size.width * rate / 2
        let handleY: CGFloat = rect.size.height * rate / 2

        let left = CGPoint(x: rect.minX, y: rect.midY)
        let top = CGPoint(x: rect.midX, y: rect.minY)
        let right = CGPoint(x: rect.maxX, y: rect.midY)
        let bottom = CGPoint(x: rect.midX, y: rect.maxY)

        var path = Path()

        path.move(to: left) //
        path.addCurve(to: top,
                      control1: CGPoint(x: left.x, y: left.y - handleY),
                      control2: CGPoint(x: top.x - handleX, y: top.y))

        path.addCurve(
            to: right,
            control1: CGPoint(x: top.x + handleX, y: top.y),
            control2: CGPoint(x: right.x, y: right.y - handleY)
        )
        path.addCurve(
            to: bottom,
            control1: CGPoint(x: right.x, y: right.y + handleY),
            control2: CGPoint(x: bottom.x + handleX, y: bottom.y)
        )
        path.addCurve(
            to: left,
            control1: CGPoint(x: bottom.x - handleX, y: bottom.y),
            control2: CGPoint(x: left.x, y: left.y + handleY)
        )

        return path
    }
}
