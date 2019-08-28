//
//  MLChessPiece.swift
//
//
//  Created by Philipp Schunker on 28.05.19.
//

import Foundation

public class MLChessPiece: Codable, Equatable {
    
    public var color: MLPieceColor = MLPieceColor.black
    public var id: Int = 0
    public var value: Int = 0
    
    //MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id
        //case value
    }
    
    //MARK: - Equatable
    
    public static func ==(lhs: MLChessPiece, rhs: MLChessPiece) -> Bool {
        return lhs.id == lhs.id
    }
}

