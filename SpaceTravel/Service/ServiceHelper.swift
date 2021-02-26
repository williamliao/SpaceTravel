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
    static let badUrl = Route(endpoint: "/cmmobile")
}

class ServiceHelper: NetworkClient {
   
    var cacheRespone: URLCache = URLCache()
    
   /* let baseURL: String
    
    init(withBaseURL baseURL: String) {
        self.baseURL = baseURL
    }*/
    
    func getFeed(fromRoute route: Route,  parameters: Any?, completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
        let baseURL = "https://raw.githubusercontent.com"
        
        guard let url = URL(string: baseURL+route.endpoint) else {
            completion(.failure(ServerError.badURL))
            return
        }
       
        fetch(with: clientURLRequest(url: url, method: .get) as URLRequest, decode: { json -> [Response]? in
               guard let feedResult = json as? [Response] else { return  nil }
               return feedResult
           }, completion: completion)
    }
}
