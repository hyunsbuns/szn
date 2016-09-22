//
//  GameStatsSummaryTVC.swift
//  Squad
//
//  Created by Steve on 2/24/16.
//  Copyright © 2016 squad. All rights reserved.
//

import UIKit

class GameStatsSummaryTVC: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 250)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return SquadCore.selectedSquadRoster.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameStatsSummaryTableViewCell
        
        // Configure the cell...
        //cell.scrollContainer = SquadCore.storyBoard.instantiateViewControllerWithIdentifier("ScrollContainerVC") as! ScrollContainerVC
        //cell.scrollContainerPlaceHolder.addSubview(cell.scrollContainer.view)
        
        let player = SquadCore.selectedSquadRoster[(indexPath as NSIndexPath).row]
        
        
        cell.nameLabel.text = "\(player.value(forKey: "firstName") as! String) \(player.value(forKey: "lastName") as! String)"
        return cell
    }
}
