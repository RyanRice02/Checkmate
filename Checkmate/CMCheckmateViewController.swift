//
//  CMCheckmateViewController.swift
//  Checkmate
//
//  Created by Ryan Rice on 1/15/17.
//  Copyright © 2017 Ryan Rice. All rights reserved.
//

import UIKit
import GameKit

class CMCheckmateViewController: UIViewController, GKGameCenterControllerDelegate {
	
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var bestLabel: UILabel!
	
	@IBOutlet weak var playagainButton: UIButton!
	@IBOutlet weak var menuButton: UIButton!
	@IBOutlet weak var leaderboardButton: CMButton!
	
	var score = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		var best = false
		
		if score > UserDefaults.standard.integer(forKey: "Best Score") {
		
			UserDefaults.standard.set(score, forKey: "Best Score")
			best = true
			
		}
		
		UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "All-Time Captures") + score, forKey: "All-Time Captures")
		
		scoreLabel.text = "Score \(score)"
		bestLabel.text = best ? "New Best Score" : "Best \(UserDefaults.standard.integer(forKey: "Best Score"))"
		
		postScore()
		postCaptures()
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "CMLoadMenuSegue" {
			
			let vc = segue.destination as! CMLoadingViewController
			
			vc.destination = presentingViewController!.presentingViewController!.presentingViewController!
			
		} else if segue.identifier == "CMLoadGameSegue" {
		
			let vc = segue.destination as! CMLoadingViewController
			
			vc.destination = presentingViewController!
		
		}
		
	}
	
	func postScore() {
	
		let bestScore = GKScore(leaderboardIdentifier: "Endless")
		
		bestScore.value = Int64(UserDefaults.standard.integer(forKey: "Best Score"))
		
		GKScore.report([bestScore]) { (Error) in
			
		}
	
	}
	
	func postCaptures() {
		
		let alltimeCaptures = GKScore(leaderboardIdentifier: "AllTimeCaptures")
		
		alltimeCaptures.value = Int64(UserDefaults.standard.integer(forKey: "All-Time Captures"))
		
		GKScore.report([alltimeCaptures]) { (Error) in
			
		}
		
	}
	
	@IBAction func showLeaderboard(_ sender: Any) {
	
		let vc = GKGameCenterViewController()
		
		vc.gameCenterDelegate = self
		vc.viewState = .leaderboards
		vc.leaderboardIdentifier = "Endless"
		
		present(vc, animated: true, completion: nil)
	
	}
	
	func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
		
		gameCenterViewController.dismiss(animated: true, completion: nil)
		
	}

}
