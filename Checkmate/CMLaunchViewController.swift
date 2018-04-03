//
//  CMLaunchViewController.swift
//  Checkmate
//
//  Created by Ryan Rice on 1/15/17.
//  Copyright © 2017 Ryan Rice. All rights reserved.
//

import UIKit
import GameKit

class CMLaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
	
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		if UserDefaults.standard.bool(forKey: "Tutorial Complete") == false {
		
			UserDefaults.standard.set(true, forKey: "Sound")
		
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
		
			self.authenticateLocalPlayer()
			
		}
		
	}
	
	func authenticateLocalPlayer() {
		
		let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
		
		localPlayer.authenticateHandler = {(ViewController, error) -> Void in
			
			self.performSegue(withIdentifier: "CMLaunchSegue", sender: nil)
			
		}
		
	}
	
}
