//
//  URLSessionProtocol.swift
//  HelloUnitTest
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/25.
//

import Foundation

//1
protocol URLSessionDataTaskProtocol {
    //2
    func resume()
}
//3
extension URLSessionDataTask: URLSessionDataTaskProtocol {}

//1
protocol URLSessionProtocol {
    //2
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}
//3
extension URLSession: URLSessionProtocol {
    //4
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol   {
        //5
        return (dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        
        return (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}
