// https://blog.personal-factory.com/2021/01/30/how-to-create-clubhouse-super-ellipse-by-swiftui/
import Foundation
import SwiftUI

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
