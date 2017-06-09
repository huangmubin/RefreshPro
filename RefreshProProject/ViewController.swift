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
    var linses = 5
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let footer = RefreshView_Footer_Simple()
        footer.delegate = self
        tableview.addSubview(footer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Action
    
    @IBAction func action(_ sender: UIButton) {
        if let status = self.tableview.refresh_header()?.status {
            switch status {
            case .refreshing:
                UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    self.linses = 5
                    self.tableview.reloadData()
                }, completion: { _ in
                    self.tableview.refresh_header()?.status_set(refreshed: true, data: nil)
                })
            default:
                break
            }
        }
        if let status = self.tableview.refresh_footer()?.status {
            switch status {
            case .refreshing:
                UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    self.linses += 5
                    self.tableview.reloadData()
                }, completion: { _ in
                    self.tableview.refresh_footer()?.status_set(refreshed: true, data: nil)
                })
            default:
                break
            }
        }
    }
    
}

// MARK: - RefreshView_Delegate

extension ViewController: RefreshView_Delegate {
    
    func refreshView(view: RefreshView, identifier: String) {
//        DispatchQueue.global().async {
//            Thread.sleep(forTimeInterval: 3)
//            DispatchQueue.main.async {
//                self.tableview.refresh_header()?.status_set(refreshed: true, data: nil)
//            }
//        }
    }
    
}

// MAKR: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linses
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
