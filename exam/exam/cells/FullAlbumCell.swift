//
//  FullAlbumCell.swift
//  exam
//
//  Created by Karolis Petkevicius on 30/11/2019.
//  Copyright © 2019 org. All rights reserved.
//

import UIKit
import Alamofire

final class FullAlbumCell: UICollectionViewCell {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var artistLabel: UILabel!
    
    func setup(with album: Album) {
        if let thumb = album.strAlbumThumb {
            //it would be nice to make this loading in VC or maybe cache image and later to use in albumVC
            Alamofire.request(thumb, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseData { [weak self] response in
                self?.imageView.image = UIImage(data: response.data!, scale: 1)
            }
        } else {
            imageView.image = UIImage(named: "placeholder")
            
        }
        titleLabel.text = album.strAlbum
        artistLabel.text = album.strArtist
    }
}
