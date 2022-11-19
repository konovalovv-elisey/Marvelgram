//
//  randomHeroCollectionView.swift
//  Marvelgram
//
//  Created by Elisey Konovalov on 06.11.2022.
//

import UIKit

class RandomHeroCollectionViewCell: UICollectionViewCell {
    
    private let randomHeroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setConstraint()
    }
    
    private func setupViews() {
        backgroundColor = .none
        addSubview(randomHeroImageView)
    }
    
    func cellConfigure(model: HeroMarvelModel) {
        
        guard let url = model.thumbnail.url else { return }
        NetworkImageFetch.shared.requestImage(url: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                let image = UIImage(data: data)
                self.randomHeroImageView.image = image
            case .failure(_):
                print("AlertHere")
            }
        }
    }
    
    private func setConstraint() {
        NSLayoutConstraint.activate([
            randomHeroImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            randomHeroImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            randomHeroImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            randomHeroImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
