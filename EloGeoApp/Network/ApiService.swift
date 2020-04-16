//
// Created by Евгений Доленко on 15.06.2018.
// Copyright (c) 2018 Евгений Доленко All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift
import os.log

class ApiService {
    lazy private var jsonDecoder: JSONDecoder = {
        return JSONDecoder()
    }()

    lazy private var jsonEncoder: JSONEncoder = {
        return JSONEncoder()
    }()

    // Обертка для вызова всех запросов к серверу - выполняется базовую обработку всех общих ошибок
    private func _call(_ req: URLRequest) -> Observable<(Data, HTTPURLResponse)> {
        return RxAlamofire
                .request(req)
                .do(onNext: { req in
                    req.debugLog()
                })
                .responseData()
                .map { response, data in
                    return (data, response)
                }
    }

    // Обертка для вызова простого POST
    internal func post(_ path: String, data: [String: Any], headers: [String: String] = [:]) -> Observable<(Data, HTTPURLResponse)> {
        do {
            let req = try JSONEncoding.default.encode(request(path, method: .post, headers: headers), with: data)
            return _call(req)
        } catch let error {
            return Observable.error(error)
        }
    }

    // Обертка для вызова простого POST
    internal func put(_ path: String, data: [String: Any], headers: [String: String] = [:]) -> Observable<(Data, HTTPURLResponse)> {
        do {
            let req = try JSONEncoding.default.encode(request(path, method: .put, headers: headers), with: data)
            return _call(req)
        } catch let error {
            return Observable.error(error)
        }
    }

    internal func delete(_ path: String, data: [String: Any], headers: [String: String] = [:]) -> Observable<(Data, HTTPURLResponse)> {
        do {
            let req = try JSONEncoding.default.encode(request(path, method: .delete, headers: headers), with: data)
            return _call(req)
        } catch let error {
            return Observable.error(error)
        }
    }

    internal func post<T: Encodable>(_ path: String, json: T, headers: [String: String] = [:]) -> Observable<(Data, HTTPURLResponse)> {
        do {
            var req = try request(path, method: .post, headers: headers)
            if !(json is EmptyRequest) {
                req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                req.httpBody = try jsonEncoder.encode(json)
            }
            return _call(req)
        } catch let error {
            return Observable.error(error)
        }
    }

    // Обертка для вызова простого GET
    internal func get(_ path: String, queryParams: [String: String], headers: [String: String]) -> Observable<(Data, HTTPURLResponse)> {
        do {
            let req = try request(path, method: .get, queryParams: queryParams, headers: headers)
            return _call(req)
        } catch let error {
            return Observable.error(error)
        }
    }

    // Генератор request. В AuthApiService этот метод переопределен для добавления токена аутенфикации
    internal func request(_ path: String, method: HTTPMethod, queryParams: [String: String] = [:], headers: [String: String] = [:]) throws -> URLRequest {
        let req = try URLRequest(url: ApiService.destUrl(url: path), method: method, headers: headers)
        return try URLEncoding.queryString.encode(req, with: queryParams)
    }

    internal func parseJSON<T: Decodable>(_ data: Data) -> T? {
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch let error {
            let responseStr = String(data: data, encoding: .utf8) ?? "unreadable"
            os_log("api json parsing problem\n%@", responseStr)
            os_log("error = %@", error.localizedDescription)
            return nil
        }
    }

    static func destUrl(url: String) -> String {
        return Constants.API_URL + url
    }
}

extension Request {
    public func debugLog() -> Self {
        #if DEBUG
        debugPrint(self)
        #endif
        return self
    }
}