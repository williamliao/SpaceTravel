//
//  NetworkClient.swift
//  HelloUnitTest
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/25.
//

import Foundation

enum APIResult<T, U> where U: Error  {
    case success(T)
    case failure(U)
}

public enum RequestType: String {
    case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

enum ServerError: Swift.Error {
    case unknownError(Error)
    case statusCodeError(Int)
    case badRequest
    case forbidden
    case notFound
    case methodNotAllowed
    case timeOut
    case serverError
    case serverUnavailable
    case jsonDecodeFailed
    case badURL
    case badData
    
    var localizedDescription: String {
        switch self {
        case .unknownError(let error):
            return NSLocalizedString(error.localizedDescription, comment: "")
        case .notFound:
            return NSLocalizedString("notFound", comment: "")
        case .serverError:
            return NSLocalizedString("serverError", comment: "")
        case .serverUnavailable:
            return NSLocalizedString("serverUnavailable", comment: "")
        case .timeOut:
            return NSLocalizedString("timeOut", comment: "")
        case .jsonDecodeFailed:
            return NSLocalizedString("jsonDecodeFailed", comment: "")
        case .badURL:
            return NSLocalizedString("Bad Url", comment: "")
        case .badRequest:
            return NSLocalizedString("badRequest", comment: "")
        case .methodNotAllowed:
            return NSLocalizedString("methodNotAllowed", comment: "")
        case .forbidden:
            return NSLocalizedString("forbidden", comment: "")
        case .badData:
            return NSLocalizedString("badData", comment: "")
        case .statusCodeError(let code):
            return NSLocalizedString("statusCodeError:\(code)", comment: "")
        }
    }
}

class NetworkClient {
    
    typealias JSONTaskCompletionHandler = (Decodable?, ServerError?) -> Void

    private var session: URLSessionProtocol

    init(withSession session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    private func decodingTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTaskProtocol {
        
        let decoder = JSONDecoder()
        
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                let errorString = (error! as NSError).userInfo["NSLocalizedDescription"]
               // let code = (error! as NSError).code
                print("Error: \(String(describing: errorString))")
                completion(nil, ServerError.unknownError(error!))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain:"", code:999, userInfo:["NSLocalizedDescription": "no httpResponse"])
                completion(nil, ServerError.unknownError(error))
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let genericModel = try decoder.decode(decodingType, from: data)
                        completion(genericModel, nil)
                    } catch {
                        completion(nil, ServerError.jsonDecodeFailed)
                    }
                } else {
                    completion(nil, ServerError.badData)
                }
            } else {
                
                switch httpResponse.statusCode {
                case 404:
                    completion(nil, ServerError.notFound)
                default:
                    completion(nil, ServerError.statusCodeError(httpResponse.statusCode))
                    break
                }
            }
        }
        return task
    }

    func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        
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


