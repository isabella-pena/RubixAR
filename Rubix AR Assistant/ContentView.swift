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
            inGroupNamed: "ImageAnchors", // Match the name of your AR Resource Group
            bundle: nil
        ) {
            configuration.detectionImages = referenceImages
            print("Successfully loaded ARReferenceImages")
        } else {
            print("Failed to load ARReferenceImages")
        }

        arView.session.run(configuration)

        // Add a delegate to respond to image detection
        arView.session.delegate = context.coordinator
        context.coordinator.arView = arView

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
                    addCube(to: imageAnchor)
                }
            }
        }

        func addCube(to imageAnchor: ARImageAnchor) {
            guard let arView = arView else { return }

            // Create a cube to place on the detected image
            let cube = ModelEntity(mesh: .generateBox(size: 0.1))
            cube.model?.materials = [SimpleMaterial(color: .red, roughness: 0.5, isMetallic: true)]

            // Create an anchor entity at the detected image's position
            let anchorEntity = AnchorEntity(world: imageAnchor.transform)
            anchorEntity.addChild(cube)

            // Add the anchor entity to the ARView scene
            arView.scene.addAnchor(anchorEntity)
        }
    }
}

#Preview {
    ContentView()
}
