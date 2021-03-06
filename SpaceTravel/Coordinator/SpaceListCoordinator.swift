//
//  SpaceListCoordinator.swift
//  SpaceTravel
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/24.
//

import UIKit
import SafariServices

class SpaceListCoordinator: Coordinator {
    // MARK: - Properties
    var rootViewController: UINavigationController
    
    // MARK: - Coordinator
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }
    
    lazy var mainViewModel: MainViewModel! = {
        let viewModel = MainViewModel()
        return viewModel
    }()
    
    lazy var photoListViewModel: PhotoListViewModel! = {
        let viewdModel = PhotoListViewModel()
        return viewdModel
    }()
    
    lazy var photoDetailViewModel: DetailViewModel! = {
        let viewdModel = DetailViewModel()
        return viewdModel
    }()
    
    override func start() {
        let main = createMainView()
        self.rootViewController.pushViewController(main, animated: true)
    }
    
    override func finish() {
        
    }
    
    func createMainView() -> UIViewController {
        let main = MainViewController()
        main.title = "Main"
        main.viewModel = mainViewModel
        main.viewModel.coordinator = self
        return main
    }
    
    func createPhotoListView(respone: [Response]) -> UIViewController {
        let photo = PhotoListViewController()
        photo.title = "Photo"
        photo.coordinator = self
        photoListViewModel.respone.value = respone
        photo.viewModel = photoListViewModel
        photo.viewModel.coordinator = self
        return photo
    }
    
    func createDetailView() -> PhotoDetailViewController {
        let detail = PhotoDetailViewController()
        detail.title = "Detail"
        detail.coordinator = self
        detail.viewModel = photoDetailViewModel
        detail.viewModel.coordinator = self
        return detail
    }
    
}

extension SpaceListCoordinator {
    
    func goToPhotoView(respone: [Response]) {
        
        let photoListVC = createPhotoListView(respone: respone)
        
        rootViewController.pushViewController(photoListVC, animated: true)
    }
    
    func goToDetailView(respone: Response) {
        let topDetailVC = createDetailView()
        
        topDetailVC.viewModel.respone.value = respone
        
        rootViewController.pushViewController(topDetailVC, animated: true)
    }
    
    func openWebUrl(url: URL) {
        let config = SFSafariViewController.Configuration()

        let vc = SFSafariViewController(url: url, configuration: config)
        rootViewController.present(vc, animated: true)
    }
}
