import SwiftUI

struct ExploreViewChannelGroupLink: View {
    var channelGroup: ChannelGroup
    var body: some View {
        ZStack {
            MyColor.chevlonMenuBgColor
            HStack {
                Image(uiImage: UIImage())
                    .frame(width: 40, height: 40)
                    .background(Color.yellow)
                    .clipShape(SuperEllipseShape(rate: 0.75))
                VStack {
                    HStack {
                        Text(channelGroup.name).font(.system(size: 20)).bold()
                        Spacer()
                    }
                    if channelGroup.description != nil {
                        Text(channelGroup.description!)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                Image(systemName: "chevron.right")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .cornerRadius(10)
    }
}

struct ExploreViewChannelGroupLink_Previews: PreviewProvider {
    static var previews: some View {
        let channelGroup = ChannelGroup(id: 1, name: "グループ名", unique_name: "channel_group", description: "説明", parent_id: 0, message_count: 1)
        ExploreViewChannelGroupLink(channelGroup: channelGroup)
    }
}
