//
//  PhotoListViewController.swift
//  SpaceTravel
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/24.
//

import UIKit

class PhotoListViewController: UIViewController {
    
    var viewModel: PhotoListViewModel!
    
    var coordinator :SpaceListCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewModel.updateCollectionView()
    }
    
    func render() {
        
        viewModel.configureCollectionView(Add: view)
        
        viewModel.respone.bind { [weak self] (_) in
            self?.viewModel.applyInitialSnapshots()
        }
    }

}
