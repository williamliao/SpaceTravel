//
//  MainViewController.swift
//  SpaceTravel
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/24.
//

import UIKit

class MainViewController: UIViewController {
    
    var viewModel: MainViewModel!
    
    var coordinator :SpaceListCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        render()
    }
    
    func render() {
        viewModel.createView(rootView: view)
    }
}
