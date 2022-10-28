import SwiftUI

struct ContentView: View {
    @State var timelineModel: TimelineModel
    var body: some View {
        VStack {
            Button("Button")
            {
                timelineModel.fetchMessages()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(timelineModel: TimelineModel())
    }
}
