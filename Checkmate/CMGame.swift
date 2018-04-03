//
//  CMGame.swift
//  Checkmate
//
//  Created by Ryan Rice on 1/13/17.
//  Copyright © 2017 Ryan Rice. All rights reserved.
//

import UIKit
import GameKit

class CMGame: NSObject {

	enum GameState {
		
		case PlayerSelect
		case PlayerMove
		case Computer
		
	}
	
	static let sharedInstance = CMGame()
	
	private var state: GameState = .PlayerSelect
	private var moves: [[Int]] = [[Int]]()
	
	private var spawnCounter = 0
	private var computerCounter = 0
	
	private var score = 0
	
	private var computerTypes: [CMGameSquare.SquarePiece] = [.Pawn, .Bishop, .Rook, .Knight, .Queen]
	private var userType: CMGameSquare.SquarePiece = .Pawn
	
	private var computerColor = "Red"
	private var userColor = "Blue"
	
	private let colors = ["Blue", "Red", "Green", "Purple", "Yellow"]
	
	private override init() {
	
	}
	
	func startGame() {
	
		state = .PlayerSelect
		score = 0
		
		setComputerColor()
		resetSpawnCounter()
		resetComputerCounter()
		
	}
	
	func getState() -> GameState {
	
		return state
	
	}
	
	func setState(state: GameState) {
	
		self.state = state
	
	}
	
	func getUserType() -> CMGameSquare.SquarePiece {
	
		return userType
	
	}
	
	func setUserType(type: CMGameSquare.SquarePiece) {
	
		userType = type
	
	}
	
	func getUserColor() -> String {
		
		return userColor
		
	}
	
	func setUserColor(color: String) {
		
		userColor = color
		
		setComputerColor()
		
	}
	
	func setComputerColor() {
	
		computerColor = colors[Int(arc4random_uniform(UInt32(colors.count)))]
		
		if computerColor == userColor {
		
			setComputerColor()
		
		}
	
	}
	
	func setComputerColor(color: String) {
	
		computerColor = color
	
		if computerColor == userColor {
			
			setComputerColor()
			
		}
		
	}
	
	func getComputerColor() -> String {
	
		return computerColor
	
	}
	
	func getUserColorSwatch() -> UIColor {
	
		switch userColor {
			
		case "Blue":
			return #colorLiteral(red: 0.3019607843, green: 0.7764705882, blue: 1, alpha: 1)
			
		case "Red":
			return #colorLiteral(red: 1, green: 0.3, blue: 0.3, alpha: 1)
		
		case "Green":
			return #colorLiteral(red: 0.5624166667, green: 0.85, blue: 0.255, alpha: 1)
			
		case "Purple":
			return #colorLiteral(red: 0.6733333333, green: 0.3, blue: 1, alpha: 1)
			
		case "Yellow":
			return #colorLiteral(red: 1, green: 0.9358333333, blue: 0.45, alpha: 1)
			
		case "White":
			return #colorLiteral(red: 0.92684, green: 0.9118, blue: 0.94, alpha: 1)
			
		case "Black":
			return #colorLiteral(red: 0.44, green: 0.44, blue: 0.44, alpha: 1)
			
		default:
			return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
			
		}
	
	}
	
	func getFlag(color: String) -> UIImage {
	
		switch color {
		
		case "Blue":
			return #imageLiteral(resourceName: "Flag Blue")
			
		case "Red":
			return #imageLiteral(resourceName: "Flag Red")
			
		case "Green":
			return #imageLiteral(resourceName: "Flag Green")
			
		case "Purple":
			return #imageLiteral(resourceName: "Flag Purple")
			
		case "Yellow":
			return #imageLiteral(resourceName: "Flag Yellow")
			
		case "White":
			return #imageLiteral(resourceName: "Flag White")
			
		case "Black":
			return #imageLiteral(resourceName: "Flag Black")
			
		default:
			return #imageLiteral(resourceName: "Flag Blue")
			
		}
	
	}
	
	func getPieceImage(owner: CMGameSquare.SquareOwner, piece: CMGameSquare.SquarePiece) -> UIImage {
	
		var pieceImages: [UIImage] = []
		
		switch owner == .User ? userColor : computerColor {
		
		case "Blue":
			pieceImages = [#imageLiteral(resourceName: "Piece Pawn Blue"), #imageLiteral(resourceName: "Piece Bishop Blue"), #imageLiteral(resourceName: "Piece Rook Blue"), #imageLiteral(resourceName: "Piece Knight Blue"), #imageLiteral(resourceName: "Piece Queen Blue")]
			
		case "Red":
			pieceImages = [#imageLiteral(resourceName: "Piece Pawn Red"), #imageLiteral(resourceName: "Piece Bishop Red"), #imageLiteral(resourceName: "Piece Rook Red"), #imageLiteral(resourceName: "Piece Knight Red"), #imageLiteral(resourceName: "Piece Queen Red")]
		
		case "Green":
			pieceImages = [#imageLiteral(resourceName: "Piece Pawn Green"), #imageLiteral(resourceName: "Piece Bishop Green"), #imageLiteral(resourceName: "Piece Rook Green"), #imageLiteral(resourceName: "Piece Knight Green"), #imageLiteral(resourceName: "Piece Queen Green")]
			
		case "Purple":
			pieceImages = [#imageLiteral(resourceName: "Piece Pawn Purple"), #imageLiteral(resourceName: "Piece Bishop Purple"), #imageLiteral(resourceName: "Piece Rook Purple"), #imageLiteral(resourceName: "Piece Knight Purple"), #imageLiteral(resourceName: "Piece Queen Purple")]
		
		case "Yellow":
			pieceImages = [#imageLiteral(resourceName: "Piece Pawn Yellow"), #imageLiteral(resourceName: "Piece Bishop Yellow"), #imageLiteral(resourceName: "Piece Rook Yellow"), #imageLiteral(resourceName: "Piece Knight Yellow"), #imageLiteral(resourceName: "Piece Queen Yellow")]
		
		case "White":
			pieceImages = [#imageLiteral(resourceName: "Piece Pawn White"), #imageLiteral(resourceName: "Piece Bishop White"), #imageLiteral(resourceName: "Piece Rook White"), #imageLiteral(resourceName: "Piece Knight White"), #imageLiteral(resourceName: "Piece Queen White")]
		
		case "Black":
			pieceImages = [#imageLiteral(resourceName: "Piece Pawn Black"), #imageLiteral(resourceName: "Piece Bishop Black"), #imageLiteral(resourceName: "Piece Rook Black"), #imageLiteral(resourceName: "Piece Knight Black"), #imageLiteral(resourceName: "Piece Queen Black")]
			
		default:
			break
		
		}
		
		switch piece {
		
		case .Pawn:
			return pieceImages[0]
			
		case .Bishop:
			return pieceImages[1]
			
		case .Rook:
			return pieceImages[2]
			
		case .Knight:
			return pieceImages[3]
			
		case .Queen:
			return pieceImages[4]
		
		default:
			return pieceImages[0]
		
		}
	
	}
	
	func calcPossibleMoves(board: [CMGameSquare], position: [Int], piece: CMGameSquare.SquarePiece, owner: CMGameSquare.SquareOwner) -> [[Int]] {
	
		var moves = [[Int]]()
		
		switch piece {
		
		case .Pawn:
			
			var normalMoves = [[position[0], position[1] + 1], [position[0] + 1, position[1]], [position[0], position[1] - 1], [position[0] - 1, position[1]]]
			var captureMoves = [[position[0] + 1, position[1] + 1], [position[0] + 1, position[1] - 1], [position[0] - 1, position[1] - 1], [position[0] - 1, position[1] + 1]]
			
			for move in normalMoves {
			
				if move.contains(-1) || move.contains(6) || board[move[0] + move[1] * 6].piece != .Empty {
				
					normalMoves.remove(at: normalMoves.index(where: {$0 == move})!)
				
				}
			
			}
			
			for move in captureMoves {
				
				let owners: [CMGameSquare.SquareOwner] = owner == .User ? [.User] : [.Computer, .MovedComputer]
				
				if move.contains(-1) || move.contains(6) || board[move[0] + move[1] * 6].piece == .Empty || owners.contains(board[move[0] + move[1] * 6].owner) {
					
					captureMoves.remove(at: captureMoves.index(where: {$0 == move})!)
					
				}
				
			}
			
			moves += normalMoves
			moves += captureMoves
			
		case .Bishop:
			
			var moves = [[Int]]()
			
			let owners: [CMGameSquare.SquareOwner] = owner == .User ? [.User] : [.Computer, .MovedComputer]
			
			var x = position[0]
			var y = position[1]
			var i = 1
			
			var rightUp = true
			var rightDown = true
			var leftUp = true
			var leftDown = true
			
			while x + i < 6 {
			
				if y + i < 6 && rightUp {
				
					if board[x + i + (y + i) * 6].piece == .Empty {
						
						moves.append([x + i, y + i])
					
					} else if !owners.contains(board[x + i + (y + i) * 6].owner) {
					
						moves.append([x + i, y + i])
						rightUp = false
					
					} else {
					
						rightUp = false
					
					}
						
				}
				
				if y - i > -1 && rightDown {
				
					if board[x + i + (y - i) * 6].piece == .Empty {
						
						moves.append([x + i, y - i])
						
					} else if !owners.contains(board[x + i + (y - i) * 6].owner) {
						
						moves.append([x + i, y - i])
						rightDown = false
						
					} else {
						
						rightDown = false
						
					}
				
				}
				
				i += 1
			
			}
			
			x = position[0]
			y = position[1]
			i = 1
			
			while x - i > -1 {
				
				if y + i < 6 && leftUp {
					
					if board[x - i + (y + i) * 6].piece == .Empty {
						
						moves.append([x - i, y + i])
						
					} else if !owners.contains(board[x - i + (y + i) * 6].owner) {
						
						moves.append([x - i, y + i])
						leftUp = false
						
					} else {
						
						leftUp = false
						
					}
					
				}
				
				if y - i > -1 && leftDown {
					
					if board[x - i + (y - i) * 6].piece == .Empty {
						
						moves.append([x - i, y - i])
						
					} else if !owners.contains(board[x - i + (y - i) * 6].owner) {
						
						moves.append([x - i, y - i])
						leftDown = false
						
					} else {
						
						leftDown = false
						
					}
					
				}
				
				i += 1
				
			}
			
			return moves
			
		case .Rook:
			
			var moves = [[Int]]()
			
			let owners: [CMGameSquare.SquareOwner] = owner == .User ? [.User] : [.Computer, .MovedComputer]
			
			for x in (position[0] + 1)..<6 {
			
				if board[x + position[1] * 6].piece == .Empty {
				
					moves.append([x, position[1]])
				
				} else if !owners.contains(board[x + position[1] * 6].owner) {
				
					moves.append([x, position[1]])
					break
				
				} else {
				
					break
				
				}
				
			}
			
			for x in 0..<position[0] {
				
				if board[position[0] - x - 1 + position[1] * 6].piece == .Empty {
					
					moves.append([position[0] - x - 1, position[1]])
					
				} else if !owners.contains(board[position[0] - x - 1 + position[1] * 6].owner) {
					
					moves.append([position[0] - x - 1, position[1]])
					break
					
				} else {
					
					break
					
				}
				
			}
			
			for y in (position[1] + 1)..<6 {
				
				if board[position[0] + y * 6].piece == .Empty {
					
					moves.append([position[0], y])
					
				} else if !owners.contains(board[position[0] + y * 6].owner) {
					
					moves.append([position[0], y])
					break
					
				} else {
					
					break
					
				}
				
			}
			
			for y in 0..<position[1] {
				
				if board[position[0] + (position[1] - y - 1) * 6].piece == .Empty {
					
					moves.append([position[0], position[1] - y - 1])
					
				} else if !owners.contains(board[position[0] + (position[1] - y - 1) * 6].owner) {
					
					moves.append([position[0], position[1] - y - 1])
					break
					
				} else {
					
					break
					
				}
				
			}
			
			return moves
			
		case .Knight:
			
			var moves = [[Int]]()
			
			let owners: [CMGameSquare.SquareOwner] = owner == .User ? [.User] : [.Computer, .MovedComputer]
			
			let combos = [[2, 1], [1, 2], [-1, 2], [-2, 1], [-2, -1], [-1, -2], [1, -2], [2, -1]]
			
			for combo in combos {
			
				let x = position[0] + combo[0]
				let y = position[1] + combo[1]
				
				if x < 6 && x > -1 && y < 6 && y > -1 && !owners.contains(board[x + y * 6].owner) {
					
					moves.append([x, y])
					
				}
			
			}
			
			return moves
			
		case .Queen:
			
			return calcPossibleMoves(board: board, position: position, piece: .Rook, owner: owner) + calcPossibleMoves(board: board, position: position, piece: .Bishop, owner: owner)
			
		default:
			break
			
		}
		
		for move in moves {
		
			if move.contains(-1) || move.contains(6) {
			
				moves.remove(at: moves.index(where: {$0 == move})!)
			
			}
		
		}
		
		return moves
	
	}
	
	func getPossibleMoves() -> [[Int]] {
	
		return moves
	
	}
	
	func setPossibleMoves(moves: [[Int]]) {
	
		self.moves = moves
	
	}
	
	func getSpawnCounter() -> Int {
		
		return spawnCounter
		
	}
	
	func increaseSpawnCounter() {
	
		spawnCounter += 1
	
	}
	
	func resetSpawnCounter() {
	
		spawnCounter = 0
	
	}
	
	func getComputerCounter() -> Int {
		
		return computerCounter
		
	}
	
	func increaseComputerCounter() {
		
		computerCounter += 1
		
	}
	
	func decreaseComputerCounter() {
		
		computerCounter -= 1
		score += 1
		
	}
	
	func resetComputerCounter() {
	
		computerCounter = 0
	
	}
	
	func getSpawnFactor() -> Int {
	
		return min(score / 5 + 1, 5)
	
	}
	
	func getComputerTypes() -> [CMGameSquare.SquarePiece] {
	
		return computerTypes
	
	}
	
	func checkAchievements(board: [CMGameSquare], playerSquare: CMGameSquare) {
	
		let i = board.index(of: playerSquare)!
		var achievements = [GKAchievement]()
		
		if (i + 1 < 36 && board[i + 1].piece == .Rook || i - 1 > -1 && board[i - 1].piece == .Rook) && (i + 6 < 36 && board[i + 6].piece == .Rook || i - 6 > -1 && board[i - 6].piece == .Rook) && playerSquare.piece == .Pawn {
			
			let a = GKAchievement(identifier: "RiemannTrap")
			
			a.percentComplete = 100
			a.showsCompletionBanner = true
			
			if !a.isCompleted {
			
				achievements.append(a)
			
			}
			
		}
	
		GKAchievement.report(achievements) { (Error) in
			
		}
		
	}
	
}
