import SwiftUI

struct ExploreViewDescriptionView: View {
    let channelGroup: ChannelGroup

    init(channelGroup: ChannelGroup) {
        self.channelGroup = channelGroup
    }

    var body: some View {
        ScrollView {
            if let description = self.channelGroup.description {
                Text(description)
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(20)
            }
        }
    }
}

struct ExploreViewDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        let channelGroup = ChannelGroup(id: 1, name: "channel_group", unique_name: "チャンネルグループ", description: "チャンネルグループの説明", parent_id: 0, message_count: 199, image_url: nil)
        ExploreViewDescriptionView(channelGroup: channelGroup)
    }
}
