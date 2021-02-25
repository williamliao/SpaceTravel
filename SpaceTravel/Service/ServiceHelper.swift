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

class ServiceHelper: NSObject, APIClient {
  
    var cacheRespone: URLCache = URLCache()
    
    let baseURL: String
    
    init(withBaseURL baseURL: String) {
        self.baseURL = baseURL
    }
    
    lazy var session: URLSession = { [weak self] in
        
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let diskCacheURL = cachesURL.appendingPathComponent("DownloadCache")
        let cache = URLCache(memoryCapacity: 10_000_000, diskCapacity: 1024 * 1024 * 100, directory: diskCacheURL)
        
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = cache
        configuration.timeoutIntervalForResource = 60
        if #available(iOS 11, *) {
            configuration.waitsForConnectivity = true
        }
        let session = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil)
        return session
    }()
    
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

extension ServiceHelper: URLSessionDelegate {
  
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Error: \(String(describing: error?.localizedDescription))")
        task.cancel()
    }
}
