//
//  AppCoordinator.swift
//  HelloCoordinator
//
//  Created by William on 2018/12/25.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    // MARK: - Properties
    let window: UIWindow?
    var navController: UINavigationController
    lazy var rootViewController: UINavigationController = {
        return UINavigationController()
    }()

    // MARK: - Coordinator
    init(navController: UINavigationController, window: UIWindow?) {
        self.navController = navController
        self.window = window
    }

    lazy var mainViewModel: MainViewModel! = {
        let viewModel = MainViewModel()
        return viewModel
    }()
    
    override func start() {
        let coordinator = SpaceListCoordinator(rootViewController: navController)
        coordinator.start()
    }
    
    override func finish() {
        
    }
}
