//
//  ViewController.swift
//  SporeNetworking
//
//  Created by loohawe@gamil.com on 08/02/2017.
//  Copyright (c) 2017 loohawe@gamil.com. All rights reserved.
//

import UIKit
import SporeNetworking

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var loadArea: MogoAPIs.HotBusinessAreaAPI = MogoAPIs.HotBusinessAreaAPI.init()
//        loadArea.isMock = true
        
        Spore.send(loadArea) { result in
            switch result {
            case .success(let user):
                print("\(user)")
            case .failure(let sessionError):
                print("\(sessionError)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

