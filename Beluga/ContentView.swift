import SwiftUI

struct ContentView: View {
    @State var timelineModel: TimelineModel
    var body: some View {
        VStack {
            TimelineView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(timelineModel: TimelineModel())
    }
}
