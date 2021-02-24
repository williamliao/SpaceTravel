//
//  SpaceListCoordinator.swift
//  SpaceTravel
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/24.
//

import UIKit

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
        main.coordinator = self
        main.viewModel = mainViewModel
        return main
    }
    
    func createPhotoListView() -> UIViewController {
        let photo = PhotoListViewController()
        photo.title = "Main"
        photo.coordinator = self
        photo.viewModel = photoListViewModel
        return photo
    }
    
    func createDetailView() -> UIViewController {
        let detail = PhotoDetailViewController()
        detail.title = "Main"
        detail.coordinator = self
        detail.viewModel = photoDetailViewModel
        return detail
    }
    
}

extension SpaceListCoordinator {
    
    func goToPhotoView() {
        
        let photoListVC = createPhotoListView()
        
        if let currentNavController = self.rootViewController.viewControllers.first as? UINavigationController {
            
            currentNavController.pushViewController(photoListVC, animated: true)
        }
    }
    
    func goToDetailView() {
        let topDetailVC = createDetailView()
        
        if let currentNavController = self.rootViewController.viewControllers.first as? UINavigationController {
            
            currentNavController.pushViewController(topDetailVC, animated: true)
        }
    }
}
