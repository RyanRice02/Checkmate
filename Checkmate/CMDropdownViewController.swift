//
//  CMDropdownViewController.swift
//  Checkmate
//
//  Created by Ryan Rice on 1/17/17.
//  Copyright © 2017 Ryan Rice. All rights reserved.
//

import UIKit
import GameKit
import StoreKit
import AVFoundation

class CMDropdownViewController: UIViewController, UIScrollViewDelegate, GKGameCenterControllerDelegate, SKPaymentTransactionObserver {

	enum DropdownType {
		
		case Menu
		case Check
		case Game
		
	}
	
	@IBOutlet weak var titleLabel: UILabel!
	
	@IBOutlet weak var dropdownScrollView: UIScrollView!
	@IBOutlet weak var tipCardScrollView: UIScrollView!
	@IBOutlet weak var tipCardPageControl: UIPageControl!
	
	@IBOutlet weak var button1: CMButton!
	@IBOutlet weak var button2: CMButton!
	@IBOutlet weak var button3: CMButton!
	@IBOutlet weak var button4: CMButton!
	
	@IBOutlet weak var dropdownBackground: UIImageView!
	@IBOutlet weak var dropdownButton: UIButton!
	
	var dropdownType: DropdownType!
	
	var soundPlayer: AVAudioPlayer!
	
	let audioSession = AVAudioSession.sharedInstance()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		dropdownScrollView.contentSize = CGSize(width: dropdownScrollView.frame.width * 2, height: dropdownScrollView.frame.height)
		dropdownScrollView.delegate = self
		
		tipCardScrollView.contentSize = CGSize(width: tipCardScrollView.frame.width * 5, height: tipCardScrollView.frame.height)
		tipCardScrollView.delegate = self
		
		setButtons()
		prepareDropdown()
		setupSound()
		
		SKPaymentQueue.default().add(self)
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		animateDropdown()
		
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
	
	func prepareDropdown() {
		
		let translation = CGAffineTransform(translationX: 0, y: dropdownButton.frame.height - view.frame.height)
		
		titleLabel.transform = translation
		dropdownScrollView.transform = translation
		dropdownBackground.transform = translation
		
	}
	
	func animateDropdown() {
	
		UIView.animate(withDuration: 0.5, animations: {
			
			self.titleLabel.transform = CGAffineTransform.identity
			self.dropdownScrollView.transform = CGAffineTransform.identity
			self.dropdownBackground.transform = CGAffineTransform.identity
			
		})
	
	}
	
	func setButtons() {
	
		let sound = UserDefaults.standard.bool(forKey: "Sound") ? "Sound: On" : "Sound: Off"
		
		switch dropdownType! {
			
		case .Menu:
			
			showButtons(buttons: [button1, button2, button3, button4], labels: ["Leaderboard", sound, "Tips", "Restore"])
			
		case .Check:
			
			showButtons(buttons: [button1, button2, button3, button4], labels: ["Leaderboard", sound, "Restore", "Menu"])
			
		case .Game:
			
			showButtons(buttons: [button1, button2, button3, button4], labels: ["Leaderboard", sound, "Tips", "Quit"])
			
		}
	
	}
	
	func showButtons(buttons: [UIButton], labels: [String]) {
	
		for button in buttons {
			
			button.setTitle(labels[buttons.index(of: button)!], for: .normal)
			button.isEnabled = true
			button.alpha = 1
			
		}
	
	}
	
	func hideButtons(buttons: [UIButton]) {
	
		for button in buttons {
			
			button.setTitle("", for: .normal)
			button.isEnabled = false
			button.alpha = 0
			
		}
	
	}

	@IBAction func triggerButton(_ sender: UIButton) {
	
		switch sender.titleLabel!.text! {
			
		case "Leaderboard":
			
			let vc = GKGameCenterViewController()
			
			vc.gameCenterDelegate = self
			vc.viewState = .leaderboards
			vc.leaderboardIdentifier = "Endless"
			
			present(vc, animated: true, completion: nil)
			
		case "Sound: On":
			
			UserDefaults.standard.set(false, forKey: "Sound")

			sender.setTitle("Sound: Off", for: .normal)

			toggleMusic()
			
		case "Sound: Off":
			
			UserDefaults.standard.set(true, forKey: "Sound")
			
			sender.setTitle("Sound: On", for: .normal)
			
			toggleMusic()
			
		case "Tips":
			
			dropdownScrollView.scrollRectToVisible(CGRect(x: dropdownScrollView.frame.width, y: 0, width: dropdownScrollView.frame.width, height: dropdownScrollView.frame.height), animated: true)
			
		case "Tutorial":
			
			UserDefaults.standard.set(false, forKey: "Tutorial Complete")
			
			(presentingViewController as! CMGameViewController).resetGame()
			
			dismissDropdown(self)
			
		case "Restore":
			
			SKPaymentQueue.default().restoreCompletedTransactions()
			
		case "Menu":
			
			presentingViewController!.presentingViewController!.dismiss(animated: false, completion: nil)
			
		case "Back":
			
			dropdownScrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: dropdownScrollView.frame.width, height: dropdownScrollView.frame.height), animated: true)
			
		case "Quit":
			
			let vc = storyboard?.instantiateViewController(withIdentifier: "CMLoadingViewController") as! CMLoadingViewController
			var presentvc: UIViewController = self
			
			while !(presentvc is CMMenuViewController) {
			
				presentvc = presentvc.presentingViewController!
			
			}
			
			vc.destination = presentvc
			
			present(vc, animated: false, completion: nil)
		
		default:
			break
			
		}
	
	}
	
	@IBAction func dismissDropdown(_ sender: Any) {
	
		let translation = CGAffineTransform(translationX: 0, y: dropdownButton.frame.height - view.frame.height)
		
		UIView.animate(withDuration: 0.5, animations: {
			
			self.titleLabel.transform = translation
			self.dropdownScrollView.transform = translation
			self.dropdownBackground.transform = translation
			
		}, completion: {(Bool) in
			
			self.dismiss(animated: false, completion: nil)
			
		})
		
	}
	
	@IBAction func buttonDown(_ sender: UIButton) {
		
		let downImage = sender.tag == 1 ? #imageLiteral(resourceName: "Button White Down") : #imageLiteral(resourceName: "Logo Bar Blue Down")
		
		sender.setBackgroundImage(downImage, for: .normal)
		sender.titleEdgeInsets.top += CGFloat(Int(sender.frame.height / 6))
		
		playSound()
		
	}
	
	@IBAction func buttonUp(_ sender: UIButton) {
		
		let upImage = sender.tag == 1 ? #imageLiteral(resourceName: "Button White") : #imageLiteral(resourceName: "Logo Bar Blue")
		
		sender.setBackgroundImage(upImage, for: .normal)
		sender.titleEdgeInsets.top -= CGFloat(Int(sender.frame.height / 6))
		
	}
	
	func toggleMusic() {
		
		if audioSession.isOtherAudioPlaying {
			return
		}
	
		var vc = presentingViewController
		
		while !(vc is CMMenuViewController) {
	
			vc = vc!.presentingViewController
			
		}
		
		(vc as! CMMenuViewController).playMusic()
		
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		if scrollView == tipCardScrollView {
			
			let cardIndex = Int(tipCardScrollView.contentOffset.x / tipCardScrollView.bounds.size.width + 0.5)
			
			tipCardPageControl.currentPage = cardIndex
			
		}
		
	}
	
	func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
		
		gameCenterViewController.dismiss(animated: true, completion: nil)
		
	}
	
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		
		for transaction in transactions {

			SKPaymentQueue.default().finishTransaction(transaction)

		}
		
	}
	
	func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
		
		var unlocked = Set(UserDefaults.standard.object(forKey: "Unlocked Flags") as? [Int] ?? [0])
		
		for _ in queue.transactions {
			
			unlocked.insert(5)
			
			UserDefaults.standard.set(Array(unlocked), forKey: "Unlocked Flags")
			
		}
		
		let restoreAlert = UIAlertController(title: "Restore", message: "Restore Successful", preferredStyle: .alert)
		
		if queue.transactions.isEmpty {
			
				restoreAlert.message = "No Purchases To Restore"
			
		}
		
		restoreAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
			
			restoreAlert.dismiss(animated: true, completion: nil)
			
		}))
		
		present(restoreAlert, animated: true, completion: nil)
		
	}
	
	func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
		
		let restoreAlert = UIAlertController(title: "Restore", message: "Restore Failed", preferredStyle: .alert)
		
		restoreAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
			
			restoreAlert.dismiss(animated: true, completion: nil)
			
		}))
		
		present(restoreAlert, animated: true, completion: nil)
		
	}
	
}
