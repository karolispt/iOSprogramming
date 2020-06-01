//
//  RecomendationCell.swift
//  exam
//
//  Created by Karolis Petkevicius on 01/12/2019.
//  Copyright © 2019 org. All rights reserved.
//

import UIKit

final class RecomendationCell: UICollectionViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    
    func setup(with recomend: Recomendation) {
        titleLabel.text = recomend.Name
    }
    
}
