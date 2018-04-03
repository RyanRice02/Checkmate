//
//  CMUnlockView.swift
//  Checkmate
//
//  Created by Ryan Rice on 1/17/17.
//  Copyright © 2017 Ryan Rice. All rights reserved.
//

import UIKit
import StoreKit

@IBDesignable

class CMUnlockView: UIView, SKProductsRequestDelegate, SKPaymentTransactionObserver {
	
	@IBOutlet weak var backgroundBlur: UIVisualEffectView!
	@IBOutlet weak var alertTitle: UILabel!
	
	@IBOutlet weak var alertMessage: UILabel!
	@IBOutlet weak var alertMessageImage: UIImageView!
	
	@IBOutlet weak var alertCost: UILabel!
	@IBOutlet weak var alertCostSubtitle: UILabel!
	
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var unlockButton: UIButton!
	
	@IBOutlet weak var capturesLabel: UILabel!
	
	var unlockIndex: Int!
	var unlockType: String!
	var presentingViewController: CMCheckViewController!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		xibSetup()
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		xibSetup()
		
	}
	
	func xibSetup() {
		
		var view: UIView!
		
		view = loadViewFromNib()
		view.frame = bounds
		view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		self.addSubview(view)
	
		backgroundBlur.layer.cornerRadius = backgroundBlur.frame.height / 18
		backgroundBlur.layer.masksToBounds = true
	
		SKPaymentQueue.default().add(self)
		
	}
	
	func loadViewFromNib() -> UIView {
		
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: "CMUnlockView", bundle: bundle)
		let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		
		return view
		
	}
	
	func show(title: String, message: String, image: UIImage, cost: Int) {
		
		cancelButton.isEnabled = true
		
		if cost < 0 {
			
			unlockButton.isEnabled = true
			unlockButton.titleLabel?.alpha = 1
			unlockButton.setTitle("Buy", for: .normal)
			
			alertCost.text = "Cost To Unlock"
			alertCostSubtitle.text = "$0.99"
			
		} else {
			
			unlockButton.setTitle("Unlock", for: .normal)
			
			alertCost.text = "Required Captures\nFor Unlock"
			alertCostSubtitle.text = "\(cost)"
			
			if UserDefaults.standard.integer(forKey: "Captures") >= cost {
				
				unlockButton.isEnabled = true
				unlockButton.titleLabel?.alpha = 1
				
			} else {
				
				unlockButton.titleLabel?.alpha = 0.25
				
			}
			
		}
		
		alertTitle.text = title
		alertMessage.text = message
		alertMessageImage.image = image
		
		capturesLabel.text = "Captures: \(UserDefaults.standard.integer(forKey: "Captures"))"
		
		self.alpha = 1
		self.superview?.bringSubview(toFront: self)

	}
	
	func hide() {
	
		cancelButton.isEnabled = false
		unlockButton.isEnabled = false
	
		self.alpha = 0
		self.superview?.sendSubview(toBack: self)
		
	}
	
	@IBAction func cancel(_ sender: Any) {
	
		hide()
		
	}
	
	@IBAction func unlock(_ sender: Any) {
		
		var unlocked = Set(UserDefaults.standard.object(forKey: "Unlocked \(unlockType!)") as! [Int])
		
		if Int(alertCostSubtitle.text!) != nil {
			
			unlocked.insert(unlockIndex!)
			
			UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "Captures") - Int(alertCostSubtitle.text!)!, forKey: "Captures")
			UserDefaults.standard.set(Array(unlocked), forKey: "Unlocked \(unlockType!)")
		
			presentingViewController.updateUnlocks()
						
		} else {
			
			if SKPaymentQueue.canMakePayments() {
				
				let productIdentifiers: Set<String> = ["CH.WF"]
				let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
				
				productRequest.delegate = self
				productRequest.start()
				
			} else {
			
				hide()
			
			}
			
		}
		
		hide()
		
	}
	
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		
		let payment = SKPayment(product: response.products[0])
		
		SKPaymentQueue.default().add(payment)
		
	}
	
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		
		if unlockType == nil {
			return
		}
		
		var unlocked = Set(UserDefaults.standard.object(forKey: "Unlocked \(unlockType!)") as! [Int])
		
		for transaction in transactions {
		
			SKPaymentQueue.default().finishTransaction(transaction)
			
			switch transaction.transactionState {
				
			case .purchased:
				
				unlocked.insert(unlockIndex!)
				
				UserDefaults.standard.set(Array(unlocked), forKey: "Unlocked \(unlockType!)")
				
				presentingViewController.updateUnlocks()
				
			default:
				hide()
			
			}
		
		}
		
	}
	
}
