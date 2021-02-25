//
//  APIResult.swift
//  Jikan
//
//  Created by William Liao on 2021/2/7.
//  Copyright © 2021 William Liao. All rights reserved.
//

import UIKit
import Foundation

enum APIResult<T, U> where U: Error  {
    case success(T)
    case failure(U)
}

public enum RequestType: String {
    case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

protocol APIClient {
    var session: URLSession { get }
    var cacheRespone: URLCache { get }
    func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, Error>) -> Void)
}

extension APIClient {
    typealias JSONTaskCompletionHandler = (Decodable?, Error?) -> Void
      
        private func decodingTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
            
            let decoder = JSONDecoder()

            let task = session.dataTask(with: request) { data, response, error in
               
                guard error == nil else {
                    let errorString = (error! as NSError).userInfo["NSLocalizedDescription"]
                   // let code = (error! as NSError).code
                    print("Error: \(String(describing: errorString))")
                    completion(nil, error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(nil, error)
                    return
                }
                
                var cacheData:Data? = nil
                if httpResponse.statusCode == 200 {
                    
                    if request.url!.absoluteString.contains("apod.json") {
                        if self.cacheRespone.cachedResponse(for: request) == nil,
                            let data = try? Data(contentsOf: request.url!) {
                            self.cacheRespone.storeCachedResponse(CachedURLResponse(response: httpResponse, data: data), for: request)
                            
                            cacheData = data
                            
                        } else {
                            let cacheRespone: CachedURLResponse = self.cacheRespone.cachedResponse(for: request)!
                            
                            cacheData = cacheRespone.data
                        }
                    }
                    
                    if let data = cacheData {
                        do {
                            let genericModel = try decoder.decode(decodingType, from: data)
                            completion(genericModel, nil)
                        } catch {
                            completion(nil, error)
                        }
                    } else {
                        completion(nil, error)
                    }

                } else {
                    print("statusCode \(httpResponse.statusCode)")
                }
            }
            return task
        }

        func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, Error>) -> Void) {
           
          
                let task = decodingTask(with: request, decodingType: T.self) { (json , error) in
                    
                    //MARK: change to main queue
                    DispatchQueue.main.async {
                        guard let json = json else {
                            if let error = error {
                                completion(APIResult.failure(error))
                            }
                            return
                        }

                        if let value = decode(json) {
                            completion(.success(value))
                        }
                    }
                }
                task.resume()
        }
    
    func clientURLRequest(url: URL , method: RequestType, params: Dictionary<String, AnyObject>? = nil) -> NSMutableURLRequest {
       
        
        let request = NSMutableURLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30.0)
        
        request.httpMethod = method.rawValue
        
        if let params = params {
            var paramString = ""
            for (key, value) in params {
                let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                paramString += "\(String(describing: escapedKey))=\(String(describing: escapedValue))&"
            }
            request.httpBody = paramString.data(using: String.Encoding.utf8)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if UserDefaults.standard.object(forKey: "ETag") != nil {
           let tag = UserDefaults.standard.string(forKey: "ETag")
           if let etag = tag {
               request.addValue(etag, forHTTPHeaderField: "If-None-Match")
           }
        }
        
        return request
    }
}
