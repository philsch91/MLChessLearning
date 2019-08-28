import Foundation

public class MLChessBatchManager: MLGameLogManager {
    
    public func persist(newBatch: MLChessBatch) -> Void {
        //var batches: [MLChessBatch]!
        var batch: MLChessBatch!
        
        let str = self.read()
        
        if str == "" {
            print("empty")
            //batches = [MLChessBatch]()
            batch = newBatch
        } else {
            let decoder = JSONDecoder()
            let json = str.data(using: String.Encoding.utf8)!
            //batches = try? decoder.decode([MLChessBatch].self, from: json)
            batch = try? decoder.decode(MLChessBatch.self, from: json)
            
            batch.states.append(contentsOf: newBatch.states)
            batch.labels.append(contentsOf: newBatch.labels)
        }
        
        //batches.append(batch)
        
        let encoder = JSONEncoder()
        //encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
        let jsonData = try? encoder.encode(batch)
        
        if let json = String(data: jsonData!, encoding: String.Encoding.utf8){
            _ = self.clear()
            _ = self.write(string: json)
        }
    }
    
}
