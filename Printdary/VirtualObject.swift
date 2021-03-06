/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Wrapper SceneKit node for virtual objects placed into the AR scene.
*/

import Foundation
import SceneKit
import ARKit

struct VirtualObjectDefinition: Codable, Equatable {
    let modelName: String
    let displayName: String
    let particleScaleInfo: [String: Float]
    
    lazy var thumbImage: UIImage = UIImage(named: self.modelName)!
    
    init(modelName: String, displayName: String, particleScaleInfo: [String: Float] = [:]) {
        self.modelName = modelName
        self.displayName = displayName
        self.particleScaleInfo = particleScaleInfo
    }
    
    static func ==(lhs: VirtualObjectDefinition, rhs: VirtualObjectDefinition) -> Bool {
        return lhs.modelName == rhs.modelName
            && lhs.displayName == rhs.displayName
            && lhs.particleScaleInfo == rhs.particleScaleInfo
    }
}

class VirtualObject: SCNReferenceNode, ReactsToScale {
    let definition: VirtualObjectDefinition
	var textures: [String] = []
	var audioURL: URL? = nil
    
    init(definition: VirtualObjectDefinition) {
        self.definition = definition
        if let url = Bundle.main.url(forResource: "Models.scnassets/\(definition.modelName)/\(definition.modelName)", withExtension: "scn") {
            super.init(url: url)!
        } else if let url = Bundle.main.url(forResource: "Models.scnassets/\(definition.modelName)/\(definition.modelName)", withExtension: "DAE") {
            super.init(url: url)!
        } else if let url = Bundle.main.url(forResource: "Models.scnassets/\(definition.modelName)/\(definition.modelName)", withExtension: "obj") {
            super.init(url: url)!
        } else if let url = Bundle.main.url(forResource: "Models.scnassets/\(definition.modelName)/\(definition.modelName)", withExtension: "abc") {
            super.init(url: url)!
        } else {
            fatalError("can't find expected virtual object bundle resources")
        }
    }
    
    override init(url: URL) {
        definition = VirtualObjectDefinition(modelName: "", displayName: "")
        super.init(url: url)!
		self.scale = SCNVector3(0.0015, 0.0015, 0.0015)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Use average of recent virtual object distances to avoid rapid changes in object scale.
    var recentVirtualObjectDistances = [Float]()
    
    func reactToScale() {
        for (nodeName, particleSize) in definition.particleScaleInfo {
            guard let node = self.childNode(withName: nodeName, recursively: true), let particleSystem = node.particleSystems?.first
                else { continue }
            particleSystem.reset()
            particleSystem.particleSize = CGFloat(scale.x * particleSize)
        }
    }
}

extension VirtualObject {
	
	static func isNodePartOfVirtualObject(_ node: SCNNode) -> VirtualObject? {
		if let virtualObjectRoot = node as? VirtualObject {
			return virtualObjectRoot
		}
		
		if node.parent != nil {
			return isNodePartOfVirtualObject(node.parent!)
		}
		
		return nil
	}
    
}

// MARK: - Protocols for Virtual Objects

protocol ReactsToScale {
	func reactToScale()
}

extension SCNNode {
	
	func reactsToScale() -> ReactsToScale? {
		if let canReact = self as? ReactsToScale {
			return canReact
		}
		
		if parent != nil {
			return parent!.reactsToScale()
		}
		
		return nil
	}
}
