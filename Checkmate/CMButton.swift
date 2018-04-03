//
//  CMButton.swift
//  Checkmate
//
//  Created by Ryan Rice on 1/21/17.
//  Copyright © 2017 Ryan Rice. All rights reserved.
//

import UIKit

class CMButton: UIButton {

    override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		self.titleLabel?.adjustsFontSizeToFitWidth = true
		
    }

}
