//
//  SearchVC.swift
//  exam
//
//  Created by Karolis Petkevicius on 30/11/2019.
//  Copyright © 2019 org. All rights reserved.
//

import UIKit
import Alamofire

final class SearchVC: UIViewController {
    
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var collectionView: UICollectionView!
    
    private var albums: [Album] = []
    
    override func viewDidLoad() {
        hideKeyboardWhenTappedAround() 
        collectionView.delegate = self
        collectionView.dataSource = self
        let collectionViewNib = UINib(nibName: "FullAlbumCell", bundle: nil)
        collectionView.register(collectionViewNib, forCellWithReuseIdentifier: "FullAlbumCell")
        
        searchBar.delegate = self
        
        fetchData()
        
        
    }
    
    private func fetchData() {
        let url = "https://www.theaudiodb.com/api/v1/json/1/searchalbum.php?a=\(searchBar.text ?? "")"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseData(completionHandler: { [weak self] response in
            guard let data = response.data else { return }
            let decoder = JSONDecoder()
            do {
                let albums = try decoder.decode(SearchResponse.self, from: data)
                self?.albums = albums.album
                self?.collectionView.reloadData()
            } catch {
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? AlbumVC)?.album = sender as? Album
    }
}

extension SearchVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullAlbumCell", for: indexPath as IndexPath) as! FullAlbumCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.setup(with: albums[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        performSegue(withIdentifier: "AlbumVC", sender: albums[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.size.width
        return CGSize(width: width * 0.45, height: width * 0.45)
    }
}

extension SearchVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            fetchData()
        } else {
            albums.removeAll()
            collectionView.reloadData()
        }
    }
}

struct SearchResponse: Codable {
    let album: [Album]
}



//hides keyboard extension
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
