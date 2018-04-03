//
//  CMCheckViewController.swift
//  Checkmate
//
//  Created by Ryan Rice on 1/15/17.
//  Copyright © 2017 Ryan Rice. All rights reserved.
//

import UIKit
import AVFoundation
import GameKit

class CMCheckViewController: UIViewController, UIScrollViewDelegate {

	@IBOutlet weak var flagScrollView: UIScrollView!
	@IBOutlet weak var pieceScrollView: UIScrollView!
	
	@IBOutlet weak var checkButton: CMButton!
	
	@IBOutlet weak var unlockAlert: CMUnlockView!
	
	let blueImages = [#imageLiteral(resourceName: "Piece Pawn Blue Token"), #imageLiteral(resourceName: "Piece Knight Blue Token"), #imageLiteral(resourceName: "Piece Bishop Blue Token"), #imageLiteral(resourceName: "Piece Rook Blue Token"), #imageLiteral(resourceName: "Piece Queen Blue Token")]
	let redImages = [#imageLiteral(resourceName: "Piece Pawn Red Token"), #imageLiteral(resourceName: "Piece Knight Red Token"), #imageLiteral(resourceName: "Piece Bishop Red Token"), #imageLiteral(resourceName: "Piece Rook Red Token"), #imageLiteral(resourceName: "Piece Queen Red Token")]
	let greenImages = [#imageLiteral(resourceName: "Piece Pawn Green Token"), #imageLiteral(resourceName: "Piece Knight Green Token"), #imageLiteral(resourceName: "Piece Bishop Green Token"),  #imageLiteral(resourceName: "Piece Rook Green Token"), #imageLiteral(resourceName: "Piece Queen Green Token")]
	let purpleImages = [#imageLiteral(resourceName: "Piece Pawn Purple Token"), #imageLiteral(resourceName: "Piece Knight Purple Token"), #imageLiteral(resourceName: "Piece Bishop Purple Token"), #imageLiteral(resourceName: "Piece Rook Purple Token"), #imageLiteral(resourceName: "Piece Queen Purple Token")]
	let yellowImages = [#imageLiteral(resourceName: "Piece Pawn Yellow Token"), #imageLiteral(resourceName: "Piece Knight Yellow Token"), #imageLiteral(resourceName: "Piece Bishop Yellow Token"), #imageLiteral(resourceName: "Piece Rook Yellow Token"), #imageLiteral(resourceName: "Piece Queen Yellow Token")]
	let whiteImages = [#imageLiteral(resourceName: "Piece Pawn White Token"), #imageLiteral(resourceName: "Piece Knight White Token"), #imageLiteral(resourceName: "Piece Bishop White Token"), #imageLiteral(resourceName: "Piece Rook White Token"), #imageLiteral(resourceName: "Piece Queen White Token")]
	let blackImages = [#imageLiteral(resourceName: "Piece Pawn Black Token"), #imageLiteral(resourceName: "Piece Knight Black Token"), #imageLiteral(resourceName: "Piece Bishop Black Token"), #imageLiteral(resourceName: "Piece Rook Black Token"), #imageLiteral(resourceName: "Piece Queen Black Token")]
	
	var images: [[UIImage]]!
	
	let flags = [("Red", #imageLiteral(resourceName: "Flag Red"), 25), ("Green", #imageLiteral(resourceName: "Flag Green"), 100), ("Purple", #imageLiteral(resourceName: "Flag Purple"), 250), ("Yellow", #imageLiteral(resourceName: "Flag Yellow"), 500), ("White", #imageLiteral(resourceName: "Flag White"), -1)]
	let pieces =  [("Knight", #imageLiteral(resourceName: "Move Pattern Knight"), 10), ("Bishop", #imageLiteral(resourceName: "Move Pattern Bishop"), 100), ("Rook", #imageLiteral(resourceName: "Move Pattern Rook"), 500), ("Queen", #imageLiteral(resourceName: "Move Pattern Queen"), 2000)]
	
	var unlockedFlags = Set(UserDefaults.standard.object(forKey: "Unlocked Flags") as? [Int] ?? [0])
	var unlockedPieces = Set(UserDefaults.standard.object(forKey: "Unlocked Pieces") as? [Int] ?? [0])
	
	var soundPlayer: AVAudioPlayer!
	
	let audioSession = AVAudioSession.sharedInstance()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if UserDefaults.standard.bool(forKey: "Black") == true {
			
			unlockedFlags.insert(6)
			
		} else {
		
			flagScrollView.subviews[6].removeFromSuperview()
		
		}
		
		flagScrollView.contentSize = CGSize(width: flagScrollView.frame.width * CGFloat(flagScrollView.subviews.count), height: flagScrollView.frame.height)
		
		pieceScrollView.contentSize = CGSize(width: pieceScrollView.frame.width * CGFloat(pieceScrollView.subviews.count), height: pieceScrollView.frame.height)
		
		flagScrollView.delegate = self
		pieceScrollView.delegate = self
		
		images = [blueImages, redImages, greenImages, purpleImages, yellowImages, whiteImages, blackImages]
		
		UserDefaults.standard.set(Array(unlockedFlags), forKey: "Unlocked Flags")
		UserDefaults.standard.set(Array(unlockedPieces), forKey: "Unlocked Pieces")
		
		if let userCheck = UserDefaults.standard.object(forKey: "User Check") as? [CGFloat] {
			
			flagScrollView.setContentOffset(CGPoint(x: flagScrollView.frame.width * (userCheck[0]), y: 0), animated: false)
			pieceScrollView.setContentOffset(CGPoint(x: pieceScrollView.frame.width * (userCheck[1]), y: 0), animated: false)
			
		}
		
		updateUnlocks()
		
		unlockAlert.presentingViewController = self
		unlockAlert.hide()
		
		setupSound()
		
	}
	
	func setupSound() {
		
		do {
			
			let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "rollover2", ofType: "wav")!)
			
			soundPlayer = try AVAudioPlayer(contentsOf: sound)
			soundPlayer.numberOfLoops = 1
			soundPlayer.prepareToPlay()
			
		} catch {}
		
	}
	
	func playSound() {
		
		if audioSession.isOtherAudioPlaying {
			return
		}
		
		if UserDefaults.standard.bool(forKey: "Sound") {
			
			soundPlayer.play()
			
		} else {
			
			soundPlayer.stop()
			
		}
		
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		let flagIndex = Int(flagScrollView.contentOffset.x / flagScrollView.bounds.size.width + 0.5)
		let pieceIndex = Int(pieceScrollView.contentOffset.x / pieceScrollView.bounds.size.width + 0.5)
		
		if scrollView == flagScrollView {
			
			for i in 0..<images[flagIndex].count {
				
				(pieceScrollView.subviews[i] as! UIButton).setBackgroundImage(images[flagIndex][i], for: .normal)
				
				if !unlockedFlags.contains(flagIndex) {
					
					pieceScrollView.subviews[i].alpha = 0.25
					
				} else if unlockedPieces.contains(i) {
					
					pieceScrollView.subviews[i].alpha = 1
					
				}
				
			}
			
		}
		
		if unlockedFlags.contains(flagIndex) && unlockedPieces.contains(pieceIndex) {
		
			checkButton.isEnabled = true
			checkButton.titleLabel?.alpha = 1
		
		} else {
		
			checkButton.isEnabled = false
			checkButton.titleLabel?.alpha = 0.5
			
		}
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "CMGameSegue" {
			
			let vc = segue.destination as! CMGameViewController
			
			let flagIndex = Int(flagScrollView.contentOffset.x / flagScrollView.bounds.size.width)
			let pieceIndex = Int(pieceScrollView.contentOffset.x / pieceScrollView.bounds.size.width)
			
			let flag = flagIndex == 0 ? "Blue" : flagIndex == 1 ? "Red" : flagIndex == 2 ? "Green" : flagIndex == 3 ? "Purple" : flagIndex == 4 ? "Yellow" : flagIndex == 5 ? "White" : "Black"
			let piece: CMGameSquare.SquarePiece = pieceIndex == 0 ? .Pawn : pieceIndex == 1 ? .Knight : pieceIndex == 2 ? .Bishop : pieceIndex == 3 ? .Rook : .Queen
			
			vc.game.setUserColor(color: flag)
			vc.game.setUserType(type: piece)
			
			UserDefaults.standard.set([flagIndex, pieceIndex], forKey: "User Check")
			
		} else if segue.identifier == "CMCheckDropdownSegue" {
			
			let vc = segue.destination as! CMDropdownViewController
			
			vc.dropdownType = .Check
			
		}
		
	}
	
	@IBAction func unlockablePressed(_ sender: UIButton) {
		
		let flagIndex = Int(flagScrollView.contentOffset.x / flagScrollView.bounds.size.width)
		let pieceIndex = Int(pieceScrollView.contentOffset.x / pieceScrollView.bounds.size.width)
		
		if sender.superview == flagScrollView && !unlockedFlags.contains(flagIndex) {
			
			unlockAlert.show(title: flags[flagIndex - 1].0, message: "Flag", image: flags[flagIndex - 1].1, cost: flags[flagIndex - 1].2)
			
			unlockAlert.unlockIndex = flagIndex
			unlockAlert.unlockType = "Flags"
			
		} else if sender.superview == pieceScrollView && !unlockedPieces.contains(pieceIndex) {
		
			unlockAlert.show(title: pieces[pieceIndex - 1].0, message: "Move Pattern", image: pieces[pieceIndex - 1].1, cost: pieces[pieceIndex - 1].2)
		
			unlockAlert.unlockIndex = pieceIndex
			unlockAlert.unlockType = "Pieces"
			
		}
		
	}
	
	func updateUnlocks() {
	
		let flagIndex = Int(flagScrollView.contentOffset.x / flagScrollView.bounds.size.width)
		let pieceIndex = Int(pieceScrollView.contentOffset.x / pieceScrollView.bounds.size.width)
		
		unlockedFlags = Set(UserDefaults.standard.object(forKey: "Unlocked Flags") as? [Int] ?? [0])
		unlockedPieces = Set(UserDefaults.standard.object(forKey: "Unlocked Pieces") as? [Int] ?? [0])
	
		for i in 0..<flagScrollView.subviews.count {
			
			if !unlockedFlags.contains(i) {
				
				flagScrollView.subviews[i].alpha = 0.25
				
			} else {
				
				flagScrollView.subviews[i].alpha = 1
				
			}
			
		}
		
		for i in 0..<pieceScrollView.subviews.count {
			
			if !unlockedPieces.contains(i) || !unlockedFlags.contains(flagIndex) {
				
				pieceScrollView.subviews[i].alpha = 0.25
				
			} else {
			
				pieceScrollView.subviews[i].alpha = 1
			
			}
			
		}
		
		if unlockedFlags.contains(flagIndex) && unlockedPieces.contains(pieceIndex) {
			
			checkButton.isEnabled = true
			checkButton.titleLabel?.alpha = 1
			
		} else {
			
			checkButton.isEnabled = false
			checkButton.titleLabel?.alpha = 0.5
			
		}
		
		checkAchievements()
		
	}
	
	
	
	func checkAchievements() {
		
		if unlockAlert.unlockType == nil {
			return
		}
		
		var achievements = [GKAchievement]()
		
		switch unlockAlert.unlockType! {
			
		case "Flags":
			
			let a = GKAchievement(identifier: "ForKingAndCountry")
			
			a.percentComplete = 100
			a.showsCompletionBanner = true
			
			if !a.isCompleted {
				
				achievements.append(a)
				
			}
			
		case "Pieces":
			
			let a = GKAchievement(identifier: "FirePower")
			
			a.percentComplete = 100
			a.showsCompletionBanner = true
			
			if !a.isCompleted {
				
				achievements.append(a)
				
			}
			
		default:
			break
			
		}
		
		GKAchievement.report(achievements) { (Error) in
			
		}
		
	}
	
	@IBAction func buttonDown(_ sender: UIButton) {
		
		let downImage = sender.tag == 1 ? #imageLiteral(resourceName: "Button Blue Down") : #imageLiteral(resourceName: "Logo Bar Blue Down")
		
		sender.setBackgroundImage(downImage, for: .normal)
		sender.titleEdgeInsets.top += CGFloat(Int(sender.frame.height / 6))
		
		playSound()
		
	}
	
	@IBAction func buttonUp(_ sender: UIButton) {
		
		let upImage = sender.tag == 1 ? #imageLiteral(resourceName: "Button Blue") : #imageLiteral(resourceName: "Logo Bar Blue")
		
		sender.setBackgroundImage(upImage, for: .normal)
		sender.titleEdgeInsets.top -= CGFloat(Int(sender.frame.height / 6))
		
	}
	
}
