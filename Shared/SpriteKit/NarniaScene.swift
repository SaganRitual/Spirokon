// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SpriteKit
import SwiftUI

class NarniaScene: SKScene, ObservableObject, Spirokonable {
    let appModel: AppModel
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

    init(appModel: AppModel) {
        self.appModel = appModel

        super.init(size: CGSize(width: 2048, height: 2048))
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFit
        self.backgroundColor = .black

        self.dotter = Dotter(self, dotSize: CGSize(radius: 3))
        self.spirokon = Spirokon(appModel: appModel, ancestorOfAll: self)
    }

    override func didMove(to view: SKView) {
        var parent: Spirokonable = self
        for pixie in pixies {
            spirokon.addChild(pixie.ring, to: parent)
            spirokon.addChild(pixie.pen, to: pixie.ring)
            parent = pixie.ring
        }
    }

    func makePixieView(_ tumblerIx: Int) -> some View {
        let pm = PixieModel(tumblerIx)

        pm.addToScene(self)

        pixies.append(pm)

        let r = appModel.tumblers[tumblerIx].radius.publisher.sink {
            self.setRadius($0, for: tumblerIx)
        }

        radiusObservers.append(r)

        let p = appModel.tumblers[tumblerIx].pen.publisher.sink {
            self.setPen($0, for: tumblerIx)
        }

        penObservers.append(p)

        let s = appModel.tumblers[tumblerIx].showRing.publisher.sink {
            self.pixies[tumblerIx].showPixie($0)
        }

        showRingObservers.append(s)

        setRadius(appModel.tumblers[tumblerIx].radius.value, for: tumblerIx)
        setPen(appModel.tumblers[tumblerIx].pen.value, for: tumblerIx)

        return PixieView<TumblerModel>().environmentObject(appModel)
    }

    func penOffset(for tumblerIx: Int) -> Double {
        let offset = appModel.tumblers[tumblerIx].pen.value
        print("penOffset(for: \(tumblerIx) -> \(offset)")
        return offset
    }

    func pixieOffset(for tumblerIx: Int, modelRadius modelRadius_: Double? = nil) -> Double {
        let modelRadius = modelRadius_ ?? appModel.tumblers[tumblerIx].radius.value
        let forMyRadius = (1.0 - modelRadius)
        return forMyRadius
    }

    func pixieRadius(for tumblerIx: Int, modelRadius modelRadius_: Double? = nil) -> Double {
        let modelRadius = modelRadius_ ?? appModel.tumblers[tumblerIx].radius.value
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
        print("setPen(\(newPen), for: \(tumblerIx)")
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

    override func update(_ currentTime: TimeInterval) {
        guard let previousTickTime = self.previousTickTime else {
            self.previousTickTime = currentTime
            return
        }

        let deltaTime = currentTime - previousTickTime
        self.previousTickTime = currentTime

        // Don't do anything until the app settles. Rolling for
        // jumps of more than three frames looks ugly, and is probably
        // at least partly responsible for causing the app to
        // take longer to settle
        guard deltaTime < 3.0 / 60.0 else { return }

        let rotateBy = appModel.cycleSpeed.value * Double.tau * deltaTime

        spirokon.rollEverything(rotateBy: rotateBy)
        spirokon.dropDots(currentTime: currentTime, deltaTime: deltaTime)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
