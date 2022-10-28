import SwiftUI

@main
struct BelugaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(timelineModel: TimelineModel())
        }
    }
}