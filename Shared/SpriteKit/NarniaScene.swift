// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SpriteKit
import SwiftUI

class NarniaScene: SKScene, SKSceneDelegate, ObservableObject, Spirokonable {
    let appModel: AppModel
    let appState: AppState
    var dotter: Dotter!
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

    init(appModel: AppModel, appState: AppState) {
        self.appModel = appModel
        self.appState = appState

        super.init(size: CGSize(width: 2048, height: 2048))
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFit
        self.backgroundColor = .black

        self.dotter = Dotter(appState, self, dotSize: CGSize(radius: 3))
        self.spirokon = Spirokon(appModel: appModel, appState: appState, ancestorOfAll: self)
    }

    func makePixieView(_ tumblerIx: Int) -> some View {
        let pm = PixieModel(tumblerIx)

        pm.addToScene(self)

        pixies.append(pm)

        let r = appState.tumblerStates[tumblerIx].radiusSliderState.$trackingPosition.sink {
            self.setRadius($0, for: tumblerIx)
        }

        radiusObservers.append(r)

        let p =  appState.tumblerStates[tumblerIx].penSliderState.$trackingPosition.sink {
            self.setPen($0, for: tumblerIx)
        }

        penObservers.append(p)

        let s = appState.tumblerStates[tumblerIx].$showRing.sink {
            self.pixies[tumblerIx].showPixie($0)
        }

        showRingObservers.append(s)

        setRadius(appState.tumblerStates[tumblerIx].radiusSliderState.trackingPosition, for: tumblerIx)
        setPen(appState.tumblerStates[tumblerIx].penSliderState.trackingPosition, for: tumblerIx)

        return PixieView()
    }

    func penOffset(for tumblerIx: Int) -> Double {
        appState.tumblerStates[tumblerIx].penSliderState.trackingPosition
    }

    func pixieOffset(for tumblerIx: Int, modelRadius modelRadius_: Double? = nil) -> Double {
        let modelRadius = modelRadius_ ?? appState.tumblerStates[tumblerIx].radiusSliderState.trackingPosition
        let forMyRadius = tumblerIx == 0 ? 0.0 : (1.0 - modelRadius)
        return forMyRadius
    }

    func pixieRadius(for tumblerIx: Int, modelRadius modelRadius_: Double? = nil) -> Double {
        let modelRadius = modelRadius_ ?? appState.tumblerStates[tumblerIx].radiusSliderState.trackingPosition
        return modelRadius
    }

    func propagateScale(startAt: Int) {
        guard startAt < pixies.count - 1 else { return }

        for tumblerIx in startAt..<appModel.tumblers.count {
            let r = pixieRadius(for: tumblerIx)
            let p = pixieOffset(for: tumblerIx)

            pixies[tumblerIx].ring.size = CGSize(radius: r)
            pixies[tumblerIx].ring.position = CGPoint(x: p, y: 0)
        }
    }

    func setPen(_ newPen: Double, for tumblerIx: Int) {
        pixies[tumblerIx].pen.position.x = newPen
    }

    func setSpirokonRelationships() {
        var parent: Spirokonable = self
        for pixie in pixies {
            spirokon.addChild(pixie.ring, to: parent)
            spirokon.addChild(pixie.pen, to: pixie.ring)
            parent = pixie.ring
        }
    }

    func setRadius(_ newRadius: Double, for tumblerIx: Int) {
        let r = pixieRadius(for: tumblerIx, modelRadius: newRadius)
        let p = pixieOffset(for: tumblerIx, modelRadius: newRadius)

        pixies[tumblerIx].pen.position.x = penOffset(for: tumblerIx)
        pixies[tumblerIx].ring.size = CGSize(radius: r)
        pixies[tumblerIx].ring.position = CGPoint(x: p, y: 0)

        propagateScale(startAt: tumblerIx)
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

        if deltaTime < 0.02 {
            cTicksInLimit += 1
            if cTicksInLimit > 60 { appState.markComponentReady(.narnia) }
        } else if !appState.readyComponents.contains(.narnia) {
            cTicksInLimit = 0
        }

        if appState.readyComponents.contains(.pixieViews) && !appState.appIsReady {
            setSpirokonRelationships()
            appState.markComponentReady(.spirokon)
        }

        guard appState.appIsReady else {
            deltas.put(deltaTime)
            appState.llamasLlocated += 1
            appState.averageLlama = deltas.elements.reduce(0.0, { $0 + ($1 ?? 0.0) }) / Double(deltas.count)
            assert(appState.averageLlama.isFinite)
            return
        }

        let rotateBy = appState.cycleSpeed * Double.tau * truncatedDeltaTime
        let oversample = 1.0 / max(1.0, appState.dotDensity)

        for dt in stride(from: 0.0, to: truncatedDeltaTime, by: truncatedDeltaTime * oversample) {
            for t in appState.tumblerStates {
                t.radiusSliderState.update(deltaTime: truncatedDeltaTime)
                t.penSliderState.update(deltaTime: truncatedDeltaTime)
            }

            spirokon.rollEverything(rotateBy: rotateBy * oversample)

            // If the user slides to < 1 dot per tick, turn off all drawing
            if appState.dotDensity >= 1.0 {
                spirokon.dropDots(currentTime: self.previousTickTime! + dt, deltaTime: truncatedDeltaTime * oversample)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
