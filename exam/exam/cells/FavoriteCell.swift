//
//  FavoriteCell.swift
//  exam
//
//  Created by Karolis Petkevicius on 01/12/2019.
//  Copyright © 2019 org. All rights reserved.
//

import UIKit

final class FavoriteCell: UITableViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var artistLabel: UILabel!
    @IBOutlet private var durationLabel: UILabel!

    func setup(with track: Track) {
        titleLabel.text = track.strTrack
        artistLabel.text = track.strArtist
        durationLabel.text = track.subtitle
    }
}
