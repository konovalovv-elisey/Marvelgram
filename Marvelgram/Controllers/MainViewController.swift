//
//  ViewController.swift
//  Marvelgram
//
//  Created by Elisey Konovalov on 26.10.2022.
//

import UIKit

class MainViewController: UIViewController {
    
    private let heroCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var searchController = UISearchController()
    
    private let idCollectionView = "idCollectionView"
    private var heroesArray = [HeroMarvelModel]()
    
    private var isFiltred = false
    private var filtredArray = [IndexPath]()
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getHeroesArray()
        setupViews()
        setupNavigationBar()
        setDelegates()
        setConstreints()
    }
    
    private func setupViews() {
        
        view.backgroundColor = #colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.09411764706, alpha: 1)
        view.addSubview(heroCollectionView)
        
        heroCollectionView.register(HeroesCollectionViewCell.self, forCellWithReuseIdentifier: idCollectionView)
    }
    
    private func setupNavigationBar() {
        
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        
        navigationItem.backButtonTitle = ""
        
        navigationItem.titleView = createCustomTitleView()
        navigationItem.hidesSearchBarWhenScrolling = true
        
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.backgroundColor = #colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.09411764706, alpha: 1)
            navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = #colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.09411764706, alpha: 1)
        }
    }
    
    private func setDelegates() {
        heroCollectionView.dataSource = self
        heroCollectionView.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.delegate = self
    }
    
    private func getHeroesArray() {
        
        NetworkDataFetch.shared.fatchHero { [weak self] heroMarvelArray, error in
            guard let self = self else {return}
            if error != nil {
                print("show alert")
            } else {
                guard let heroMarvelArray = heroMarvelArray else {return}
                
                self.heroesArray = heroMarvelArray
                self.heroCollectionView.reloadData()
            }
        }
    }
    
    private func setAlphaForCell(alpha: Double) {
        heroCollectionView.visibleCells.forEach { cell in
            cell.alpha = alpha
        }
    }
    
    private func createCustomTitleView() -> UIView {
        
        let view = UIView()
        let heightNavBar = navigationController?.navigationBar.frame.height ?? 0
        let widthNavBar = navigationController?.navigationBar.frame.width ?? 0
        view.frame = CGRect(x: 0, y: 0, width: widthNavBar, height: heightNavBar - 10)
        
        let marvelImageView = UIImageView()
        marvelImageView.image = UIImage(named: "MarvelLogo")
        marvelImageView.contentMode = .left
        marvelImageView.frame = CGRect(x: 10, y: 0, width: widthNavBar, height: heightNavBar / 2)
        view.addSubview(marvelImageView)
        return view
    }
}

//MARK: - UICollectionViewDataSource

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        heroesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = heroCollectionView.dequeueReusableCell(withReuseIdentifier: idCollectionView, for: indexPath) as! HeroesCollectionViewCell
        let heroModel = heroesArray[indexPath.row]
        
        cell.cellConfigure(model: heroModel)
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let heroModel = heroesArray[indexPath.row]
        let detailsHeroViewController = DetailsHeroViewController()
        detailsHeroViewController.heroModel = heroModel
        detailsHeroViewController.heroesArray = heroesArray
        
        navigationController?.pushViewController(detailsHeroViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isFiltred {
            cell.alpha = (filtredArray.contains(indexPath) ? 1 : 0.3)
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension MainViewController: UICollectionViewDelegateFlowLayout {
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        CGSize(width: heroCollectionView.frame.width / 3.02,
               height: heroCollectionView.frame.width / 3.02)
    }
}

//MARK: - UISearchResultUpdating

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filterContentForSearchText(text)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        for (value, hero) in heroesArray.enumerated() {
            let indexPath: IndexPath = [0, value]
            let cell = heroCollectionView.cellForItem (at: indexPath)
            
            if hero.name.lowercased().contains(searchText.lowercased()) {
                filtredArray.append(indexPath)
                cell?.alpha = 1
            } else {
                cell?.alpha = 0.3
            }
        }
    }
}

//MARK: - UISearchControllerDelegate

extension MainViewController: UISearchControllerDelegate {
    
    func didPresentSearchController(_ searchController: UISearchController) {
        isFiltred = true
        setAlphaForCell(alpha: 0.3)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        isFiltred = false
        setAlphaForCell(alpha: 1)
    }
}

//MARK: - SetConstreints

extension MainViewController {
    
    private func setConstreints() {
        
        NSLayoutConstraint.activate([
            heroCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            heroCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            heroCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            heroCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
}
