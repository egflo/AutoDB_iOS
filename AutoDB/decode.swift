//
//  Decode.swift
//  AutoDB
//
//

import Foundation
import JWTDecode


@MainActor
class Meta: ObservableObject {
    @Published var query = "all"
    @Published var params = [URLQueryItem]()
    
    @Published var isAuthenticated = false
    @Published var user: User?
}


// MARK: - User

struct User {
    let id: String
    let name: String
    let email: String
    let emailVerified: String
    let picture: String
    let updatedAt: String
}

extension User {
    init?(from idToken: String) {
        guard let jwt = try? decode(jwt: idToken),
              let id = jwt.subject,
              let name = jwt["name"].string,
              let email = jwt["email"].string,
              let emailVerified = jwt["email_verified"].boolean,
              let picture = jwt["picture"].string,
              let updatedAt = jwt["updated_at"].string else {
            return nil
        }
        self.id = id
        self.name = name
        self.email = email
        self.emailVerified = String(describing: emailVerified)
        self.picture = picture
        self.updatedAt = updatedAt
    }
}

// MARK: - Bookmark



struct BookmarkWithAuto: Codable, Equatable {
    let auto: Auto
    let bookmark: Bookmark
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bookmark.id)
    }
    
    static func ==(lhs: BookmarkWithAuto, rhs: BookmarkWithAuto) -> Bool {
        return lhs.bookmark.id == rhs.bookmark.id
    }
    
    static func < (lhs: BookmarkWithAuto, rhs: BookmarkWithAuto) -> Bool {
        return lhs.bookmark.id < rhs.bookmark.id
    }
    
}

struct Bookmark: Codable, Identifiable, Equatable {
    let id: Int
    let userId: String
    let autoId: Int
    let created: String
    let auto: Auto?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Bookmark, rhs: Bookmark) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Bookmark, rhs: Bookmark) -> Bool {
        return lhs.id < rhs.id
    }
}



// MARK: - Auto
struct Auto: Codable, Equatable, Hashable, Identifiable, Comparable {
    let id: Int
    let body: Body
    let cityMpg: Int
    let description: String
    let engine: Engine
    let exteriorColor: String
    let fleet: Bool
    let report: Report
    let dealer: Dealer?
    let fuelTankVolume: String
    let fuel: Fuel
    let highwayMpg, horsepower: Int
    let interiorColor: String
    let isCab, isCpo, isNew, isOemcpo: Bool
    let color: Color
    let listingID: String
    let mainPictureURL: String
    let make: Make
    let seating, mileage: Int
    let model: Model
    let power: String
    let price: Double
    let torque: String
    let transmission: Transmission
    let trim: Trim
    let drivetrain: Drivetrain
    let year: Int
    let images: [AutoImage]
    let options: [Option]

    enum CodingKeys: String, CodingKey {
        case id, body, cityMpg
        case description = "description"
        case engine, exteriorColor, fleet, report, dealer, fuelTankVolume, fuel, highwayMpg, horsepower, interiorColor, isCab, isCpo, isNew, isOemcpo, color
        case listingID = "listingId"
        case mainPictureURL = "mainPictureUrl"
        case make, seating, mileage, model, power, price, torque, transmission, trim, drivetrain, year, images, options
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Auto, rhs: Auto) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Auto, rhs: Auto) -> Bool {
        return lhs.id < rhs.id
    }
    
}

// MARK: - Body
struct Body: Codable {
    let id: Int
    let bodyType: BodyType
    let length, width, height, wheelbase: String
    let frontLegroom, backLegroom, bedLength, cabin: String
}

// MARK: - Fuel
struct Fuel: Codable {
    let id: Int
    let type: String
}

// MARK: - BodyType
struct BodyType: Codable {
    let id: Int
    let type: String
}

// MARK: - Make
struct Make: Codable {
    let id: Int
    let name: String
}


// MARK: - Color
struct Color: Codable {
    let id: Int
    let name: String
}

// MARK: - Dealer
struct Dealer: Codable {
    let id: Int
    let longitude, latitude: Double
    let postcode, name: String
    let spID: Int
    let rating: Double
    let city: String
    let franchiseDealer: Bool
    let franchiseMake: String

    enum CodingKeys: String, CodingKey {
        case id, longitude, latitude, postcode, name
        case spID = "spId"
        case rating, city, franchiseDealer, franchiseMake
    }
}

// MARK: - Drivetrain
struct Drivetrain: Codable {
    let id: Int
    let name, description: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case description = "description"
    }
}

// MARK: - Engine
struct Engine: Codable {
    let id, cylinders, displacement: Int
    let type, power, torque, horsepower: String
}

// MARK: - Image
struct AutoImage: Codable, Hashable {
    let id, autoID: Int
    let url: String

    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case autoID = "autoId"
        case url
    }
}

// MARK: - Model
struct Model: Codable {
    let id: Int
    let make: Color
    let name: String
}

// MARK: - Option
struct Option: Codable {
    let id: Int
    let description: String

    enum CodingKeys: String, CodingKey {
        case id
        case description = "description"
    }
}

// MARK: - Report
struct Report: Codable {
    let id: Int
    let vin: String
    let frameDamage, hasAccidents, theftTitle: Bool
    let ownerCount: Int
    let salvage: Bool
}

// MARK: - Transmission
struct Transmission: Codable {
    let id: Int
    let type, description: String

    enum CodingKeys: String, CodingKey {
        case id, type
        case description = "description"
    }
}

// MARK: - Trim
struct Trim: Codable {
    let id, trimDescription: String

    enum CodingKeys: String, CodingKey {
        case id
        case trimDescription = "description"
    }
}



// MARK: - Pagab;e


struct Response<T: Codable>: Codable {
    var content: [T]
    var pageable: Pagable
    var totalPages: Int
    var totalElements: Int
    var last: Bool
    var size: Int
    var number: Int
    var sort: Sort
    var numberOfElements: Int
    var first: Bool
    var empty: Bool
}


struct Pagable:Codable {
    var sort: Sort
    var offset: Int
    var pageNumber: Int
    var pageSize: Int
    var paged: Bool
    var unpaged: Bool
}

struct Sort:Codable {
    var unsorted: Bool
    var sorted: Bool
    var empty: Bool
}
