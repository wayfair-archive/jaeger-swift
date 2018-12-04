import UIKit

class UIPerformance {

    private var firstTime: TimeInterval = 0.0
    private var lastTime: TimeInterval = 0.0
    private var isStarted = false

    func start() {
        guard self.isStarted == false else {return}
        self.isStarted = true
        // Add CADisplayLink to track frame drops
        let link = CADisplayLink(target: self, selector: #selector(self.update(link:)))
        link.add(to: .main, forMode: .common)
    }

    @objc private func update(link: CADisplayLink) {
        if lastTime == 0 {
            firstTime = link.timestamp
            lastTime = link.timestamp
        }

        let currentTime = link.timestamp

        let elapsedTime = floor((currentTime - lastTime) * 10_000)/10
        let totalElapsedTime = currentTime - firstTime
        if elapsedTime > 16.7 { // we want 60fps
            print("Frame was dropped with elpased time of \(elapsedTime)ms at \(totalElapsedTime)")
        }
        lastTime = link.timestamp
    }
}
