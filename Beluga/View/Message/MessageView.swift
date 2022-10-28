import SwiftUI

struct MessageView: View {
    let viewModel: MessageViewModel
    var body: some View {
        VStack {
            HStack {
                if let userDisplayName = self.viewModel.message.user?.display_name {
                    Text(userDisplayName)
                }
                if let userName = self.viewModel.message.user?.name {
                    Text("@" + userName)
                }
            }
            Text(self.viewModel.message.text).padding(5)
        }
    }
}
