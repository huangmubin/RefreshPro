//
//  ViewController.swift
//  RefreshPro
//
//  Created by Myron on 2017/6/7.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Action
    
    @IBAction func action(_ sender: UIButton) {
        
    }
    
}

// MAKR: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath
        )
        cell.textLabel?.text = "Cell in Section: \(indexPath.section), Row: \(indexPath.row)"
        return cell
    }
    
}

// MAKR: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
}
