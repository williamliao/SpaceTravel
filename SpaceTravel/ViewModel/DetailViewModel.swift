//
//  DetailViewModel.swift
//  SpaceTravel
//
//  Created by 雲端開發部-廖彥勛 on 2021/2/24.
//

import UIKit
import Combine

class DetailViewModel: NSObject {
    
    // MARK:- property
    var respone: Observable<Response?> = Observable(nil)
    
    // MARK: - component
    private var cancellable: AnyCancellable?
    
    var coordinator: SpaceListCoordinator?
    
    var contentView: UIView!
    var scrollView:UIScrollView!
    
    var titleLabel: UILabel!
    var copyRightLabel: UILabel!
    var dateLabel: UILabel!
    var descriptionTextView: UITextView!
    var imageView: UIImageView!
    var infoButton: UIButton!
    
    var descriptionTextViewHeightConstraint: NSLayoutConstraint!
    
    private var act = UIActivityIndicatorView(style: .large)
    
}
// MARK: - View
extension DetailViewModel {
    func createView(rootView: UIView) {
        
        rootView.backgroundColor = .systemBackground
        
        contentView = UIView()
        
        scrollView = UIScrollView()
        
        dateLabel = UILabel()
        dateLabel.font = UIFont.systemFont(ofSize: 16)
        dateLabel.textAlignment = .center
        dateLabel.textColor = .label
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        
        copyRightLabel = UILabel()
        copyRightLabel.font = UIFont.systemFont(ofSize: 16)
        copyRightLabel.textAlignment = .center
        copyRightLabel.textColor = .label
        
        descriptionTextView = UITextView()
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.textColor = .label
        descriptionTextView.clipsToBounds = true
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        rootView.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(copyRightLabel)
        contentView.addSubview(act)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        copyRightLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        act.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            
            scrollView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: rootView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: rootView.widthAnchor, multiplier: 1.0),
            
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            dateLabel.heightAnchor.constraint(equalToConstant: 16),
            
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 300),
           
            act.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            act.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            titleLabel.heightAnchor.constraint(equalToConstant: 16),
            
            copyRightLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            copyRightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            copyRightLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            copyRightLabel.heightAnchor.constraint(equalToConstant: 16),
            
            descriptionTextView.topAnchor.constraint(equalTo: copyRightLabel.bottomAnchor, constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
        ])
        
        descriptionTextViewHeightConstraint = descriptionTextView.heightAnchor.constraint(equalToConstant: 100)
        descriptionTextViewHeightConstraint.isActive = true
    }
    
    func configureView(respone: Response) {
        
        formatDateString(dateString: respone.date)
        titleLabel.text = respone.title
        copyRightLabel.text = respone.copyright
        descriptionTextView.text = respone.description
        
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let constraintRect = CGSize(width: 200, height: CGFloat.greatestFiniteMagnitude)
        let attribute = [NSAttributedString.Key.font: descriptionTextView.font!, NSAttributedString.Key.paragraphStyle: style]
        let str = NSString(string: respone.description)
        
        let textViewHeight = str.boundingRect(with: constraintRect, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: attribute, context: nil).size
        descriptionTextViewHeightConstraint.constant = CGFloat(ceilf(Float(textViewHeight.height)))
        
       
        if let url = URL(string: respone.hdurl) {
            configureImage(with: url)
        }
        
    }
    
    func createInfoBarItem(navItem: UINavigationItem) {
        
        infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: infoButton)
        navItem.rightBarButtonItem = barButton
    }
}

// MARK: - Public
extension DetailViewModel {
     func configureImage(with url: URL) {
         isLoading(isLoading: true)
         cancellable = self.loadImage(for: url).sink { [unowned self] image in
             self.showImage(image: image)
             isLoading(isLoading: false)
         }
     }
}

// MARK: - Private
extension DetailViewModel {
    
    private func formatDateString(dateString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else {
            return
        }

        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        formatter.dateFormat = "MMM"
        let month = formatter.string(from: date)
        formatter.dateFormat = "dd"
        let day = formatter.string(from: date)
        
        dateLabel.text = "\(year) \(month). \(day)"
    }
    
    private func showImage(image: UIImage?) {
        
        guard let image = image else {
            return
        }
        
       // let imageAspectRatio = image.size.width / image.size.height
    
       // imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageAspectRatio).isActive = true
        
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
        
    private func loadImage(for url: URL) -> AnyPublisher<UIImage?, Never> {
        return Just(url)
        .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
            return ImageLoader.shared.loadImage(from: url)
        })
        .eraseToAnyPublisher()
    }
    
    private func isLoading(isLoading: Bool) {
        if isLoading {
            act.startAnimating()
        } else {
            act.stopAnimating()
        }
        act.isHidden = !isLoading
    }
}

extension DetailViewModel {
    @objc func infoButtonTapped() {
        if let res = self.respone.value {
            if let url = URL(string: res.apod_site) {
                coordinator?.openWebUrl(url: url)
            }
        }
    }
}
