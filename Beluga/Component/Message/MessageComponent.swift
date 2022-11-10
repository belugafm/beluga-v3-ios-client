import SwiftUI

struct MessageComponent: View {
    @State var viewModel: MessageViewModel
    @ObservedObject var message: ObservableMessage
    var body: some View {
        HStack {
            VStack {
                if self.message.consecutive == false {
                    AvatarImage(url: viewModel.message.user?.profile_image_url, id: viewModel.message.user_id, width: 50, height: 50)
                    Spacer()
                }
            }.frame(width: 50, height: 50)

            VStack {
                HStack {
                    if let userDisplayName = self.viewModel.message.user?.display_name {
                        Text(userDisplayName).bold().font(.system(size: 16))
                    }
                    if let userName = self.viewModel.message.user?.name {
                        Text("@" + userName).font(.system(size: 16))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                Text(self.viewModel.message.text)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .font(.system(size: 20))
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct MessageComponent_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthRequest = OAuthRequest(credential: OAuthCredential())
        let message = ObservableMessage(id: 1, channel_id: 1, channel: nil, user_id: 1, user: User(id: 1, name: "user_name", display_name: "ユーザー名", profile_image_url: nil), text: "メッセージの本文です", created_at: "1000000000", favorite_count: 1, favorited: false, like_count: 1, reply_count: 0, thread_id: nil, deleted: false, entities: MessageEntities(channels: [], channel_groups: [], messages: [], files: [], urls: [], favorited_users: [], style: []), consecutive: true)
        let viewModel = MessageViewModel(message: message, oAuthRequest: oAuthRequest)
        MessageComponent(viewModel: viewModel, message: message)
    }
}
