//
// Created by Евгений Доленко on 30.11.2019.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import MessageKit

class Message: Codable, MessageType {
    var id: String = ""
    var domainID: String? = ""
    var courierID: String = ""
    var managerID: String = ""
    var senderID: String = ""
    var orderID: String = ""

    var senderName: String = ""
    var senderSurname: String = ""
    var message: String? = ""
    var attach: String? = nil
    var attachExtension: String? = nil
    var read: Int? = 0
    var createdAt: String = ""
    var timestampCreated: String = ""

    init() {

    }

    init?(map: [String: Any]) {
        guard let messageId = map["id"] as? Int else { return }
        guard let managerId = map["manager_id"] as? Int else { return }
        guard let senderId = map["sender_id"] as? Int else { return }
        guard let orderId = map["order_id"] as? Int else { return }
        guard let courierId = map["courier_id"] as? Int else { return }
        guard let timestampCreated = map["timestamp_created"] as? Int else { return }

        guard let senderName = map["sender_name"] as? String else { return }
        guard let senderSurname = map["sender_surname"] as? String else { return }
        guard let createdAt = map["created_at"] as? String else { return }

        let attach = map["attach"] as? String
        let message = map["message"] as? String

        self.id = String(messageId)
        self.managerID = String(managerId)
        self.senderID = String(senderId)
        self.orderID = String(orderId)
        self.courierID = String(courierId)

        self.senderName = senderName
        self.senderSurname = senderSurname
        self.createdAt = createdAt
        self.timestampCreated = String(timestampCreated)
        self.message = message
        self.attach = attach
    }

    enum CodingKeys: String, CodingKey {
        case id
        case domainID = "domain_id"
        case courierID = "courier_id"
        case managerID = "manager_id"
        case senderID = "sender_id"
        case orderID = "order_id"
        case senderName = "sender_name"
        case senderSurname = "sender_surname"
        case message
        case attach
        case read
        case createdAt = "created_at"
        case timestampCreated = "timestamp_created"
        case attachExtension = "attach_extension"
    }

    var sender: SenderType {
        return Sender(senderId: String(senderID), displayName: senderName + " " + senderSurname)
    }
    var messageId: String {
        return id
    }
    var sentDate: Date {
        return Date(timeIntervalSince1970: Double(timestampCreated) ?? 0)
    }
    var kind: MessageKind {
        if let attach = attach, !attach.isEmpty {
            return MessageKind.photo(PhotoMediaItem(imageUrl: imageUrl))
        } else {
            return MessageKind.text(message ?? "")
        }
    }

    var imageUrl: URL? {
        let urlString = ApiService.destUrl(url: "file/get-file")
        var url = URL(string: urlString)
        url?.appendQueryParameters(["file": attach ?? ""])
        return url
    }

    class PhotoMediaItem: MediaItem {
        var image: UIImage? = nil
        var placeholderImage: UIImage = UIImage(named: "placeholder")!
        var size: CGSize = CGSize(width: 200, height: 200)

        let imageUrl: URL?

        init(imageUrl: URL?) { self.imageUrl = imageUrl }

        var url: URL? {
            return imageUrl
        }
    }
}
