import Foundation

class TimelineModel: ObservableObject {
    func fetchMessages(resolve: @escaping ([Message]) -> Void){
        guard let url = URL(string: "https://beluga.fm/api/v1/timeline/channel_debug?channel_id=2") else { return }
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
                print("Loaded", messages.count, "messages")
                resolve(messages.reversed())
            } catch {
                print("Error", error)
            }
        }.resume()
    }
}

