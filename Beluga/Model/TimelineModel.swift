import Foundation

class TimelineModel: ObservableObject {
    @Published var messages = [Message]()
    func fetchMessages(){
        guard let url = URL(string: "https://beluga.fm/api/v1/timeline/channel?channel_id=2") else { return }
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                guard let responseData = data else {
                    return
                }
                let decodedData = try JSONDecoder().decode(TimelineChannelJsonResponse.self, from: responseData)
                guard let messages = decodedData.messages else {
                    print("Failed to load messages")
                    return
                }
                self.messages = messages
                print("Loaded", self.messages.count, "messages")
                
            } catch {
                print("Error", error)
            }
        }.resume()
    }
}

