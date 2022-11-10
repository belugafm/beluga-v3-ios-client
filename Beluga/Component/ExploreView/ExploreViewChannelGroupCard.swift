import SwiftUI

struct ExploreViewChannelGroupCard: View {
    var channelGroup: ChannelGroup
    var body: some View {
        VStack {
            HStack {
                AvatarImage(url: channelGroup.image_url, id: channelGroup.id, width: 60, height: 60)
                VStack {
                    Text(channelGroup.name)
                        .font(.system(size: 20))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Text("投稿数").font(.system(size: 14))
                        Text(String(channelGroup.message_count)).font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            if channelGroup.description != nil {
                Text(channelGroup.description!)
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .lineLimit(3)
                    .padding(.vertical, 10)
            }
        }
        .padding(10)
    }
}

struct ExploreViewChannelGroupCard_Previews: PreviewProvider {
    static var previews: some View {
        let channelGroup = ChannelGroup(id: 2, name: "グループ名", unique_name: "channel_group", description: "説明", parent_id: 0, message_count: 1, image_url: nil)
        ExploreViewChannelGroupCard(channelGroup: channelGroup)
    }
}
