//
//  GameViewController.swift
//  PhuongTrinhDt
//
//  Created by Le Tan Thanh on 7/13/18.
//  Copyright © 2018 Le Tan Thanh. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    @IBOutlet var scnView: SCNView!
    var startPoint:SCNVector3?
    var endPoint:SCNVector3?
    var num = 3
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
       let scene = SCNScene()
        scnView.backgroundColor = .black
        scnView.showsStatistics = true
        scnView.allowsCameraControl = true
        scnView.scene = scene
        
        
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers

    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are clicked
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        var projectDepth:CGFloat = 0.0
        if let result = hitResults.first {
            let nodeSelected = result.node
            projectDepth = nodeSelected.position.z
        }
        print("p :\(p)")
        let vec3 = SCNVector3Make(p.x, p.y, 0)
        var unprj = scnView.unprojectPoint(vec3)
        
        print("\(unprj)")
        if let startPoint = self.startPoint {
            endPoint = unprj
            drawLine(startPoint, to: unprj)
            self.startPoint = unprj
        } else {
            self.startPoint = unprj
        }
    }
    
    func drawLine(_ startPoint:SCNVector3, to endPoint:SCNVector3) {
        let indices = [1,2]
        let element = SCNGeometryElement(indices:indices, primitiveType: SCNGeometryPrimitiveType.line)
        let sources = SCNGeometrySource(vertices: [startPoint,endPoint])
        let geometry = SCNGeometry(sources: [sources], elements:[element])
        geometry.firstMaterial?.isDoubleSided = true
        geometry.firstMaterial?.diffuse.contents = NSColor.red
        let node = SCNNode(geometry: geometry)
        
        createEquationLinear(startPoint: startPoint, endPoint: endPoint)
        scnView.scene?.rootNode.addChildNode(node)
    }
    
    func createEquationLinear(startPoint:SCNVector3, endPoint:SCNVector3) {
        let directVector = subtraction(startPoint, vectorB: endPoint)
        let a:Double = Double(directVector.x)
        let b:Double = Double(directVector.y)
        let c:Double = Double(directVector.z)
        /* Line x = startpoint.x + a * t
                y = startpoint.y + b * t
                z = startpoint.z + c * t
        
         */
        var lengthLine = length(directVector)
        var listPoints:[SCNVector3] = []
        for i in 1 ..< num  {
            let smallLength = lengthLine * Double(i)/Double(num)
            let results = getCoefficient(start: startPoint, with: directVector, smallLength: smallLength, length: lengthLine)
            
            let point1 = SCNVector3(Double(startPoint.x) + a * results.result1,
                                    Double(startPoint.y) + b * results.result1,
                                    Double(startPoint.z) + c * results.result1)
            let point2 = SCNVector3(Double(startPoint.x) + a * results.result2,
                                    Double(startPoint.y) + b * results.result2,
                                    Double(startPoint.z) + c * results.result2)
            
            print("Point1 :\(point1)")
            print("point2 :\(point2)")
            let directPoint1 = subtraction(point1, vectorB: endPoint)
            let value1 = length(directPoint1)
            if value1 < lengthLine {
                listPoints.append(point1)
            } else {
                listPoints.append(point2)
            }
        }
        
        print("listPoints :\(listPoints)")
      
    }
    
    func getCoefficient(start startPoint:SCNVector3,
                  with directVector:SCNVector3 ,
                  smallLength:Double, length:Double) -> (result1 : Double, result2: Double)  {
        /*
         (a * t)^2 + (b*t)^2 + (c*t)^2 = smallLength^2
         => t^2 = smallLength^2/ (a^2 + b^2 + c^2)
         => t = +/- sqrt(smallLength^2/(a^2 + b^2 + c^2))
         */
        let lengthPow2 = pow(smallLength, 2)
        let denominator = Double(pow(directVector.x, 2) + pow(directVector.y, 2) + pow(directVector.z, 2))
        let t = lengthPow2/denominator
        return (sqrt(t), -sqrt(t))
        
    }
    
    func subtraction(_ vectorA:SCNVector3, vectorB: SCNVector3) -> SCNVector3 {
        return SCNVector3(vectorB.x - vectorA.x,vectorB.y - vectorA.y,vectorB.z - vectorA.z)
    }
    
    func length(_ vector:SCNVector3) -> Double {
        let xPow2 = pow(vector.x, 2)
        let yPow2 = pow(vector.y, 2)
        let zPow2 = pow(vector.z, 2)
        return Double(sqrt(xPow2 + yPow2 + zPow2))
    }
}
