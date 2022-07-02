//
//  FavTableViewCell.swift
//  MuseosCyL
//
//  Created by RAQUEL CHAMORRO GIGANTO on 24/09/2021.
//

import UIKit

class FavTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
