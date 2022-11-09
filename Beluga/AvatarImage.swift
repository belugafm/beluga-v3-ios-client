import SwiftUI

struct AvatarImage: View {
    let url: String?
    let id: Int?
    let width: CGFloat
    let height: CGFloat
    var body: some View {
        if self.url != nil {
            Image(uiImage: UIImage())
                .frame(width: self.width, height: self.height)
                .clipShape(SuperEllipseShape(rate: 0.75))
        } else if self.id != nil {
            Image(uiImage: UIImage())
                .frame(width: self.width, height: self.height)
                .background(Color(uiColor: randomColor(seed: self.id!)))
                .clipShape(SuperEllipseShape(rate: 0.75))
        }
    }
}

struct AvatarImage_Previews: PreviewProvider {
    static var previews: some View {
        AvatarImage(url: nil, id: 1, width: 40, height: 40)
    }
}
