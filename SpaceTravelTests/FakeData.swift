//
//  FakeData.swift
//  SpaceTravelTests
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/25.
//

import Foundation
@testable import SpaceTravel

class FakeData {
    
    func getURL() -> URL? {
        let bundle = Bundle(for: type(of: self))

        guard let url = bundle.url(forResource: "nasa", withExtension: "json") else {
            return nil
        }
        
        return url
    }
    
    func getData() -> [Response] {
        
      guard
        let url = getURL(),
        let data = try? Data(contentsOf: url)
        else {
          return []
      }
      
      do {
        let decoder = JSONDecoder()
        return try decoder.decode([Response].self, from: data)
      } catch {
        return []
      }
    }
}
