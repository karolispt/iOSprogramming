//
//  SongCell.swift
//  exam
//
//  Created by Karolis Petkevicius on 30/11/2019.
//  Copyright © 2019 org. All rights reserved.
//

import UIKit

final class SongCell: UITableViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    
    func setup(with data: SimpleCell) {
        titleLabel.text = data.title
        timeLabel.text = data.subtitle
    }
}
