
import Foundation



struct LegoLength {
    
    let numberOfLegoUnits: Float
    
    static let unitsPerPlate: Float = 1
    static let unitsPerStud: Float = 2.5
    
    init(plates numberOfPlates: Float) {
        
        self.numberOfLegoUnits = numberOfPlates * Self.unitsPerPlate
    }
    
    init(studs numberOfStuds: Float) {
        
        self.numberOfLegoUnits = numberOfStuds * Self.unitsPerStud
    }
    
    func resolve(using legoUnitDimension: Float) -> Float {
        
        return numberOfLegoUnits * legoUnitDimension
    }
}


extension Float {
    
    var plates: LegoLength { LegoLength(plates: self) }
    
    var studs: LegoLength { LegoLength(studs: self) }
}


extension Int {
    
    var plates: LegoLength { Float(self).plates }
    
    var studs: LegoLength { Float(self).studs }
}
