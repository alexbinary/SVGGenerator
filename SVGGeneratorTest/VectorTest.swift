
import XCTest

@testable import SVGGenerator



class VectorTest: XCTestCase {


    func test_init_xy() {

        let coordinates = Vector(x: 1, y: 2)
        
        XCTAssertEqual(coordinates.x, 1)
        XCTAssertEqual(coordinates.y, 2)
    }
    
    
    func test_equatable() {

        let c1 = Vector(x: 1, y: 2)
        let c2 = Vector(x: 1, y: 2)
        
        XCTAssertEqual(c1, c2)
        XCTAssertTrue(c1 == c2)
    }
    
    
    func test_zero() {

        let zero = Vector.zero
        
        XCTAssertEqual(zero, Vector(x: 0, y: 0))
    }
    
    
    func test_operator_plus() {

        let c1 = Vector(x: 1, y: 2)
        let c2 = Vector(x: 3, y: 4)
        
        let c3 = c1 + c2
        
        XCTAssertEqual(c3, Vector(x: 4, y: 6))
    }
    
    
    func test_operator_minus() {

        let c1 = Vector(x: 1, y: 2)
        let c2 = Vector(x: 3, y: 4)
        
        let c3 = c1 - c2
        
        XCTAssertEqual(c3, Vector(x: -2, y: -2))
    }
    
    
    func test_operator_plus_equal() {

        var c1 = Vector(x: 1, y: 2)
        let c2 = Vector(x: 3, y: 4)
        
        c1 += c2
        
        XCTAssertEqual(c1, Vector(x: 4, y: 6))
        XCTAssertEqual(c2, Vector(x: 3, y: 4))
    }
    
    
    func test_add() {

        var c1 = Vector(x: 1, y: 2)
        let c2 = Vector(x: 3, y: 4)
        
        c1.add(c2)
        
        XCTAssertEqual(c1, Vector(x: 4, y: 6))
        XCTAssertEqual(c2, Vector(x: 3, y: 4))
    }
    
    
    func test_flipped() {

        let c1 = Point(x: 1, y: 2)
        let c2 = c1.flipped
        
        XCTAssertEqual(c1, Vector(x: 1, y: 2))
        XCTAssertEqual(c2, Vector(x: 2, y: 1))
    }
    
    
    func test_mirrorX() {

        let c1 = Vector(x: 1, y: 2)
        let c2 = c1.mirrorX
        
        XCTAssertEqual(c1, Vector(x: 1, y: 2))
        XCTAssertEqual(c2, Vector(x: -1, y: 2))
    }
    
    
    func test_mirrorY() {

        let c1 = Vector(x: 1, y: 2)
        let c2 = c1.mirrorY
        
        XCTAssertEqual(c1, Vector(x: 1, y: 2))
        XCTAssertEqual(c2, Vector(x: 1, y: -2))
    }
}
