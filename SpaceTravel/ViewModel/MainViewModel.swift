//
//  MainViewModel.swift
//  SpaceTravel
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/24.
//

import UIKit

class MainViewModel: NSObject {
    
    // MARK:- property
    var respone: Observable<[Response]?> = Observable([])
    var errorMessage: Observable<String?> = Observable(nil)
    var error: Observable<Error?> = Observable(nil)
    
    var isLoading: Observable<Bool> = Observable(false)

    // MARK: - component
    let service = ServiceHelper(withBaseURL: "https://raw.githubusercontent.com")
    var coordinator: SpaceListCoordinator?
    
    var titleLabel: UILabel!
    var pushButton: UIButton!
    private var act = UIActivityIndicatorView(style: .large)
}

// MARK: - View
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
        rootView.addSubview(act)
        
        createConstraint(rootView: rootView)
    }
    
    private func createConstraint(rootView: UIView) {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pushButton.translatesAutoresizingMaskIntoConstraints = false
        act.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            act.centerXAnchor.constraint(equalTo: rootView.centerXAnchor),
            act.centerYAnchor.constraint(equalTo: rootView.centerYAnchor),
        ])
    }
    
    private func pushToPhotoView(respone: [Response]) {
        coordinator?.goToPhotoView(respone: respone)
    }
   
}

// MARK: - Public
extension MainViewModel {
    @objc func fetchData() {
        
//        if (self.respone.value?.count ?? 0 > 0) {
//            self.pushToPhotoView(respone: self.respone.value!)
//            return
//        }
        
        self.isLoading.value = true
        
        self.service.getFeed(fromRoute: Routes.dataSet, parameters: nil) { [weak self] (result) in
            
            self?.isLoading.value = false
            
            switch result {
                case .success(let feedResult):
                
                    self?.pushToPhotoView(respone: feedResult)
                    self?.respone.value = feedResult

                case .failure(let error):
                    self?.setError(error)
            }
        }
    }
    
    func isLoading(isLoading: Bool) {
        if isLoading {
            act.startAnimating()
        } else {
            act.stopAnimating()
        }
        act.isHidden = !isLoading
    }
}

// MARK: - Private
extension MainViewModel {
    
    private func setError(_ error: Error) {
        self.errorMessage = Observable(error.localizedDescription)
        self.error = Observable(error)
    }
}
