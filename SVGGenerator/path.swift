
import Foundation



struct Coordinates: Equatable {

    
    var x: Float
    var y: Float
    
    
    mutating func add(_ other: Coordinates) {
        
        self = Coordinates(x: x + other.x, y: y + other.y)
    }
    
    
    var flipped: Coordinates { Coordinates(x: y, y: x) }
    
    var mirrorX: Coordinates { Coordinates(x: -x, y: y) }
    
    var mirrorY: Coordinates { Coordinates(x: x, y: -y) }
}



struct Size: Equatable {

    
    var width: Float
    var height: Float
    
    
    static var zero: Size { Size(width: 0, height: 0) }
}



struct CoordinatesBox: Equatable {

    
    var origin: Coordinates
    var size: Size
}



enum PathCommand {

    
    case moveToRelative(Coordinates)
    case lineToRelative(Coordinates)
    case close
}



class Path {
    
    
    var commands: [PathCommand]
    
    
    init(withCommands commands: [PathCommand]) {
        
        self.commands = commands
    }
    
    
    init(fromPath path: Path) {
        
        self.commands = path.commands
    }
    
    
    static var empty: Path { Path(withCommands: []) }
    
    
    func append(_ command: PathCommand) {
        
        commands.append(command)
    }
    
    
    func append(_ path: Path) {
        
        commands.append(contentsOf: path.commands)
    }
    
    
    func enumerateCoordinates(block: (Coordinates) -> Void) {
        
        var currentCoordinate = Coordinates(x: 0, y: 0)
        var firstShapePoint: Coordinates? = nil
        
        block(currentCoordinate)
        
        commands.forEach { command in
            
            switch command {
            
            case .moveToRelative(let coordinate):
                
                currentCoordinate.add(coordinate)
                
            case .lineToRelative(let coordinate):
                
                if firstShapePoint == nil {
                    firstShapePoint = currentCoordinate
                }
                currentCoordinate.add(coordinate)
                
            case .close:
                
                currentCoordinate = firstShapePoint!
            }
            
            block(currentCoordinate)
        }
    }
    
    
    var endPoint: Coordinates {
    
        var currentCoordinate = Coordinates(x: 0, y: 0)
        
        enumerateCoordinates { coordinate in
            
            currentCoordinate = coordinate
        }
        
        return currentCoordinate
    }
    
    
    var boundingBox: CoordinatesBox {
        
        var smallestCoordinate: Coordinates! = nil
        var biggestCoordinate: Coordinates! = nil
        
        enumerateCoordinates { coordinate in
        
            if smallestCoordinate == nil {
                smallestCoordinate = coordinate
            }
            if biggestCoordinate == nil {
                biggestCoordinate = coordinate
            }
            
            if coordinate.x > biggestCoordinate.x {
                biggestCoordinate.x = coordinate.x
            }
            if coordinate.y > biggestCoordinate.y {
                biggestCoordinate.y = coordinate.y
            }
            
            if coordinate.x < smallestCoordinate.x {
                smallestCoordinate.x = coordinate.x
            }
            if coordinate.y < smallestCoordinate.y {
                smallestCoordinate.y = coordinate.y
            }
        }
        
        let origin: Coordinates! = smallestCoordinate.x < 0 || smallestCoordinate.y < 0 ? smallestCoordinate : Coordinates(x: 0, y: 0)
        let size = Size(width: biggestCoordinate.x - origin.x, height: biggestCoordinate.y - origin.y)
        
        return CoordinatesBox(origin: origin, size: size)
    }
    
    
    func transformCommandsWith(transform: (PathCommand) -> PathCommand) {
    
        commands = commands.map(transform)
    }
    
    
    func transformCommandsCoordinatesWith(transform: (Coordinates) -> Coordinates) {
        
        transformCommandsWith { command in
            
            switch command {
            
            case .moveToRelative(let coordinate):
                
                return .moveToRelative(transform(coordinate))
                
            case .lineToRelative(let coordinate):
                
                return .lineToRelative(transform(coordinate))
                
            case .close:
                
                return .close
            }
        }
    }
    
    
    func flip() {
        
        self.transformCommandsCoordinatesWith { $0.flipped }
    }
    
    
    var flipped: Path {
        
        let path = Path(fromPath: self)
        path.flip()
        return path
    }
    
    
    func mirrorX() {
        
        self.transformCommandsCoordinatesWith { $0.mirrorX }
    }
    
    
    func mirrorY() {
        
        self.transformCommandsCoordinatesWith { $0.mirrorY }
    }
    
    
    var transformedMirrorX: Path {
        
        let path = Path(fromPath: self)
        path.mirrorX()
        return path
    }
    
    
    var transformedMirrorY: Path {
        
        let path = Path(fromPath: self)
        path.mirrorY()
        return path
    }
    
    
    var rotated90DegreesClockWise: Path { self.flipped.transformedMirrorX }
    var rotated180DegreesClockWise: Path { self.rotated90DegreesClockWise.rotated90DegreesClockWise }
    var rotated270DegreesClockWise: Path { self.rotated180DegreesClockWise.rotated90DegreesClockWise }
}
