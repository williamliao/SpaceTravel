//
//  PhotoDetailViewController.swift
//  SpaceTravel
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/24.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    var viewModel: DetailViewModel!
    
    var coordinator :SpaceListCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
    }
 
    func render() {
        viewModel.createView(rootView: view)
        viewModel.createInfoBarItem(navItem: self.navigationItem)
        
        viewModel.respone.bind { [weak self] (_) in
            guard let res = self?.viewModel.respone.value else {
                return
            }
            self?.viewModel.configureView(respone: res)
        }
    }
}
