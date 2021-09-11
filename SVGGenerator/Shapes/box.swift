
import Foundation



enum BoxCrenelDirection {
    
    
    case external
    case `internal`
}



struct BoxFaceCrenelConfig {

    
    var crenelConfig: CrenelConfig
    var numberOfCrenels: NumerOfCrenelsEnum
    var direction: BoxCrenelDirection
}



struct BoxFace: PathRepresentable {
        
    
    var width: MetricLength
    var height: MetricLength
    
    var leftCrenelConfig: BoxFaceCrenelConfig?
    var rightCrenelConfig: BoxFaceCrenelConfig?
    var topCrenelConfig: BoxFaceCrenelConfig?
    var bottomCrenelConfig: BoxFaceCrenelConfig?
    
    var punchLinesPositionYStartingFromBottom: [MetricLength] = []
    var punchLinesCrenelConfig: CrenelConfig? = nil
    
    
    var path: Path {
         
        var totalPath: Path = .empty
        
        let offsetLeft = leftCrenelConfig != nil && leftCrenelConfig!.direction == .external ? leftCrenelConfig!.crenelConfig.depth : 0.mm
        let offsetRight = rightCrenelConfig != nil && rightCrenelConfig!.direction == .external ? rightCrenelConfig!.crenelConfig.depth : 0.mm
        
        let offsetTop = topCrenelConfig != nil && topCrenelConfig!.direction == .external ? topCrenelConfig!.crenelConfig.depth : 0.mm
        let offsetBottom = bottomCrenelConfig != nil && bottomCrenelConfig!.direction == .external ? bottomCrenelConfig!.crenelConfig.depth : 0.mm
        
        totalPath.append(.moveToRelative(Coordinates(x: offsetLeft.toMillimeters, y: offsetTop.toMillimeters)))
        
        let horizontalLength = width - offsetLeft - offsetRight
        let verticalLength = height - offsetTop - offsetBottom
        
        if let crenelConfig = leftCrenelConfig {
            
            var crenelPath = CrenelSegment(
                totalLength: height,
                numberOfCrenels: crenelConfig.numberOfCrenels,
                crenelConfig: crenelConfig.crenelConfig,
                offsetStart: offsetTop,
                offsetEnd: -offsetBottom
            ).path.rotated90DegreesClockWise
            
            if crenelConfig.direction == .internal {
                crenelPath.mirrorX()
            }
            
            totalPath.append(crenelPath)
        } else {
            totalPath.append(.lineToRelative(Coordinates(x: 0, y: verticalLength.toMillimeters)))
        }
        
        if let crenelConfig = bottomCrenelConfig {
            
            var crenelPath = CrenelSegment(
                totalLength: width,
                numberOfCrenels: crenelConfig.numberOfCrenels,
                crenelConfig: crenelConfig.crenelConfig,
                offsetStart: offsetLeft,
                offsetEnd: -offsetRight
            ).path
            
            if crenelConfig.direction == .internal {
                crenelPath.mirrorY()
            }
            
            totalPath.append(crenelPath)
        } else {
            totalPath.append(.lineToRelative(Coordinates(x: horizontalLength.toMillimeters, y: 0)))
        }
        
        if let crenelConfig = rightCrenelConfig {
            
            var crenelPath = CrenelSegment(
                totalLength: height,
                numberOfCrenels: crenelConfig.numberOfCrenels,
                crenelConfig: crenelConfig.crenelConfig,
                offsetStart: offsetBottom,
                offsetEnd: -offsetTop
            ).path.rotated270DegreesClockWise
            
            if crenelConfig.direction == .internal {
                crenelPath.mirrorX()
            }
            
            totalPath.append(crenelPath)
        } else {
            totalPath.append(.lineToRelative(Coordinates(x: 0, y: -verticalLength.toMillimeters)))
        }
        
        if let crenelConfig = topCrenelConfig {
            
            var crenelPath = CrenelSegment(
                totalLength: width,
                numberOfCrenels: crenelConfig.numberOfCrenels,
                crenelConfig: crenelConfig.crenelConfig,
                offsetStart: offsetRight,
                offsetEnd: -offsetLeft
            ).path.rotated180DegreesClockWise
            
            if crenelConfig.direction == .internal {
                crenelPath.mirrorY()
            }
            
            totalPath.append(crenelPath)
        } else {
            totalPath.append(.lineToRelative(Coordinates(x: -horizontalLength.toMillimeters, y: 0)))
        }
        
        if !punchLinesPositionYStartingFromBottom.isEmpty {
            
            totalPath.append(.moveToRelative(Coordinates(x: -offsetLeft.toMillimeters, y: (-offsetTop + height).toMillimeters)))
            
            punchLinesPositionYStartingFromBottom.dropLast().forEach { h in
                
                let punchPath = PunchesSegment(
                    totalLength: width,
                    numberOfPunches: .auto,
                    crenelConfig: punchLinesCrenelConfig!,
                    offsetStart: 0.mm,
                    offsetEnd: 0.mm
                ).path
                
                totalPath.append(.moveToRelative(Coordinates(x: 0, y: -h.toMillimeters)))
                totalPath.append(punchPath)
                totalPath.append(.moveToRelative(Coordinates(x: -width.toMillimeters, y: 0)))
            }
        }
        
        return totalPath
    }
}



struct BoxCrenelConfig {

    
    var crenelConfig: CrenelConfig
    var numberOfCrenels: NumerOfCrenelsEnum
}



struct CrenelBox: PathsLayoutRepresentable {
    
    
    var width: MetricLength
    var length: MetricLength
    var height: MetricLength
    
    var widthCrenelConfig: BoxCrenelConfig
    var lengthCrenelConfig: BoxCrenelConfig
    var heightCrenelConfig: BoxCrenelConfig
    
    
    var pathsLayout: PathsLayout {
        
        let bottomFace = BoxFace(
            
            width: length,
            height: width,
            
            leftCrenelConfig: BoxFaceCrenelConfig(
                crenelConfig: widthCrenelConfig.crenelConfig,
                numberOfCrenels: widthCrenelConfig.numberOfCrenels,
                direction: .internal
            ),
            rightCrenelConfig: BoxFaceCrenelConfig(
                crenelConfig: widthCrenelConfig.crenelConfig,
                numberOfCrenels: widthCrenelConfig.numberOfCrenels,
                direction: .internal
            ),
            topCrenelConfig: BoxFaceCrenelConfig(
                crenelConfig: lengthCrenelConfig.crenelConfig,
                numberOfCrenels: lengthCrenelConfig.numberOfCrenels,
                direction: .internal
            ),
            bottomCrenelConfig: BoxFaceCrenelConfig(
                crenelConfig: lengthCrenelConfig.crenelConfig,
                numberOfCrenels: lengthCrenelConfig.numberOfCrenels,
                direction: .internal
            )
        )
        
        let frontBackFace = BoxFace(
            
            width: length,
            height: height,
            
            leftCrenelConfig: BoxFaceCrenelConfig(
                crenelConfig: heightCrenelConfig.crenelConfig,
                numberOfCrenels: heightCrenelConfig.numberOfCrenels,
                direction: .internal
            ),
            rightCrenelConfig: BoxFaceCrenelConfig(
                crenelConfig: heightCrenelConfig.crenelConfig,
                numberOfCrenels: heightCrenelConfig.numberOfCrenels,
                direction: .external
            ),
            topCrenelConfig: nil,
            bottomCrenelConfig: BoxFaceCrenelConfig(
                crenelConfig: lengthCrenelConfig.crenelConfig,
                numberOfCrenels: lengthCrenelConfig.numberOfCrenels,
                direction: .external
            )
        )
        
        let leftRightFace = BoxFace(
            
            width: width,
            height: height,
            
            leftCrenelConfig: BoxFaceCrenelConfig(
                crenelConfig: heightCrenelConfig.crenelConfig,
                numberOfCrenels: heightCrenelConfig.numberOfCrenels,
                direction: .internal
            ),
            rightCrenelConfig: BoxFaceCrenelConfig(
                crenelConfig: heightCrenelConfig.crenelConfig,
                numberOfCrenels: heightCrenelConfig.numberOfCrenels,
                direction: .external
            ),
            topCrenelConfig: nil,
            bottomCrenelConfig: BoxFaceCrenelConfig(
                crenelConfig: widthCrenelConfig.crenelConfig,
                numberOfCrenels: widthCrenelConfig.numberOfCrenels,
                direction: .external
            )
        )
        
        return PathsLayout(withVerticallyAlignedPaths: [
                            bottomFace.path(withName: "bottom"),
                            frontBackFace.path(withName: "front").transformedMirrorY,
                            frontBackFace.path(withName: "back"),
                            leftRightFace.path(withName: "left").transformedMirrorY,
                            leftRightFace.path(withName: "right"),
        ])
    }
}



struct LegoCrenelBox: PathsLayoutRepresentable {
    
    
    let legoUnitLength: MetricLength
    
    let width: LegoLength
    let length: LegoLength
    let height: LegoLength
    
    let crenelConfig: CrenelConfig
    
    let numberOfCrenelsWidth: NumerOfCrenelsEnum = .auto
    let numberOfCrenelsLength: NumerOfCrenelsEnum = .auto
    let numberOfCrenelsHeight: NumerOfCrenelsEnum = .auto
    
    
    var pathsLayout: PathsLayout {
        
        let box = CrenelBox(
            
            width: width.resolveToMetric(using: legoUnitLength),
            length: length.resolveToMetric(using: legoUnitLength),
            height: height.resolveToMetric(using: legoUnitLength),
            
            widthCrenelConfig: BoxCrenelConfig(crenelConfig: crenelConfig, numberOfCrenels: numberOfCrenelsWidth),
            lengthCrenelConfig: BoxCrenelConfig(crenelConfig: crenelConfig, numberOfCrenels: numberOfCrenelsLength),
            heightCrenelConfig: BoxCrenelConfig(crenelConfig: crenelConfig, numberOfCrenels: numberOfCrenelsHeight)
        )
        
        return box.pathsLayout
    }
}



struct LegoCrenelBoxCase: PathsLayoutRepresentable {
    
    
    let legoUnitLength: MetricLength
    
    let materialThickness: MetricLength
    let margin: MetricLength
    
    let width: LegoLength
    let length: LegoLength
    let height: LegoLength
    
    let crenelConfig: CrenelConfig
    
    let numberOfCrenelsWidth: NumerOfCrenelsEnum = .auto
    let numberOfCrenelsLength: NumerOfCrenelsEnum = .auto
    let numberOfCrenelsHeight: NumerOfCrenelsEnum = .auto
    
    
    var pathsLayout: PathsLayout {
        
        let box = CrenelBox(
            
            width: width.resolveToMetric(using: legoUnitLength) + 2 * materialThickness + margin,
            length: length.resolveToMetric(using: legoUnitLength) + 2 * materialThickness + margin,
            height: height.resolveToMetric(using: legoUnitLength) + materialThickness + margin,
            
            widthCrenelConfig: BoxCrenelConfig(crenelConfig: crenelConfig, numberOfCrenels: numberOfCrenelsWidth),
            lengthCrenelConfig: BoxCrenelConfig(crenelConfig: crenelConfig, numberOfCrenels: numberOfCrenelsLength),
            heightCrenelConfig: BoxCrenelConfig(crenelConfig: crenelConfig, numberOfCrenels: numberOfCrenelsHeight)
        )
        
        return box.pathsLayout
    }
}
