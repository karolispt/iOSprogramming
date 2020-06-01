//
//  AlbumVC.swift
//  exam
//
//  Created by Karolis Petkevicius on 30/11/2019.
//  Copyright © 2019 org. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

final class AlbumVC: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var artistLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var yearLabel: UILabel!
    
    private var tracks: [Track] = []
    
    var album: Album!
    
    override func viewDidLoad() {
        artistLabel.text = album.strArtist
        titleLabel.text = album.strAlbum
        yearLabel.text = album.intYearReleased
        tableView.delegate = self
        tableView.dataSource = self
        fetchData()
        let nib = UINib(nibName: "SongCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SongCell")
        tableView.tableFooterView = UIView()
         navigationItem.backBarButtonItem?.title = "Back"
    }
    
    
    private func fetchData() {
        if let thumb = album.strAlbumThumb {
            Alamofire.request(thumb, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseData { [weak self] response in
                self?.imageView.image = UIImage(data: response.data!, scale: 1)
            }
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
        
        Alamofire.request("https://www.theaudiodb.com/api/v1/json/1/track.php?m=&m=\(album.idAlbum)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseData(completionHandler: { [weak self] response in
            guard let data = response.data, let `self` = self else { return }
            let decoder = JSONDecoder()
            do {
                let tracks = try decoder.decode(TracksResponse.self, from: data)
                self.tracks = tracks.track
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                self.tableView.heightAnchor.constraint(equalToConstant: self.tableView.contentSize.height/2).isActive = true
            } catch {
                print(error.localizedDescription)
            }
        })
    }
    //write to coreData
    private func addTofavorite(_ trackObject: Track) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Favorites", in: context)
        let track = NSManagedObject(entity: entity!, insertInto: context)
        track.setValue(trackObject.idTrack, forKey: "id")
        track.setValue(trackObject.strTrack, forKey: "title")
        track.setValue(trackObject.intDuration, forKey: "duration")
        track.setValue(trackObject.strArtist, forKey: "artist")
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
}

extension AlbumVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
        
        cell.setup(with: tracks[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        addTofavorite(tracks[indexPath.row])

        //pushing alert to notify about added sucessfully
        let refreshAlert = UIAlertController(title: "****", message: "\(tracks[indexPath.row].strTrack) added to favorites", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
}

struct TracksResponse: Codable {
    let track: [Track]
}

struct Track: Codable, Equatable, SimpleCell {
    var title: String {
        return strTrack
    }
    
    var subtitle: String {
        var seconds = String(intDur % 60)
        //append 0 at the end if needed
        seconds = seconds.count > 1 ? seconds + "" : seconds + "0"
        return String("\(intDur / 60):\(seconds)")
    }
    let idTrack: String
    let intDuration: String
    let strTrack: String
    let strArtist: String
    
    var intDur: Int {
        return (Int(intDuration) ?? 0) / 1000
    }
}
//protocol used to reuse same tableCell file
protocol SimpleCell {
    var title: String { get }
    var subtitle: String { get }
}
