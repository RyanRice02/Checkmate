//
//  CMGameSquare.swift
//  Checkmate
//
//  Created by Ryan Rice on 1/13/17.
//  Copyright © 2017 Ryan Rice. All rights reserved.
//

import UIKit

class CMGameSquare: UIButton {

	enum SquarePiece {
		
		case Empty
		case Pawn
		case Bishop
		case Rook
		case Knight
		case Queen
		
	}
	
	enum SquareOwner {
	
		case Neutral
		case User
		case Computer
		case MovedComputer
		case MovingComputer
	
	}

	var piece: SquarePiece = .Empty
	var owner: SquareOwner = .Neutral
	var position: [Int] = [0, 0]
	
}
