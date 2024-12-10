//
//  APIEndpoint.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 09/12/2024.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
}

struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let parameters: [String: String]?

    init(path: String, method: HTTPMethod = .GET, parameters: [String: String]? = nil) {
        self.path = path
        self.method = method
        self.parameters = parameters
    }
}
