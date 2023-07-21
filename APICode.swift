//  Created by Ahmed H Lulu on 21/07/2023.
//

import Foundation

class APIManager {
    
    static let shared = APIManager()
    let baseUrl = "URL"
    
    init(){}
    
    func fetchData<T: Codable>(for: T.Type, from: String, body:[String:String] = [:], method: String = "POST") async throws -> T {
        guard let url = URL(string: "\(baseUrl)/\(from)") else {throw APIError.invalidURL}
        let token = getUserToken()
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("ar", forHTTPHeaderField: "x-localization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {throw APIError.serverError }
        guard let dataDecoded = try? JSONDecoder().decode(T.self, from: data) else {throw APIError.invalidData}
        return dataDecoded
    }
    
}

struct ResponseData<T:Codable> : Codable  {
    var status: Int
    var show: Bool
    var message: String
    var data: T?
}

struct Response: Codable {
    var slug:String
}
