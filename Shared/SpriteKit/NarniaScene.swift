// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SpriteKit
import SwiftUI

class NarniaScene: SKScene, SKSceneDelegate, ObservableObject, Spirokonable {
    let appModel: AppModel
    let appState: AppState
    var dotter: Dotter!
    let llamaState: LlamaState
    let mainControlsState: MainControlsState
    var spirokon: Spirokon!

    var cycleDurationObserver: AnyCancellable!
    var previousTickTime: TimeInterval?
    var pixies = [PixieModel]()
    var drawObservers = [AnyCancellable]()
    var radiusObservers = [AnyCancellable]()
    var penObservers = [AnyCancellable]()
    var showRingObservers = [AnyCancellable]()

    // So the Spirokon can see the scene as the ancestor of all the rings n stuff
    // swiftlint:disable unused_setter_value
    var rotation: Double {
        get { 0 }
        set { preconditionFailure("Ancestor doesn't rotate") }
    }

    var spirokonChildren = [Spirokonable]()

    var spirokonParent: Spirokonable? {
        get { nil }
        set { preconditionFailure("Ancestor doesn't have a parent") }
    }

    var skNode: SKNode { self }
    // swiftlint:enable unused_setter_value

    var xPosition = SundellPublisher(0.0)

    init(
        appModel: AppModel, appState: AppState, llamaState: LlamaState, mainControlsState: MainControlsState
    ) {
        self.appModel = appModel
        self.appState = appState
        self.llamaState = llamaState
        self.mainControlsState = mainControlsState

        super.init(size: CGSize(width: 2048, height: 2048))
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFit
        self.backgroundColor = .black

        self.dotter = Dotter(mainControlsState, self, dotSize: CGSize(radius: 3))
        self.spirokon = Spirokon(appModel: appModel, appState: appState, ancestorOfAll: self)

        for tumblerIx in 0..<appModel.tumblers.count { makePixieModel(tumblerIx) }

        setSpirokonRelationships()
    }

    func makePixieModel(_ tumblerIx: Int) {
        let tumblerModel = appModel.tumblers[tumblerIx]
        let pm = PixieModel(tumblerModel)

        pm.addToScene(self)

        pixies.append(pm)
    }

    func penOffset(for tumblerIx: Int) -> Double {
        appState.tumblerStates[tumblerIx].penSliderState.trackingPosition.value
    }

    func pixieOffset(for tumblerIx: Int, modelRadius modelRadius_: Double? = nil) -> Double {
        let modelRadius = modelRadius_ ?? appState.tumblerStates[tumblerIx].radiusSliderState.trackingPosition.value
        let forMyRadius = tumblerIx == 0 ? 0.0 : (1.0 - modelRadius)
        return forMyRadius
    }

    func pixieRadius(for tumblerIx: Int, modelRadius modelRadius_: Double? = nil) -> Double {
        let modelRadius = modelRadius_ ?? appState.tumblerStates[tumblerIx].radiusSliderState.trackingPosition.value
        return modelRadius
    }

    func setSpirokonRelationships() {
        var parent: Spirokonable = self
        for pixie in pixies {
            spirokon.addChild(pixie.ring, to: parent)
            spirokon.addChild(pixie.pen, to: pixie.ring)
            parent = pixie.ring
        }
    }

    func getTumblerIx(for model: TumblerModel) -> Int {
        appModel.tumblers.firstIndex { $0.id == model.id }!
    }

    var cTicksInLimit = 0
    var deltas = Cbuffer<Double>(cElements: 100, mode: .putOnlyRing)

    override func update(_ currentTime: TimeInterval) {
        self.view!.showsFPS = true
        self.view!.showsNodeCount = true

        guard let previousTickTime = previousTickTime else {
            self.previousTickTime = currentTime
            return
        }

        // Ignore deltaTime > 1 frame, to prevent the huge leaps forward while
        // the app is still doing all its extra cpu usage up front. At some point
        // I should make a splash screen and wait for it to settle.
        let deltaTime = currentTime - previousTickTime
        let truncatedDeltaTime = min(deltaTime, 1.0 / 60.0)
        self.previousTickTime = currentTime

        let rotateBy = mainControlsState.cycleSpeed * Double.tau * truncatedDeltaTime
        let oversample = 1.0 / max(1.0, mainControlsState.dotDensity)

        for dt in stride(from: 0.0, to: truncatedDeltaTime, by: truncatedDeltaTime * oversample) {
            for t in appState.tumblerStates {
                t.radiusSliderState.update(deltaTime: truncatedDeltaTime * oversample)
                t.penSliderState.update(deltaTime: truncatedDeltaTime * oversample)
            }

            spirokon.rollEverything(rotateBy: rotateBy * oversample)

            // If the user slides to < 1 dot per tick, turn off all drawing
            if mainControlsState.dotDensity >= 1.0 {
                spirokon.dropDots(currentTime: self.previousTickTime! + dt, deltaTime: truncatedDeltaTime * oversample)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
