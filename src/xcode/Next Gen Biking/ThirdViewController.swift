//
//  ThirdViewController.swift
//  Next Gen Biking
//
//  Created by Marc Bormeth on 16.12.16.
//  Copyright © 2016 Marc Bormeth. All rights reserved.
//

import UIKit

class ThirdViewController: UITableViewController {
    
    @IBOutlet var tView: UITableView!
    @IBOutlet weak var languageCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
