//
//  topAlbumsVC.swift
//  exam
//
//  Created by Karolis Petkevicius on 30/11/2019.
//  Copyright © 2019 org. All rights reserved.
//

import UIKit
import Alamofire

final class TopAlbumsVC: UIViewController {
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var tableView: UITableView!
    
    private var albums: [Album] = []
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let collectionViewNib = UINib(nibName: "FullAlbumCell", bundle: nil)
        collectionView.register(collectionViewNib, forCellWithReuseIdentifier: "FullAlbumCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        let tableViewNib = UINib(nibName: "SongCell", bundle: nil)
        tableView.register(tableViewNib, forCellReuseIdentifier: "SongCell")

        fetchData()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change", style: .done, target: self, action: #selector(changeView))

    }
    
    @objc private func changeView() {
        tableView.isHidden = !tableView.isHidden
        collectionView.isHidden = !tableView.isHidden
    }
    
    private func fetchData() {
        Alamofire.request("https://www.theaudiodb.com/api/v1/json/1/mostloved.php?format=album", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseData(completionHandler: { [weak self] response in
            guard let data = response.data else { return }
            let decoder = JSONDecoder()
            do {
                let albums = try decoder.decode(TopAlbumsResponse.self, from: data)
                self?.albums = albums.loved
                self?.collectionView.reloadData()
                self?.tableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        })
    }
    //passing the album
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? AlbumVC)?.album = sender as? Album
    }
}

extension TopAlbumsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullAlbumCell", for: indexPath as IndexPath) as! FullAlbumCell
        
        cell.setup(with: albums[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        performSegue(withIdentifier: "AlbumVC", sender: albums[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //setup cell size
        let width = view.frame.size.width
        return CGSize(width: width * 0.45, height: width * 0.45)
    }
}

extension TopAlbumsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get a reference to our storyboard cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
        
        cell.setup(with: BasicAlbum(title: albums[indexPath.row].strAlbum, subtitle: albums[indexPath.row].strArtist))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // handle tap events
        performSegue(withIdentifier: "AlbumVC", sender: albums[indexPath.row])
    }
}

struct TopAlbumsResponse: Codable {
    let loved: [Album]
}
struct Album: Codable {
    let idAlbum: String
    let strAlbum: String
    let strAlbumThumb: String?
    let strArtist: String
    let intYearReleased: String
}

struct BasicAlbum: SimpleCell {
    let title: String
    let subtitle: String
}
