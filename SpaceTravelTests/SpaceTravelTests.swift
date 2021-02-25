//
//  SpaceTravelTests.swift
//  SpaceTravelTests
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/24.
//

import XCTest
@testable import SpaceTravel
@testable import SpaceTravel

class SpaceTravelTests: XCTestCase {
    
    var sut: URLSession!
    
    var respone = [Response]()
    var fakeRespone = [Response]()
    
    let service = ServiceHelper(withBaseURL: "https://raw.githubusercontent.com")
    
    let fakeData = FakeData()
    
    
    override func setUpWithError() throws {
        sut = URLSession(configuration: .default)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        sut = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension SpaceTravelTests {
    
    func testListCount() {
        let exception = XCTestExpectation()
        
        let fakeRespone = fakeData.getData()
        
        service.getFeed(fromRoute: Routes.dataSet, parameters: nil) { [weak self] (result) in
            
            switch result {
                case .success(let feedResult):
                    self?.respone = feedResult
                case .failure( _):
                    XCTFail("Fail")
                    break
            }
        }

        let wait = XCTWaiter()
        _ = wait.wait(for: [exception], timeout: 10)
            
        XCTAssert(respone.count == 5178, "API Parse Error")
        XCTAssertEqual(fakeRespone, self.respone)
    }
    
    func testValidCallGetsHTTPStatusCode200() {
            let url =
                URL(string: "https://raw.githubusercontent.com/cmmobile/NasaDataSet/main/apod.json")!
            let promise = expectation(description: "Status code: 200")
            var sc: Int?
            var responseError: Error?
            
            // when
            let dataTask = sut.dataTask(with: url) { data, response, error in
                // then
                if let error = error {
                  responseError = error
                  XCTFail("Error: \(error.localizedDescription)")
                  return
                } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    sc = (response as? HTTPURLResponse)?.statusCode
                  if statusCode == 200 {
                    // 2
                    promise.fulfill()
                  } else {
                    XCTFail("Status code: \(statusCode)")
                  }
                }
              }
              dataTask.resume()
              // 3
            wait(for: [promise], timeout: 10)
            XCTAssertNil(responseError)
            XCTAssertEqual(sc, 200)
    }
    
    func testDecoding() throws {
        
        let bundle = Bundle(for: type(of: self))
      
        guard let url = bundle.url(forResource: "nasa", withExtension: "json") else {
            XCTFail("Missing file: nasa.json")
            return
        }

        guard let jsonData = try? Data(contentsOf: url) else { return }

        XCTAssertNoThrow(try JSONDecoder().decode([Response].self, from: jsonData))
    }
    
    func testFormatData() {
       let viewModel = DetailViewModel()
        
        let fakeRespone = fakeData.getData()
        
        let dataString = fakeRespone[0].date
        
        let formatDataString = viewModel.formatDateString(dateString: dataString)
        
        XCTAssertEqual(formatDataString, "2006 Dec. 31")
    }
    
    func testDetailTextNotNil() {
       let viewModel = DetailViewModel()
        
        let fakeRespone = fakeData.getData()
        
        let vc = UIViewController()
        
        viewModel.createView(rootView: vc.view)
        viewModel.respone.value = fakeRespone[0]
        
        viewModel.configureView(respone: fakeRespone[0])
      
        let title = viewModel.titleLabel.text
        let copyRight = viewModel.copyRightLabel.text
        let description = viewModel.descriptionTextView.text
        let date = viewModel.dateLabel.text

        XCTAssertNotNil(title)
        XCTAssertNotNil(copyRight)
        XCTAssertNotNil(description)
        XCTAssertNotNil(date)
    }
    
    func testPhotoListNotNil() {
       let viewModel = PhotoListViewModel()
        
        let fakeRespone = fakeData.getData()
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(PhotoListCollectionViewCell.self
                                , forCellWithReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier)
        
        let cell = viewModel.configureCell(collectionView: collectionView, respone: fakeRespone[0], indexPath: IndexPath(row: 0, section: 0))
        
        let title = fakeRespone[0].title
        
        XCTAssertEqual(title, cell?.titleLabel.text)
        
        let exception = XCTestExpectation()
        let wait = XCTWaiter()
        _ = wait.wait(for: [exception], timeout: 10)
        
        let imageData = cell?.thumbnailImageView.image?.pngData()
        XCTAssertNotNil(imageData)
    }
}
