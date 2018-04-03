//
//  CMLoadingViewController.swift
//  Checkmate
//
//  Created by Ryan Rice on 1/15/17.
//  Copyright © 2017 Ryan Rice. All rights reserved.
//

import UIKit

class CMLoadingViewController: UIViewController {

	@IBOutlet weak var loadScreen: UIImageView!
	
	let loadScreens = [#imageLiteral(resourceName: "Load Screen Red"), #imageLiteral(resourceName: "Load Screen Red 2"), #imageLiteral(resourceName: "Load Screen Blue"), #imageLiteral(resourceName: "Load Screen Blue 2"), #imageLiteral(resourceName: "Load Screen Green"), #imageLiteral(resourceName: "Load Screen Green 2"), #imageLiteral(resourceName: "Load Screen Purple"), #imageLiteral(resourceName: "Load Screen Purple 2")]
	
	var destination = UIViewController()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		loadScreen.image = loadScreens[Int(arc4random_uniform(UInt32(loadScreens.count)))]
	
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		if destination is CMGameViewController {
		
			(destination as! CMGameViewController).resetGame()
		
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
		
			self.destination.dismiss(animated: false, completion: nil)
			
		}
		
	}

}
