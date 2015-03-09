//
//  ViewController.swift
//  SwiftRefreshControl
//
//  Created by Zr on 15/3/9.
//  Copyright (c) 2015年 Tarol. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

    }
    
    @IBAction func loadData(sender: UIRefreshControl) {
        
        // 主动开始加载数据
        refreshControl?.beginRefreshing()
        
    }
    

}

