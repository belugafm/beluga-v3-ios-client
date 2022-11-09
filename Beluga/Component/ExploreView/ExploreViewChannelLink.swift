import SwiftUI

struct ExploreViewChannelLink: View {
    var channel: Channel
    var body: some View {
        ZStack {
            HStack {
                Text(channel.status_string)
                    .font(.system(size: 20))
                    .bold()
                    .frame(width: 24)
                Text(channel.name)
                    .font(.system(size: 20))
                    .bold()
                Spacer()
            }
            .padding(.leading, 10)
            .padding(.trailing, 20)
            .padding(.vertical, 10)
        }
        .cornerRadius(10)
    }
}

struct ExploreViewChannelLink_Previews: PreviewProvider {
    static var previews: some View {
        let channel = Channel(id: 1, name: "チャンネル名", unique_name: "channel", message_count: 1, status_string: "#")
        ExploreViewChannelLink(channel: channel)
    }
}
