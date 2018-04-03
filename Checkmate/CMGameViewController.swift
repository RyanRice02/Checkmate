//
//  CMGameViewController.swift
//  Checkmate
//
//  Created by Ryan Rice on 1/10/17.
//  Copyright © 2017 Ryan Rice. All rights reserved.
//

import UIKit
import AVFoundation

class CMGameViewController: UIViewController {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var gameBoardStack: UIStackView!
	
	@IBOutlet weak var userFlag: UIImageView!
	@IBOutlet weak var computerFlag: UIImageView!
	
	let game = CMGame.sharedInstance
	var board = [CMGameSquare]()
	
	var tutoring = false
	var tutorStage = 0
	var tutorIndex = 0
	
	let tutorTexts = [["Welcome To Checkmate!", "See That Piece Down There?", "It's Yours! Tap It Now!"], ["Excellent!", "See Those Dark Squares?", "Those Are Possible Moves!", "Tap One To Move!"], ["Brilliant!", "That New Piece Over There", "That's An Opponent!", "Move Onto Its Square!"], ["You Captured It!", "And Look, You Got A Capture!", "New Pieces And Flags", "Can Be Unlocked With Captures!", "Looks Like You're Ready!", "One Last Thing!", "This Blue Bar Up Here", "Drops Down A Menu!", "Tap It To Pause, Quit, Etc.", "Good Luck!"]]
	
	var soundPlayer: AVAudioPlayer!
	
	let audioSession = AVAudioSession.sharedInstance()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		resetGame()
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
	
	func resetGame() {
	
		game.startGame()
		setupBoard()
		
		scoreLabel.text = "VS"
	
		if UserDefaults.standard.bool(forKey: "Tutorial Complete") == true {
		
			addComputer()
		
		} else {
			
			titleLabel.shadowOffset = CGSize(width: 0, height: 1)
			titleLabel.font = UIFont(name: "Big John", size: titleLabel.font.pointSize * 3 / 5)
			titleLabel.text = tutorTexts[0][0]
			
			tutoring = true
			tutorIndex += 1
			
			tutorGame()
		
		}
		
	}
	
	func tutorGame() {
		
		if tutorIndex < tutorTexts[tutorStage].count {
		
			DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
			
				self.titleLabel.text = self.tutorTexts[self.tutorStage][self.tutorIndex]
				self.tutorIndex += 1
			
				self.tutorGame()
				
			})
			
		} else if tutorStage == 3 {
		
			DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
			
				UserDefaults.standard.set(true, forKey: "Tutorial Complete")
				
				self.tutoring = false
				
				self.titleLabel.shadowOffset = CGSize(width: 0, height: 2)
				self.titleLabel.font = UIFont(name: "Big John", size: self.titleLabel.font.pointSize * 5 / 3)
				self.titleLabel.text = "Your Move"
				
				self.addComputer()
			
			})
		
		}
	
	}
	
	func setupBoard() {
		
		userFlag.image = game.getFlag(color: game.getUserColor())
		computerFlag.image = game.getFlag(color: game.getComputerColor())
		
		let iSquare = arc4random_uniform(UInt32(4))
		let startSquare = iSquare == 0 ? 0 : iSquare == 1 ? 5 : iSquare == 2 ? 30 : 35
		
		for rowStack in gameBoardStack.arrangedSubviews as! [UIStackView] {
		
			for square in rowStack.arrangedSubviews as! [CMGameSquare] {
			
				square.position = [rowStack.arrangedSubviews.index(of: square)!, gameBoardStack.arrangedSubviews.index(of: rowStack)!]
				square.owner = .Neutral
				square.piece = .Empty
				
				board.append(square)
				
			}
			
		}
		
		layoutBoard(position: board[startSquare].position, piece: game.getUserType(), owner: .User)

	}
	
	func layoutBoard(position: [Int], piece: CMGameSquare.SquarePiece, owner: CMGameSquare.SquareOwner) {
		
		colorBoard()
		
		var capture = false
		
		for square in board {
		
			if square.position == position {
			
				if square.owner == .Computer {
					
					game.decreaseComputerCounter()
					capture = true
					
					scoreLabel.text = scoreLabel.text == "VS" ? "1" : "\(Int(scoreLabel.text!)! + 1)"
					
				}
				
				square.setBackgroundImage(game.getPieceImage(owner: owner, piece: piece), for: .normal)
				square.piece = piece
				square.owner = owner == .User ? owner : .MovedComputer
				
			} else if square.owner == owner || square.owner == .Neutral {
			
				square.setBackgroundImage(UIImage(), for: .normal)
				square.piece = .Empty
				square.owner = .Neutral
			
			}
		
		}
		
		if tutoring {
			
			if capture {
			
				tutorStage += 1
				tutorIndex = 1
				
				titleLabel.text = tutorTexts[tutorStage][0]
				
				tutorGame()
			
			}
			
			return
			
		}
		
		if board.contains(where: {$0.owner == .User}) == false {
		
			titleLabel.text = "Checkmate"
		
			checkmate()
			
		} else if capture {
		
			titleLabel.text = "Nice Capture"
			
			UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "Captures") + 1, forKey: "Captures")
			
			if board.contains(where: {$0.owner == .Computer || $0.owner == .MovedComputer}) == false {
			
				game.resetSpawnCounter()
			
			}
		
		} else if game.getState() == .Computer || game.getState() == .PlayerSelect {
		
			titleLabel.text = "Your Move"
		
		} else if game.getState() == .PlayerMove {
		
			titleLabel.text = "Computer's Move"
		
		} else {
			
			titleLabel.text = ""
			
		}
		
		for square in board {
			
			if square.owner == .User {
		
				game.checkAchievements(board: board, playerSquare: square)
		
			}
			
		}
		
	}
	
	func colorBoard() {
	
		for square in board {
		
			square.backgroundColor = board.index(of: square)! % 2 == 0 ? board.index(of: square)! / 6 % 2 == 0 ? game.getUserColorSwatch() : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : board.index(of: square)! / 6 % 2 == 0 ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : game.getUserColorSwatch()
		
		}
	
	}
	
	func addComputer() {
		
		for _ in 0..<game.getSpawnFactor() {
			
			var i = Int(arc4random_uniform(UInt32(36)))
			var p = 0
			
			for square in board {
				
				if square.owner == .User {
					
					p = board.index(of: square)!
					
				}
				
			}
			
			while board[i].owner != .Neutral {
				
				i = Int(arc4random_uniform(UInt32(36)))
				
			}
			
			let piece = game.getComputerTypes()[Int(arc4random_uniform(UInt32(game.getComputerTypes().count)))]
			
			if piece == .Bishop && game.getUserType() == .Bishop && board[i].backgroundColor != board[p].backgroundColor {
				
				while board[i].backgroundColor != board[p].backgroundColor {
					
					i = Int(arc4random_uniform(UInt32(36)))
					
				}
				
			}
			
			let pieceSquare = UIImageView(frame: gameBoardStack.subviews[0].subviews[0].frame)
			let startPosition = board[i].frame.origin
			
			pieceSquare.image = game.getPieceImage(owner: .Computer, piece: piece)
			pieceSquare.frame.origin = CGPoint(x: startPosition.x + gameBoardStack.frame.origin.x, y: startPosition.y + gameBoardStack.frame.origin.y + gameBoardStack.subviews[0].frame.height * CGFloat(board[i].position[1]))
			pieceSquare.alpha = 0
			
			view.addSubview(pieceSquare)
			
			board[i].piece = piece
			board[i].owner = .Computer
			
			UIView.animate(withDuration: 0.1, animations: {
			
				pieceSquare.alpha = 1
				
			}, completion: { (Bool) in
				
				pieceSquare.removeFromSuperview()
				
				self.board[i].setBackgroundImage(self.game.getPieceImage(owner: .Computer, piece: piece), for: .normal)
				
			})
			
			game.resetSpawnCounter()
			game.increaseComputerCounter()
			
		}
		
	}
	
	func moveComputer() {
		
		var takenMoves = [[Int]]()
		
		for i in 0..<2 {
			
			for square in board {
				
				if square.owner == .Computer {
					
					var moves = game.calcPossibleMoves(board: board, position: square.position, piece: square.piece, owner: square.owner)
					
					if moves.count == 0 {
						break
					}
					
					var playerPosition = [Int]()
					
					for square in board {
						
						if square.owner == .User {
							
							playerPosition = square.position
							
						}
						
					}
					
					if playerPosition.isEmpty {
						break
					}
					
					for t in takenMoves {
					
						if moves.contains(where: {$0 == t}) {
						
							moves.remove(at: moves.index(where: {$0 == t})!)
						
						}
					
					}
					
					var preferredMoves = [[[Int]]]()
					var idealMoves = [[Int]]()
					var hasCheckmate = false
					
					preferredMoves.append([[12], []])
					
					for m in moves {
						
						let distance = abs(m[0] - playerPosition[0]) + abs(m[1] - playerPosition[1])
						
						if distance == 0 {
							
							idealMoves.removeAll()
							idealMoves.append(m)
							
							hasCheckmate = true
							
							break
							
						} else if game.calcPossibleMoves(board: board, position: m, piece: square.piece, owner: square.owner).contains(where: {$0 == playerPosition}) {
							
							idealMoves.append(m)
							
						}
						
						if distance < preferredMoves[0][0][0] {
							
							preferredMoves.removeAll()
							preferredMoves.append([[distance], m])
							
						} else if distance == preferredMoves[0][0][0] {
							
							preferredMoves.append([[distance], m])
							
						}
						
					}
					
//					let sortedMoves = moves.sorted(by: { (a, b) -> Bool in
//						
//						let distanceA = abs(a[0] - playerPosition[0]) + abs(a[1] - playerPosition[1])
//						let distanceB = abs(b[0] - playerPosition[0]) + abs(b[1] - playerPosition[1])
//						
//						return distanceA < distanceB
//					
//					})
					
					var move = [Int]()
					
					if i == 1 || hasCheckmate {
						
						if !idealMoves.isEmpty {
							
							move = idealMoves[Int(arc4random_uniform(UInt32(idealMoves.count)))]
							
						} else if !preferredMoves.isEmpty {
							
							move = preferredMoves[Int(arc4random_uniform(UInt32(preferredMoves.count)))][1]
							
						} else if !moves.isEmpty {
							
							move = moves[Int(arc4random_uniform(UInt32(moves.count)))]
						
						} else {
						
							move = square.position
						
						}
						
						square.owner = .MovingComputer
						
						if !move.isEmpty {
						
							animateMove(position: square.position, move: move, square: square, piece: square.piece, owner: square.owner)
							takenMoves.append(move)
							
						} else {
						
							takenMoves.append(square.position)
						
						}
						
					}
					
				}
				
			}
			
		}
		
		if self.game.getComputerCounter() == 0 {
			
			self.addComputer()
			self.game.increaseSpawnCounter()
			self.game.setState(state: .PlayerSelect)
			
		} else {
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.55, execute: {
				
				for square in self.board {
					
					if square.owner == .MovedComputer {
						square.owner = .Computer
					}
					
				}
				
				self.game.increaseSpawnCounter()
				
				if self.game.getSpawnCounter() == 2 + self.game.getSpawnFactor() || self.game.getComputerCounter() == 0 {
					self.addComputer()
				}
				
				self.game.setState(state: .PlayerSelect)
				
			})
			
		}
		
	}
	
	func animateMove(position: [Int], move: [Int], square: CMGameSquare, piece: CMGameSquare.SquarePiece, owner: CMGameSquare.SquareOwner) {
		
		let pieceSquare = UIImageView(frame: gameBoardStack.subviews[0].subviews[0].frame)
		let startPosition = self.board[self.board.index(where: {$0.position == position})!].frame.origin
		let endPosition = self.board[self.board.index(where: {$0.position == move})!].frame.origin
		
		pieceSquare.image = square.backgroundImage(for: .normal)
		square.setBackgroundImage(UIImage(), for: .normal)
		
		view.addSubview(pieceSquare)
		
		pieceSquare.frame.origin = CGPoint(x: startPosition.x + self.gameBoardStack.frame.origin.x, y: startPosition.y + self.gameBoardStack.frame.origin.y + self.gameBoardStack.subviews[0].frame.height * CGFloat(position[1]))
		
		UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
			
			pieceSquare.frame.origin = CGPoint(x: endPosition.x + self.gameBoardStack.frame.origin.x, y: endPosition.y + self.gameBoardStack.frame.origin.y + self.gameBoardStack.subviews[0].frame.height * CGFloat(move[1]))
			
		}, completion: { (Bool) in
			
			self.layoutBoard(position: move, piece: piece, owner: owner)
			
			pieceSquare.removeFromSuperview()
			
		})
	
	}
	
	@IBAction func squareTouched(_ sender: CMGameSquare) {
		
		if tutoring && (tutorIndex != tutorTexts[tutorStage].count || tutorStage == 3) {
			return
		}
		
		var shouldAdvanceTutoring = false
		
		switch game.getState() {
			
		case .PlayerSelect:
			
			if sender.piece != .Empty && sender.owner == .User {
				
				let moves = game.calcPossibleMoves(board: board, position: sender.position, piece: sender.piece, owner: sender.owner)
				
				if moves.isEmpty {
				
					game.setState(state: .Computer)
					
					perform(#selector(CMGameViewController.moveComputer), with: nil, afterDelay: 1)
					
					break
				
				}
				
				game.setPossibleMoves(moves: moves)
				game.setState(state: .PlayerMove)
				
				for square in board {
					
					if moves.contains(where: {$0 == square.position}) {
						
						square.backgroundColor = square.backgroundColor?.withAlphaComponent(0.65)
						
					}
					
				}
				
				shouldAdvanceTutoring = true
				
			}
			
		case .PlayerMove:
			
			if game.getPossibleMoves().contains(where: {$0 == sender.position}) {
				
				var square = CMGameSquare()
				
				for s in board {
				
					if s.owner == .User {
					
						square = s
					
					}
				
				}
				
				animateMove(position: square.position, move: sender.position, square: square, piece: square.piece, owner: square.owner)
				
				if !tutoring {
					
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.55, execute: {
						
						self.game.setState(state: .Computer)
						
					})
					
					perform(#selector(CMGameViewController.moveComputer), with: nil, afterDelay: 1)
					
				} else {
				
					self.game.setState(state: .PlayerSelect)
				
				}
				
				shouldAdvanceTutoring = true
				
			}
			
		default:
			break
			
		}
		
		if tutoring && shouldAdvanceTutoring {
			
			if tutorStage == 1 {
			
				addComputer()
			
			} else if tutorStage == 2 {
			
				return
			
			}
			
			tutorStage += 1
			tutorIndex = 1
			
			titleLabel.text = tutorTexts[tutorStage][0]
			
			tutorGame()
			
		}
		
	}
	
	func checkmate() {
	
		performSegue(withIdentifier: "CMCheckmateSegue", sender: nil)
	
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "CMCheckmateSegue" {
			
			let vc = segue.destination as! CMCheckmateViewController
			
			vc.score = scoreLabel.text! == "VS" ? 0 : Int(scoreLabel.text!)!
			
		} else if segue.identifier == "CMGameDropdownSegue" {
			
			let vc = segue.destination as! CMDropdownViewController
			
			vc.dropdownType = .Game
			
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
