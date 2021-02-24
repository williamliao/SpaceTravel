//
//  MainViewModel.swift
//  SpaceTravel
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/24.
//

import UIKit

class MainViewModel: NSObject {
    let service = ServiceHelper(withBaseURL: "https://raw.githubusercontent.com/")
    
    var errorMessage: Observable<String?> = Observable(nil)
    var error: Observable<Error?> = Observable(nil)
    
    var isLoading: Observable<Bool> = Observable(false)
    
    var coordinator: SpaceListCoordinator?
    
    var titleLabel: UILabel!
    var pushButton: UIButton!
    
    @objc func fetchData() {
        
        self.isLoading.value = true
        
        self.service.getFeed(fromRoute: Routes.dataSet, parameters: nil) { [weak self] (result) in
            
            self?.isLoading.value = false
            
            switch result {
                case .success(let feedResult):
                
                    self?.pushToPhotoView(respone: feedResult)

                case .failure(let error):
                    self?.setError(error)
            }
        }
    }
    
    func setError(_ error: Error) {
        self.errorMessage = Observable(error.localizedDescription)
        self.error = Observable(error)
    }
}

extension MainViewModel {
    func createView(rootView: UIView) {
        
        rootView.backgroundColor = .systemBackground
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = "Astronomy Picture of the Day"
        titleLabel.textColor = .label
        
        pushButton = UIButton()
        pushButton.setTitle("Request", for: .normal)
        pushButton.setTitleColor(.systemBlue, for: .normal)
        pushButton.addTarget(self, action: #selector(fetchData), for: .touchUpInside)
        pushButton.showsTouchWhenHighlighted = true
        
        rootView.addSubview(titleLabel)
        rootView.addSubview(pushButton)
        
        createConstraint(rootView: rootView)
    }
    
    func createConstraint(rootView: UIView) {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pushButton.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = rootView.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            pushButton.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            pushButton.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            pushButton.heightAnchor.constraint(equalToConstant: 44),
            pushButton.widthAnchor.constraint(equalToConstant: 100),
            
            titleLabel.bottomAnchor.constraint(equalTo: pushButton.topAnchor, constant: -80),
            titleLabel.heightAnchor.constraint(equalToConstant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -10),
        ])
    }
    
    func pushToPhotoView(respone: [Response]) {
        coordinator?.goToPhotoView(respone: respone)
    }
}
