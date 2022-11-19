//
//  detailHeroViewController.swift
//  Marvelgram
//
//  Created by Elisey Konovalov on 31.10.2022.
//

import UIKit

class DetailsHeroViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let heroTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let exploreMoreLabel: UILabel = {
        let label = UILabel()
        label.text = "Explore more"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let randomHeroCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let idHeroCollectionView = "idHeroCollectionView"
    
    var heroModel: HeroMarvelModel?
    var heroesArray = [HeroMarvelModel]()
    var randomHeroesArray: [HeroMarvelModel] = []
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHeroInfo()
        setupViews()
        setDelegates()
        setConstreints()
        getRandomHeroes()
    }
    
    private func setupViews() {
        view.backgroundColor = #colorLiteral(red: 0.09545705467, green: 0.09545705467, blue: 0.09545705467, alpha: 1)
        
        navigationController?.navigationBar.tintColor = .white
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
        
        randomHeroCollectionView.register(RandomHeroCollectionViewCell.self, forCellWithReuseIdentifier: idHeroCollectionView)
        
        view.addSubview(scrollView)
        scrollView.addSubview(heroImageView)
        scrollView.addSubview(heroTextLabel)
        scrollView.addSubview(exploreMoreLabel)
        scrollView.addSubview(randomHeroCollectionView)
        
        let textMultiplier = 12.5
        exploreMoreLabel.font = UIFont.systemFont(ofSize: view.frame.width / textMultiplier)
    }
    
    private func setupHeroInfo() {
        guard let heroModel = heroModel else { return }
        title = heroModel.name
        heroTextLabel.text = heroModel.description
        if heroTextLabel.text == "" {
            heroTextLabel.text = "The data on this hero is classified as 'TOP SECRET'"
        }
        
        guard let url = heroModel.thumbnail.url else { return }
        
        NetworkImageFetch.shared.requestImage(url: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case .success(let data):
                let image = UIImage(data: data)
                self.heroImageView.image = image
            case .failure(_):
                print("AlertHere")
            }
        }
    }
    
    private func setDelegates() {
        randomHeroCollectionView.dataSource = self
        randomHeroCollectionView.delegate = self
    }
    
    private func getRandomHeroes() {
        
        while randomHeroesArray.count < 8 {
            let randomInt = Int.random(in: 0...heroesArray.count - 1)
            randomHeroesArray.append(heroesArray[randomInt])
            
            let sortArray = unique(source: randomHeroesArray)
            randomHeroesArray = sortArray
        }
    }
    
    private func unique<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}

//MARK: - UICollectionViewDataSource

extension DetailsHeroViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        randomHeroesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = randomHeroCollectionView.dequeueReusableCell(withReuseIdentifier: idHeroCollectionView, for: indexPath) as? RandomHeroCollectionViewCell else {return UICollectionViewCell()}
        
        let heroModel = randomHeroesArray[indexPath.row]
        
        cell.cellConfigure(model: heroModel)
        
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension DetailsHeroViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let heroModel = randomHeroesArray[indexPath.row]
        let detailsHeroViewController = DetailsHeroViewController()
        detailsHeroViewController.heroModel = heroModel
        detailsHeroViewController.heroesArray = heroesArray
        
        navigationController?.pushViewController(detailsHeroViewController, animated: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension DetailsHeroViewController: UICollectionViewDelegateFlowLayout {
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        CGSize(width: collectionView.frame.height,
               height: collectionView.frame.height)
    }
}

//MARK: - setConstreints

extension DetailsHeroViewController {
    private func setConstreints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            heroImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
            heroImageView.widthAnchor.constraint(equalToConstant: view.frame.width),
            heroImageView.heightAnchor.constraint(equalToConstant: view.frame.width),
            
            heroTextLabel.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: 16),
            heroTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            heroTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            exploreMoreLabel.topAnchor.constraint(equalTo: heroTextLabel.bottomAnchor, constant: 16),
            exploreMoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            exploreMoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exploreMoreLabel.bottomAnchor.constraint(equalTo: randomHeroCollectionView.topAnchor, constant: -5),
            
            randomHeroCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            randomHeroCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            randomHeroCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),
            randomHeroCollectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10)
        ])
    }
}
