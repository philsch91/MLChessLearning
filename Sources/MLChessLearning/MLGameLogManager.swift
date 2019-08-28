//
//  MLGameLogManager.swift
//  
//
//  Created by Philipp Schunker on 28.05.19.
//

import Foundation

public class MLGameLogManager {
    
    public let filename: URL!
    
    public init() {
        let paths = FileManager.default.urls(for: FileManager.SearchPathDirectory.desktopDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
        self.filename = paths[0].appendingPathComponent("MLChessGame.log")
    }
    
    public init(url: URL) {
        self.filename = url
    }
    
    func write(string: String) -> Bool {
        do {
            let fh = try FileHandle(forWritingTo: self.filename)
            fh.seekToEndOfFile()
            fh.write(string.data(using: String.Encoding.utf8)!)
            fh.closeFile()
        } catch {
            return false
        }
        return true
    }
    
    public func read() -> String {
        do {
            let str = try String(contentsOf: self.filename, encoding: String.Encoding.utf8)
            return str
        } catch {
            return ""
        }
    }
    
    func clear() -> Bool {
        do {
            try "".write(to: self.filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            return false
        }
        return true
    }
    
    public func save(game: MLChessGame) -> Void {
        var games: [MLChessGame]!
        
        let str = self.read()
        
        if str == "" {
            print("empty")
            games = [MLChessGame]()
        } else {
            let decoder = JSONDecoder()
            let json = str.data(using: String.Encoding.utf8)!
            games = try? decoder.decode([MLChessGame].self, from: json)
        }
        
        games.append(game)
        
        let encoder = JSONEncoder()
        //encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
        //let jsonData = try? encoder.encode(self.game)
        let jsonData = try? encoder.encode(games)
        
        if let json = String(data: jsonData!, encoding: String.Encoding.utf8){
            _ = self.clear()
            _ = self.write(string: json)
        }
    }
    
}
