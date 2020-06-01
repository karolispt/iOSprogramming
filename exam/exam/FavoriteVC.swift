//
//  FavoriteVC.swift
//  exam
//
//  Created by Karolis Petkevicius on 01/12/2019.
//  Copyright © 2019 org. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

final class FavoriteVC: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var collectionView: UICollectionView!
    
    private var tracks: [Track] = []
    private var editEnabled = false
    private var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    private var fetchedResult: [Any]?
    
    private var recomendation: [Recomendation] = []
    
    //creating string variable to match it later (to not get missType) when reading and writing recommendations when taken from API, is stored in Core Data (as given in Exam paper)
    private let favoriteKey = "favoriteKey"
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        //setup tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        let tableViewNib = UINib(nibName: "FavoriteCell", bundle: nil)
        tableView.register(tableViewNib, forCellReuseIdentifier: "FavoriteCell")
        //setup collectioView
        collectionView.delegate = self
        collectionView.dataSource = self
        let collectionViewNib = UINib(nibName: "RecomendationCell", bundle: nil)
        collectionView.register(collectionViewNib, forCellWithReuseIdentifier: "RecomendationCell")
        
        //adding button to navBar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editMode))
    }
    //view will appear because data can change every time we open this window. viewDidLoad doesnt run because it is initial VC
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        editEnabled = false
        tableView.isEditing = false
    }
    
    @objc private func editMode() {
        editEnabled = !editEnabled
        tableView.isEditing = editEnabled
    }

    private func fetchData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            fetchedResult = result
            tracks = []
            for data in result as! [NSManagedObject] {
                tracks.append(Track(idTrack: data.value(forKey: "id") as! String,
                                            intDuration: data.value(forKey: "duration") as! String,
                                            strTrack: data.value(forKey: "title") as! String,
                                            strArtist: data.value(forKey: "artist") as! String))
            }
            tableView.reloadData()
            if hasher(tracks) != UserDefaults.standard.string(forKey: favoriteKey) {
                fetchRecomendation()
            }
        } catch {
            print("Failed")
        }
        
        let recomendRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recomendations")
        recomendRequest.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(recomendRequest)
            recomendation = []
            for data in result as! [NSManagedObject] {
                recomendation.append(Recomendation(Name: data.value(forKey: "title") as! String))
            }
            collectionView.reloadData()
        } catch {
            print("Failed")
        }
    }
    
    //fetching recommendations list when added/deleted/edited
    private func fetchRecomendation() {
        var url = "https://tastedive.com/api/similar?k=350381-PG5600Ex-J2C6SCFZ&q="
        
        //0$ signifies the first parameter passed into a Swift Closure.
        //Also fixes URL, because some songs spaces in between their names.
        tracks.forEach{ url = url + $0.strArtist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! + "%2C"}
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseData(completionHandler: { [weak self] response in
            guard let data = response.data, let `self` = self else { return }
            let decoder = JSONDecoder()
            do {
                let recomends = try decoder.decode(RecomendationResponse.self, from: data)
                self.recomendation = recomends.Similar.Results
                self.collectionView.reloadData()
                //store new hash only then recomendation has changed
                UserDefaults.standard.setValue(self.hasher(self.tracks), forKey: self.favoriteKey)
                self.saveRecomends()
            } catch {
                print(error.localizedDescription)
            }
        })
    }

    //saving recommendations
    private func saveRecomends() {
        recomendation.forEach { item in
            let entity = NSEntityDescription.entity(forEntityName: "Recomendations", in: context)
            let recomend = NSManagedObject(entity: entity!, insertInto: context)
            recomend.setValue(item.Name, forKey: "title")
            do {
                try context.save()
            } catch {
                print("Failed saving")
            }
        }
    }
    
    //Delete selected track from favourites
    
    func tappedDelete(_ track: Track) {
        let refreshAlert = UIAlertController(title: "Deletion", message: "Do you really want to delete \(track.strTrack) by \(track.strArtist)?", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction!) in
            guard let result = self.fetchedResult, let indexToDelete = self.tracks.firstIndex(of: track)
                else { return }
            self.context.delete(result[indexToDelete] as! NSManagedObject)
            do {
                try self.context.save()
                //removes from array then removed from core data
                self.tracks.remove(at: indexToDelete)
                self.tableView.reloadData()
                self.fetchRecomendation()
            } catch {
                print("Failed to delete")
            }
            print("Handle Ok logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    
    //hasher creates hash for every id as String. 0$ signifies the first parameter passed into a Swift Closure.
    private func hasher(_ tracks: [Track]) -> String {
        var hash = ""
        tracks.forEach { hash = hash + String($0.idTrack) }
        return hash
    }
}

extension FavoriteVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get a reference to our storyboard cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.setup(with: tracks[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete from your source, then update the tableView
            tappedDelete(tracks[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = tracks[sourceIndexPath.row]
        tracks.remove(at: sourceIndexPath.row)
        tracks.insert(itemToMove, at: destinationIndexPath.row)
    }
    
}

extension FavoriteVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recomendation.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecomendationCell", for: indexPath as IndexPath) as! RecomendationCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.setup(with: recomendation[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}

struct RecomendationResponse: Codable {
    let Similar: SimilarInfo
}

struct SimilarInfo: Codable {
    let Results: [Recomendation]
}

struct Recomendation: Codable {
    let Name: String
}
