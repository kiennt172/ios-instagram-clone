//
//  SearchVC.swift
//  InstagramClone
//
//  Created by Nguyen Trung Kien on 5/23/20.
//  Copyright © 2020 Nguyen Trung Kien. All rights reserved.
//

import UIKit

private let searchCellId = "searchCellId"
class SearchVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(SearchUserCell.self, forCellReuseIdentifier: searchCellId)
        
        configTitle()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchCellId, for: indexPath) as! SearchUserCell
        return cell
    }

    
    // MARK: - func
    func configTitle() {
        self.navigationItem.title = "Explore"
    }
    

}
