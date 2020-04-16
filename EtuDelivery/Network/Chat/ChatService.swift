//
// Created by Евгений Доленко on 2019-05-04.
// Copyright (c) 2019 Евгений Доленко. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import Alamofire

class ChatService: ApiService {
    func getChatMessages(orderId: Int) -> Observable<[Message]> {
        let headers = ["Uid": AppDelegate.model.auth.uid, "Auth-key": AppDelegate.model.auth.authToken]

        return get("chat/get-messages", queryParams: ["order_id": String(orderId)], headers: headers)
                .map { $0.0 }
                .flatMap { data -> Observable<[Message]> in
                    if let response: [Message] = self.parseJSON(data) {
                        return Observable.just(response)
                    } else {
                        return Observable.error(RuntimeError("unknown_error".localized()))
                    }
                }
    }

    func sendMessage(orderId: Int, managerId: Int, message: String?, attach: String?, attachExt: String?) -> Observable<SimpleResponse> {
        let headers = ["Uid": AppDelegate.model.auth.uid, "Auth-key": AppDelegate.model.auth.authToken]
        let request = SendMessageRequest(order_id: orderId, chat_message: message, manager_id: managerId, attach: attach, attach_extension: attachExt)

        return post("chat/send-message", json: request, headers: headers)
                .map { $0.0 }
                .flatMap { data -> Observable<SimpleResponse> in
                    if let response: SimpleResponse = self.parseJSON(data) {
                        return Observable.just(response)
                    } else {
                        return Observable.error(RuntimeError("unknown_error".localized()))
                    }
                }
    }

    func sendImageMessage(orderId: Int, managerId: Int, image: Data, closure: @escaping () -> Void) {
        let fileName = UUID().uuidString + ".jpeg"
        let mimeType = "image/*"

        let headers = ["Uid": AppDelegate.model.auth.uid, "Auth-key": AppDelegate.model.auth.authToken]
        Alamofire.upload(
                multipartFormData: {
                    multipartFormData in
                    multipartFormData.append(image, withName: "file", fileName: fileName, mimeType: mimeType)

                    //let fakeData = "file".data(using: .utf8) ?? Data()
                    //multipartFormData.append(fakeData, withName: "file", mimeType: "text/plain")
                },
                to: ApiService.destUrl(url: "chat/upload-file"),
                method: .post,
                headers: headers,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.response { [unowned self] response in
                            if let error = response.error {
                                closure()
                                return
                            }
                            guard (response.response?.statusCode) != nil else {
                                closure()
                                return
                            }
                            guard let data = response.data else {
                                closure()
                                return
                            }

                            if let response: FileUploadResponse = self.parseJSON(data) {
                                self.sendMessage(orderId: orderId, managerId: managerId, message: nil, attach: response.file_link, attachExt: nil)
                                        .observeOn(MainScheduler.instance)
                                        .subscribe(onNext: { [weak self]  response in
                                            closure()
                                        }, onError: { [weak self] error in
                                            closure()
                                        })
                            } else {
                                closure()
                            }
                        }

                    case .failure:
                        print("upload error")
                        closure()
                    }
                })
    }
}
