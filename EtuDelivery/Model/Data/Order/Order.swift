//
// Created by Евгений Доленко on 15.01.2020.
// Copyright (c) 2020 Евгений Доленко. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Order: Object, Codable {
    @objc dynamic var id: String = ""
    @objc dynamic var from: GeoPoint? = nil
    @objc dynamic var to: GeoPoint? = nil
    @objc dynamic var cost: Int = 0
    @objc dynamic var _status: String = "new"
    let trackpoints = List<Trackpoint>()

    @objc dynamic var lastPoint: GeoPoint? = nil

    override static func primaryKey() -> String? {
        return "id"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case from
        case to
        case cost
        case _status = "status"
        case trackpoints
    }

    var status: OrderStatus {
        return OrderStatus(rawValue: _status)!
    }

    static func ==(lhs: Order, rhs: Order) -> Bool { return lhs.id == rhs.id }


    required init() {
        super.init()
    }

    required init(realm: RLMRealm, schema: RLMObjectSchema) { super.init(realm: realm, schema: schema) }

    required init(value: Any, schema: RLMSchema) { super.init(value: value, schema: schema) }

    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        from = try container.decodeIfPresent(GeoPoint.self, forKey: .from)
        to = try container.decodeIfPresent(GeoPoint.self, forKey: .to)
        cost = try container.decode(Int.self, forKey: .cost)
        _status = try container.decode(String.self, forKey: ._status)

        let trackpointsArray: [Trackpoint] = try container.decodeIfPresent([Trackpoint].self, forKey: .trackpoints) ?? []
        trackpoints.append(objectsIn: trackpointsArray)
    }
}

// MARK: - From
class GeoPoint: Object, Codable {
    @objc dynamic var address: String? = nil
    @objc dynamic var lat: Double = 0
    @objc dynamic var lng: Double = 0
}

// MARK: - Trackpoint
class Trackpoint: Object, Codable {
    @objc dynamic var id: String
    @objc dynamic var point: GeoPoint? = nil
    @objc dynamic var comment: String? = nil
    @objc dynamic var status: String = ""
    @objc dynamic var createdAt: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
