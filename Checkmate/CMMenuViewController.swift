//
//  CMMenuViewController.swift
//  Checkmate
//
//  Created by Ryan Rice on 1/15/17.
//  Copyright © 2017 Ryan Rice. All rights reserved.
//

import UIKit
import AVFoundation

class CMMenuViewController: UIViewController {

	@IBOutlet weak var gameBoardStack: UIStackView!
	
	@IBOutlet weak var conquestButton: CMButton!
	@IBOutlet weak var endlessButton: CMButton!
	
	@IBOutlet weak var menuAlert: CMAlertView!
	
	var board = [CMGameSquare]()
	var currentOwner: CMGameSquare.SquareOwner = .User
	
	var code = [Int]()

	var topPlayer: AVAudioPlayer!
	var soundPlayer: AVAudioPlayer!
	
	let audioSession = AVAudioSession.sharedInstance()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		do {
			
			try audioSession.setCategory(AVAudioSessionCategoryAmbient)
			
			NotificationCenter.default.addObserver(self, selector: #selector(CMMenuViewController.playMusic), name: .AVAudioSessionSilenceSecondaryAudioHint, object: nil)
			
		} catch {}
		
		setupBoard()
		setupMusic()
		setupSound()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
		
			self.movePiece()
			
		})
		
	}
	
	func setupMusic() {
	
		do {
			
			let topLayer = URL(fileURLWithPath: Bundle.main.path(forResource: "Game Music Top Layer", ofType: "m4a")!)
			
			topPlayer = try AVAudioPlayer(contentsOf: topLayer)
			topPlayer.numberOfLoops = -1
			topPlayer.prepareToPlay()
			topPlayer.setVolume(0, fadeDuration: 0)
			
			playMusic()
			
		} catch {}
	
	}
	
	func setupSound() {
	
		do {
			
			let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "rollover2", ofType: "wav")!)
			
			soundPlayer = try AVAudioPlayer(contentsOf: sound)
			soundPlayer.numberOfLoops = 1
			soundPlayer.prepareToPlay()
			
		} catch {}
	
	}
	
	func playMusic() {
	
		if audioSession.isOtherAudioPlaying {
			return
		}
		
		if UserDefaults.standard.bool(forKey: "Sound") {
		
			topPlayer.play()
			topPlayer.setVolume(0.25, fadeDuration: 1)
		
		} else {
		
			topPlayer.stop()
		
		}
	
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
	
	func setupBoard() {
	
		for rowStack in gameBoardStack.arrangedSubviews as! [UIStackView] {
			
			for square in rowStack.arrangedSubviews as! [CMGameSquare] {
				
				square.position = [rowStack.arrangedSubviews.index(of: square)!, gameBoardStack.arrangedSubviews.index(of: rowStack)!]
				square.owner = .Neutral
				square.piece = .Empty
				
				board.append(square)
				
			}
			
		}
		
		let blueStartSquare = Int(arc4random_uniform(UInt32(board.count)))
		var redStartSquare = Int(arc4random_uniform(UInt32(board.count)))
		
		while redStartSquare == blueStartSquare {
			
			redStartSquare = Int(arc4random_uniform(UInt32(board.count)))
			
		}
		
		layoutBoard(position: board[blueStartSquare].position, piece: .Rook, owner: .User)
		layoutBoard(position: board[redStartSquare].position, piece: .Rook, owner: .Computer)
		
	}
	
	func layoutBoard(position: [Int], piece: CMGameSquare.SquarePiece, owner: CMGameSquare.SquareOwner) {
		
		colorBoard()
		
		for square in board {
			
			if square.position == position {
				
				square.setBackgroundImage(owner == .User ? #imageLiteral(resourceName: "Piece Rook Blue") : #imageLiteral(resourceName: "Piece Rook Red"), for: .normal)
				square.piece = piece
				square.owner = owner
				
			} else if square.owner == owner || square.owner == .Neutral {
				
				square.setBackgroundImage(UIImage(), for: .normal)
				square.piece = .Empty
				square.owner = .Neutral
				
			}
			
		}
		
	}
	
	func colorBoard() {
		
		for square in board {
			
			square.backgroundColor = board.index(of: square)! % 2 == 0 ? board.index(of: square)! / 6 % 2 == 0 ? #colorLiteral(red: 0.3019607843, green: 0.7764705882, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : board.index(of: square)! / 6 % 2 == 0 ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.3019607843, green: 0.7764705882, blue: 1, alpha: 1)
			
		}
		
	}

	func movePiece() {
	
		if menuAlert.alpha != 0 {
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
				
				self.movePiece()
				
			})
			
			return
			
		}
		
		var position = [0, 0]
		var piece: CMGameSquare.SquarePiece = .Pawn
		
		let pieceSquare = UIImageView(frame: gameBoardStack.subviews[0].subviews[0].frame)
		
		for square in board {
		
			if square.owner == currentOwner {
			
				position = square.position
				piece = square.piece
				pieceSquare.image = square.backgroundImage(for: .normal)
				
				view.addSubview(pieceSquare)
				
				square.setBackgroundImage(UIImage(), for: .normal)
				
			}
		
		}
		
		var moves = getMoves(position: position)
		let move = moves[Int(arc4random_uniform(UInt32(moves.count)))]
		
		let startPosition = self.board[self.board.index(where: {$0.position == position})!].frame.origin
		let endPosition = self.board[self.board.index(where: {$0.position == move})!].frame.origin

		pieceSquare.frame.origin = CGPoint(x: startPosition.x, y: startPosition.y + self.gameBoardStack.frame.origin.y + self.gameBoardStack.subviews[0].frame.height * CGFloat(position[1]))
		
		UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
			
			pieceSquare.frame.origin = CGPoint(x: endPosition.x, y: endPosition.y + self.gameBoardStack.frame.origin.y + self.gameBoardStack.subviews[0].frame.height * CGFloat(move[1]))
		
		}, completion: { (Bool) in
			
			self.layoutBoard(position: move, piece: piece, owner: self.currentOwner)
			self.currentOwner = self.currentOwner == .User ? .Computer : .User
			
			pieceSquare.removeFromSuperview()
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
				
				self.movePiece()
				
			})
			
		})
		
	}
	
	func getMoves(position: [Int]) -> [[Int]] {
		
		var moves = [[Int]]()
		
		for x in (position[0] + 1)..<6 {
			
			if board[x + position[1] * 6].piece == .Empty {
				
				moves.append([x, position[1]])
				
			} else {
				
				break
				
			}
			
		}
		
		for x in 0..<position[0] {
			
			if board[position[0] - x - 1 + position[1] * 6].piece == .Empty {
				
				moves.append([position[0] - x - 1, position[1]])
				
			} else {
				
				break
				
			}
			
		}
		
		for y in (position[1] + 1)..<3 {
			
			if board[position[0] + y * 6].piece == .Empty {
				
				moves.append([position[0], y])
				
			} else {
				
				break
				
			}
			
		}
		
		for y in 0..<position[1] {
			
			if board[position[0] + (position[1] - y - 1) * 3].piece == .Empty {
				
				moves.append([position[0], position[1] - y - 1])
				
			} else {
				
				break
				
			}
			
		}
		
		return moves
	
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "CMMenuDropdownSegue" {
			
			let vc = segue.destination as! CMDropdownViewController
			
			vc.dropdownType = .Menu
			
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
	
	@IBAction func squareTouched(_ sender: CMGameSquare) {
	
		if sender.owner != .Computer {
		
			code.append(board.index(of: sender)!)
		
		} else if code == [1, 14, 9, 5] {
		
			UserDefaults.standard.set(true, forKey: "Black")
			UserDefaults.standard.set(true, forKey: "Tutorial Complete")
			UserDefaults.standard.set([0, 1, 2, 3, 4, 5, 6], forKey: "Unlocked Flags")
			UserDefaults.standard.set([0, 1, 2, 3, 4], forKey: "Unlocked Pieces")
			
		} else {
		
			code.removeAll()
		
		}
	
	}
	
	@IBAction func showAlert(_ sender: Any) {
	
		menuAlert.show()
	
	}
	
}
