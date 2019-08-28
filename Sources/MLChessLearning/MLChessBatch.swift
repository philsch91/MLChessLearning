import Foundation

public struct MLChessBatch: Codable {
    public var states: [[Double]]
    public var labels: [Int]
    
    public init(states: [[Double]], labels: [Int]){
        self.states = states
        self.labels = labels
    }
    
    enum CodingKeys: String, CodingKey {
        case states
        case labels
    }
}
