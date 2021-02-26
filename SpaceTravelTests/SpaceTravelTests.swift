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
    
    var sut : ServiceHelper!
    var mockSession: MockURLSession!
    let endpoint = URL(string: "https://raw.githubusercontent.com/cmmobile/NasaDataSet/main/apod.json")!
    
    var respone = [Response]()
    var fakeRespone = [Response]()
    
    //let service = ServiceHelper(withBaseURL: "https://raw.githubusercontent.com")
    
    let fakeData = FakeData()
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        sut = nil
        mockSession = nil
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
    
    private func loadJsonData(file: String) -> Data? {
        //1
        if let jsonFilePath = Bundle(for: type(of:  self)).path(forResource: file, ofType: "json") {
            let jsonFileURL = URL(fileURLWithPath: jsonFilePath)
            //2
            if let jsonData = try? Data(contentsOf: jsonFileURL) {
                return jsonData
            }
        }
        //3
        return nil
    }
   
    private func createMockSession(fromJsonFile file: String,
                            andStatusCode code: Int,
                            andError error: Error?) -> MockURLSession? {

        let data = loadJsonData(file: file)
        let response = HTTPURLResponse(url: URL(string: "TestUrl")!, statusCode: code, httpVersion: nil, headerFields: nil)
        return MockURLSession(completionHandler: (data, response, error))
    }
}

extension SpaceTravelTests {
    
    func testNetworkClient_successResult() {
        mockSession = createMockSession(fromJsonFile: "nasa",
    andStatusCode: 200, andError: nil)
        sut = ServiceHelper(withSession: mockSession)
        
        sut.getFeed(fromRoute: Routes.dataSet, parameters: nil) { (result) in
            
            switch result {
                case .success(let feedResult):
                    XCTAssertNotNil(feedResult)
                    XCTAssertTrue(feedResult.count == 5178)
                    let respone = feedResult.first!
                    XCTAssertTrue(respone.title == "A Year of Extraterrestrial Fountains and Flows")
                case .failure( _):
                    XCTFail("Fail")
                    break
            }
        }
        
    }
    
    func testNetworkClient_404Result() {
        mockSession = createMockSession(fromJsonFile: "nasa", andStatusCode: 404, andError: nil)
        sut = ServiceHelper(withSession: mockSession)
        
        let exception = XCTestExpectation()
        var thrownError: ServerError?
        
        sut.getFeed(fromRoute: Routes.dataSet, parameters: nil) { (result) in
            
            switch result {
                case .success(_):
                    break
                case .failure(let error):
                    thrownError = error
            }
        }
        
        let wait = XCTWaiter()
        _ = wait.wait(for: [exception], timeout: 1)
        
        XCTAssertNotNil(thrownError)
        XCTAssertTrue(thrownError?.localizedDescription == "notFound")
    }
    
    func testNetworkClient_NoData() {
        mockSession = createMockSession(fromJsonFile: "A", andStatusCode: 200, andError: nil)
        sut = ServiceHelper(withSession: mockSession)
        
        let exception = XCTestExpectation()
        var thrownError: ServerError?
        
        sut.getFeed(fromRoute: Routes.dataSet, parameters: nil) { (result) in
            
            switch result {
                case .success(_):
                    break
                case .failure(let error):
                    thrownError = error
            }
        }
        
        let wait = XCTWaiter()
        _ = wait.wait(for: [exception], timeout: 1)
        
        XCTAssertNotNil(thrownError)
        XCTAssertTrue(thrownError?.localizedDescription == "badData")
    }
    
    func testNetworkClient_UnExpectStatusCode() {
        mockSession = createMockSession(fromJsonFile: "nasa", andStatusCode: 500, andError: nil)
        sut = ServiceHelper(withSession: mockSession)
        
        let exception = XCTestExpectation()
        var thrownError: ServerError?
        
        sut.getFeed(fromRoute: Routes.dataSet, parameters: nil) { (result) in
            
            switch result {
                case .success(_):
                    break
                case .failure(let error):
                    thrownError = error
            }
        }
        
        let wait = XCTWaiter()
        _ = wait.wait(for: [exception], timeout: 1)
        
        XCTAssertNotNil(thrownError)
        XCTAssertTrue(thrownError?.localizedDescription == "statusCodeError:500")
    }
    
    func testListCount() {
        
        mockSession = createMockSession(fromJsonFile: "nasa",
    andStatusCode: 200, andError: nil)
        sut = ServiceHelper(withSession: mockSession)
        
        let exception = XCTestExpectation()
        
        let fakeRespone = fakeData.getDataRespone()
        
        sut.getFeed(fromRoute: Routes.dataSet, parameters: nil) { [weak self] (result) in
            
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
        
        let fakeRespone = fakeData.getDataRespone()
        
        let dataString = fakeRespone[0].date
        
        let formatDataString = viewModel.formatDateString(dateString: dataString)
        
        XCTAssertEqual(formatDataString, "2006 Dec. 31")
    }
    
    func testDetailTextNotNil() {
       let viewModel = DetailViewModel()
        
        let fakeRespone = fakeData.getDataRespone()
        
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
        
        let fakeRespone = fakeData.getDataRespone()
        
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
