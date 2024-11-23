//
//  ContentView.swift
//  Rubix AR Assistant
//
//  Created by Isabella Pena on 11/21/24.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure ARKit for image detection
        let configuration = ARWorldTrackingConfiguration()
        if let referenceImages = ARReferenceImage.referenceImages(
            inGroupNamed: "ImageAnchors", // Match your AR Resource Group name
            bundle: nil
        ) {
            configuration.detectionImages = referenceImages
            configuration.maximumNumberOfTrackedImages = 1 // Track only one image
            print("Successfully loaded ARReferenceImages")
        } else {
            print("Failed to load ARReferenceImages")
        }
        
        arView.session.run(configuration)
        
        // Add a delegate to handle image detection and updates
        arView.session.delegate = context.coordinator
        context.coordinator.arView = arView // Pass ARView to the Coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let imageAnchor = anchor as? ARImageAnchor {
                    print("Image detected!")
                    
                    // Add AR content anchored to the sticker
                    addCube(to: imageAnchor)
                }
            }
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                if let imageAnchor = anchor as? ARImageAnchor {
                    print("Image anchor updated!")
                    updateCubePosition(for: imageAnchor)
                }
            }
        }
        
        func addCube(to imageAnchor: ARImageAnchor) {
            guard let arView = arView else { return }
            
            let cube = ModelEntity(mesh: .generateBox(size: 0.1))
            cube.model?.materials = [SimpleMaterial(color: .red, roughness: 0.5, isMetallic: true)]
            
            let anchorEntity = AnchorEntity(anchor: imageAnchor)
            anchorEntity.addChild(cube)
            
            arView.scene.addAnchor(anchorEntity)
        }
        
        func updateCubePosition(for imageAnchor: ARImageAnchor) {
            guard let arView = arView else { return }
            
            // Find the existing anchor entity for this anchor
            if let anchorEntity = arView.scene.anchors.first(where: { $0.anchorIdentifier == imageAnchor.identifier }) {
                anchorEntity.transform = Transform(matrix: imageAnchor.transform)
            }
        }
    }
}
#Preview {
    ContentView()
}
