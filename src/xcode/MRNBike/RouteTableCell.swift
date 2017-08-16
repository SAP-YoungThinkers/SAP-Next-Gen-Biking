//
//  RouteTableCell.swift
//  MRNBike
//
//  Created by Huyen Nguyen on 27.07.17.
//
//

import UIKit

class RouteTableCell: UITableViewCell {
    
    @IBOutlet weak var rtDate: UILabel!
    @IBOutlet weak var rtTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
