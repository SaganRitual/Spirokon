// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SpriteKit
import SwiftUI

class NarniaScene: SKScene, ObservableObject {
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

    init(appModel: AppModel) {
        self.appModel = appModel

        super.init(size: CGSize(width: 2048, height: 2048))
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scaleMode = .aspectFit
        self.backgroundColor = .black

        self.dotter = Dotter(self, dotSize: CGSize(radius: 3))
        self.spirokon = Spirokon(nscene: self)
    }

    func makePixieView(_ tumblerIx: Int) -> some View {
        let pm = PixieModel(tumblerIx, 2.0 * (1.5 + Double(tumblerIx)))

        if pixies.isEmpty { pm.beAdopted(by: self) } else { pm.beAdopted(by: pixies.last!) }

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
        appModel.tumblers[tumblerIx].pen.value * pixies[tumblerIx].armSprite.size.width
    }

    func pixieOffset(for tumblerIx: Int, modelRadius modelRadius_: Double? = nil) -> Double {
        let modelRadius = modelRadius_ ?? appModel.tumblers[tumblerIx].radius.value
        let zipScale = appModel.tumblers[0..<tumblerIx].reversed().reduce(1) { $0 * $1.radius.value }
        let forMyRadius = (1.0 - modelRadius)
        let normalOffset = zipScale * forMyRadius

        return size.radius * normalOffset
    }

    func pixieRadius(for tumblerIx: Int, modelRadius modelRadius_: Double? = nil) -> Double {
        let modelRadius = modelRadius_ ?? appModel.tumblers[tumblerIx].radius.value
        let zipScale = appModel.tumblers[0..<tumblerIx].reversed().reduce(1) { $0 * $1.radius.value }
        let normalRadius = zipScale * modelRadius

        return size.radius * normalRadius
    }

    func propagateScale(startAt: Int) {
        guard startAt < pixies.count - 1 else { return }

        for tumblerIx in startAt..<appModel.tumblers.count {
            let r = pixieRadius(for: tumblerIx)
            let p = pixieOffset(for: tumblerIx)

            pixies[tumblerIx].armSprite.size = CGSize(width: r, height: 3)
            pixies[tumblerIx].ringSprite.size = CGSize(radius: r)
            pixies[tumblerIx].ringSprite.position = CGPoint(x: p, y: 0)
        }
    }

    func setPen(_ newPen: Double, for tumblerIx: Int) {
        pixies[tumblerIx].penSprite.position.x = newPen * pixies[tumblerIx].armSprite.size.width
    }

    func setRadius(_ newRadius: Double, for tumblerIx: Int) {
        let r = pixieRadius(for: tumblerIx, modelRadius: newRadius)
        let p = pixieOffset(for: tumblerIx, modelRadius: newRadius)

        pixies[tumblerIx].penSprite.position.x = penOffset(for: tumblerIx)
        pixies[tumblerIx].armSprite.size = CGSize(width: r, height: 3)
        pixies[tumblerIx].ringSprite.size = CGSize(radius: r)
        pixies[tumblerIx].ringSprite.position = CGPoint(x: p, y: 0)

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

        spirokon.rotate(deltaTime: deltaTime)
        spirokon.dropDots(currentTime: currentTime, deltaTime: deltaTime)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
