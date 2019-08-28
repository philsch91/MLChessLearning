import Cocoa

let paths = FileManager.default.urls(for: FileManager.SearchPathDirectory.desktopDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)

//var filename = paths[0].appendingPathComponent("MLChessLearningGames/NumeratorDenominator/W40-B40-WS40-BS40-WN-BD-29-BW.txt")
var filename = paths[0].appendingPathComponent("MLChessLearningGames/SimDepth/20-W60-B20-WS40-BS40-WN-BN-WPU-BPU-DRAW.txt")
//filename = filename.appendingPathComponent("MLChessGame.log")
print(filename)
/*
 var absfilestr = filename.absoluteString
 //print(absfilestr)
 let ext = filename.pathExtension
 //print(ext)
 let index = absfilestr.index(absfilestr.endIndex, offsetBy: (ext.lengthOfBytes(using: String.Encoding.utf8)+1)*(-1))
 let substr = absfilestr.prefix(upTo: index)
 let filestr = String(substr).appending(".json")
 let url = URL(string: filestr)
 print(url)
 */

let manager = MLGameLogManager(url: filename)
let string = manager.read()
//print(string)

var games: [MLChessGame]! = [MLChessGame]()
var jsonData = string.data(using: String.Encoding.utf8)!

//decode json

let decoder = JSONDecoder()
games = try? decoder.decode([MLChessGame].self, from: jsonData)

/*
 //append games from additional files
 manager.filename = paths[0].appendingPathComponent("MLChessLearningGames/W20-B60-WS40-BS40-3-DRAW-NEW.txt")
 let string2 = manager.read()
 var jsonData2 = string2.data(using: String.Encoding.utf8)!
 let games2 = try? decoder.decode([MLChessGame].self, from: jsonData2)
 games.append(contentsOf: games2)
 */

/*
 var batchfile = paths[0].appendingPathComponent("MLChessLearningGames/MLChessGameLearnBatch2.log")
 manager.filename = batchfile
 
 let batchstr = manager.read()
 var batch: MLChessBatch!
 var jsonData = batchstr.data(using: String.Encoding.utf8)!
 batch = try? decoder.decode(MLChessBatch.self, from: jsonData)
 */

print(games!)
print(games.count)

//MLChessGame -> MLChessBatch

//var batches = [ChessBatch]()
var batches = Array<MLChessBatch>()
batches.reserveCapacity(games.count)

//for game in games {
for index in 0...0 {
    let game = games[index]
    //var states = [[Int]]()
    var states = Array<Array<Double>>()
    var labels = Array<Int>()
    
    states.reserveCapacity(game.moves.count)
    labels.reserveCapacity(game.moves.count)
    
    //===== evaluate labels =====
    
    let winner: Int = game.winner
    //let endstate: [[MLChessPiece?]] = game.moves[game.moves.count-1]
    
    var i = 0
    for state in game.moves {
        //print(state)
        //var array = [Float]()
        //var array = Array<Int>()
        var array = Array<Double>()
        array.reserveCapacity(64)
        
        var whiteSum = 0
        var blackSum = 0
        var label = 0
        
        for row in 0...7 {
            for col in 0...7 {
                var value = 0
                var dbl = 0.5   //Double
                if let piece = state[row][col] {
                    //print(piece.id)
                    value = piece.id
                    
                    //normalize data
                    dbl = (Double(value)-(-10))/(10-(-10))
                    //dbl = (dbl*1000).rounded()/1000
                    
                    if piece.id > 0 {
                        whiteSum += piece.id
                    } else if piece.id < 0 {
                        blackSum += piece.id
                    }
                }
                //array.append(Float(value))
                //array.append(value)
                //print(dbl)
                array.append(dbl)
            }
        }
        
        //let shapedArray = ShapedArray(shape: [64, 1], scalars: array)
        //let tensor = Tensor<Float>(shapedArray)
        //print(tensor)
        //let batch = ChessBatch(states: tensor, labels: Tensor<Float>([1.0]))
        //batches.append(batch)
        
        //future lookup
        
        let initDiff = whiteSum + blackSum
        
        var betterBlackState = 0
        var betterWhiteState = 0
        var equalState = 0
        
        for j in i..<game.moves.count {
            let pieces: [[MLChessPiece?]] = game.moves[j]
            
            var futureWhiteSum = 0
            var futureBlackSum = 0
            
            for row in 0...7 {
                for col in 0...7 {
                    if let piece = pieces[row][col] {
                        if piece.id > 0 {
                            futureWhiteSum += piece.id
                        } else if piece.id < 0 {
                            futureBlackSum += piece.id
                        }
                    }
                }
            }
            
            let newDiff = futureWhiteSum + futureBlackSum
            futureBlackSum = futureBlackSum * (-1)
            
            if futureWhiteSum > futureBlackSum || newDiff > initDiff {
                betterWhiteState += 1
            } else if futureBlackSum > futureWhiteSum || newDiff < initDiff {
                betterBlackState += 1
            } else {
                equalState += 1
            }
        }
        
        //override label if game ended with a win
        //if winner != 0 && i >= (game.moves.count/4)*3 {
        if i == (game.moves.count-1) && winner != 0 {
            if winner == 1 {
                betterWhiteState = Int.max
            } else if winner == -1 {
                betterBlackState = Int.max
            }
        }
        
        //override label for the chess game opening
        if i <= (game.moves.count/10) {
            //betterWhiteState = betterBlackState
            i += 1
            continue
        }
        
        if betterWhiteState > betterBlackState {
            label = 0
        } else if betterBlackState > betterWhiteState {
            label = 1
        }
        
        states.append(array)
        labels.append(label)
        print("label:",label)
        
        i += 1
    }
    
    //let batch = MLChessBatch(states: states, active: game.active)
    //let batch = MLChessBatch(states: states, active: game.active, labels: Array<Int>(repeating: 1, count: states.count))
    let batch = MLChessBatch(states: states, labels: labels)
    batches.append(batch)
}

//print(batches.last!)

let newpaths = FileManager.default.urls(for: FileManager.SearchPathDirectory.desktopDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
let newfilename = newpaths[0].appendingPathComponent("MLChessLearningGames/master/MLChessGameLearnBatchMasterTest.txt")

let batchManager = MLChessBatchManager(url: newfilename)

for batch in batches {
    batchManager.persist(newBatch: batch)
}
