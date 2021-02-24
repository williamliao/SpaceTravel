//
//  Response.swift
//  SpaceTravel
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/24.
//

import Foundation

struct Response: Codable {
    let description: String
    let copyright: String
    let title: String
    let url: String
    let apod_site: String
    let date: String
    let media_type: String
    let hdurl: String
}

extension Response: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
        hasher.combine(copyright)
        hasher.combine(title)
        hasher.combine(url)
        hasher.combine(apod_site)
        hasher.combine(date)
        hasher.combine(media_type)
        hasher.combine(hdurl)
    }
}
