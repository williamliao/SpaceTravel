//
//  ServiceHelper.swift
//  SpaceTravel
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/24.
//

import UIKit

public struct Route {
    let endpoint: String
}

public struct Routes {
    static let dataSet = Route(endpoint: "/cmmobile/NasaDataSet/main/apod.json")
}

class ServiceHelper: NetworkClient {
   
    var cacheRespone: URLCache = URLCache()
    
    let baseURL: String
    
    init(withBaseURL baseURL: String) {
        self.baseURL = baseURL
    }
    
    func getFeed(fromRoute route: Route,  parameters: Any?, completion: @escaping (APIResult<[Response], Error>) -> Void) {
        guard let url = URL(string: self.baseURL+route.endpoint) else {
            let errorTemp = NSError(domain:"", code:999, userInfo:["error": "badURL"])
            completion(.failure(errorTemp))
            return
        }
       
        fetch(with: clientURLRequest(url: url, method: .get) as URLRequest, decode: { json -> [Response]? in
               guard let feedResult = json as? [Response] else { return  nil }
               return feedResult
           }, completion: completion)
    }
}
