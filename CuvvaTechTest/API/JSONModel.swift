import Foundation

// MARK: JSONDecoder config

let apiJsonDecoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()

    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    
    return jsonDecoder
}()

// MARK: JSON Response Decodable

typealias JSONResponse = [JSONEvent]

enum EventType: String, Decodable {
    case unknown
    case created
    case extended
    case cancelled
    
    init(from decoder: Decoder) throws {
        let label = try decoder.singleValueContainer().decode(String.self)
        switch label {
        case "policy_created": self = .created
        case "policy_extension": self = .extended
        case "policy_cancelled": self = .cancelled
        default: self = .unknown
        }
    }
}

struct JSONEvent: Decodable, Identifiable {
    // Chebotov. It would be nice to get an id from the server
    let id: String = UUID().uuidString

    let type: EventType
    let payload: JSONPayload
    
    enum CodingKeys: String, CodingKey {
        case type
        case payload
    }
}

// Chebotov. It would be nice to handle non-existing parameters in a more elegant way
struct JSONPayload: Decodable {
    let policyId: String
    let vehicle: JSONVehicle?
    let timestamp: Date
    let startDate: Date?
    let endDate: Date?
}

// Chebotov. It would be useful to get an id from the server. Can't use UUID here since the same vehicle can be recieved multiple times.
struct JSONVehicle: Decodable {
    let prettyVrm: String
    let make: String
    let model: String
}
