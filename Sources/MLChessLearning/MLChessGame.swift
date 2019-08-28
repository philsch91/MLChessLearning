//
//  MLChessGame.swift
//  MLChess
//
//  Created by Philipp Schunker on 02.04.19.
//  Copyright © 2019 Philipp Schunker. All rights reserved.
//

import Cocoa

public class MLChessGame: NSObject, Codable {
    public var board: [[MLChessPiece?]] = [[MLChessPiece?]]()
    public var moves: [[[MLChessPiece?]]] = [[[MLChessPiece?]]]()
    public var active: MLPieceColor!
    public var winner: Int!
    
    //MARK: - CodingKey
    
    enum CodingKeys: String, CodingKey {
        case board
        case moves
        case active
        case winner
    }
    
}
