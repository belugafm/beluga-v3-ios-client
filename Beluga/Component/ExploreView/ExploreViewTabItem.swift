import SwiftUI
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct ExploreViewTabItem: View {
    let tabItem: ExploreViewTabItemType
    let text: String
    @Binding var selected: ExploreViewTabItemType
    var body: some View {
        VStack {
            Text(self.text)
                .font(.system(size: 16, weight: selected == tabItem ? .bold : .regular))
                .onTapGesture {
                    selected = tabItem
                }

            Image(uiImage: UIImage())
                .frame(width: 20, height: 2)
                .background(selected == tabItem ? .white : .black)
                .cornerRadius(2, corners: [.topLeft, .topRight])
        }
    }
}

struct ExploreViewTabItem_Previews: PreviewProvider {
    static var previews: some View {
        ExploreViewTabItem(tabItem: .topic, text: "チャンネル", selected: .constant(.topic))
    }
}
