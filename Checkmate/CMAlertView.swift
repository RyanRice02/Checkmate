//
//  CMAlertView.swift
//  Checkmate
//
//  Created by Ryan Rice on 1/21/17.
//  Copyright © 2017 Ryan Rice. All rights reserved.
//

import UIKit

@IBDesignable

class CMAlertView: UIView {
	
	@IBOutlet weak var backgroundBlur: UIVisualEffectView!
	@IBOutlet weak var alertTitle: UILabel!
	
	@IBOutlet weak var alertMessage: UILabel!
	@IBOutlet weak var alertSubtitle: UILabel!
	
	@IBOutlet weak var dismissButton: UIButton!
		
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
		
	}
	
	func loadViewFromNib() -> UIView {
		
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: "CMAlertView", bundle: bundle)
		let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		
		return view
		
	}
	
	func show() {
		
		dismissButton.isEnabled = true
		
		self.alpha = 1
		self.superview?.bringSubview(toFront: self)
		
	}
	
	func hide() {
		
		dismissButton.isEnabled = false
		
		self.alpha = 0
		self.superview?.sendSubview(toBack: self)
		
	}
	
	@IBAction func dismiss(_ sender: Any) {
		
		hide()
		
	}
	
}
