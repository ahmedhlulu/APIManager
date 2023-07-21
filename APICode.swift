//  Created by Ahmed H Lulu on 21/07/2023.
//

import Foundation

class APIManager {
    
    static let shared = APIManager()
    let baseUrl = "BASE_URL"
    
    init(){}
    
    func fetchData<T: Codable>(for: T.Type, from: ResponseURL, body:[String:String] = [:], method: String = "GET") async throws -> T {
        guard let url = URL(string: "\(baseUrl)/\(from.rawValue)") else {throw APIError.invalidURL}
        let token = "USER_TOKEN"
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
    var id: String
    var firstName: String
    var lastName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

enum ResponseURL: String {
    case nameList = "name-list"
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case serverError
    case invalidData
    case unkown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL was invalid, please try again later."
        case .serverError: return "There was an error with the server. Please try again later"
        case .invalidData: return "The data is invalid. Please try again later"
        case .unkown(let error) :
            return error.localizedDescription
        }
    }
}

// How use it!
let apiData = try await APIManager.shared.fetchData(for: ResponseData<[Response]>.self, from: .nameList)
