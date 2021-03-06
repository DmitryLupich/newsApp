//
//  Endpoint.swift
//  NewsApp
//
//  Created by Dmitriy Lupych on 7/8/19.
//  Copyright © 2019 Dmitry Lupich. All rights reserved.
//

import Foundation

enum Endpoint {
    case latestNews(page: Int)

    var path: String {
        switch self {
        case .latestNews(let page):
            return baseURL + "posts/?page=\(page)"
        }
    }

    private var baseURL: String {
        return AppConstants.Domain.baseURL
    }
}
