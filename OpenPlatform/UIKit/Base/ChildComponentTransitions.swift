import Foundation
import UIKit

internal extension Transition.Appear {
    static func `default`(scale: Bool = false, alpha: Bool = false) -> Transition.Appear {
        return Transition.Appear { component, view, transition in
            if scale {
                transition.animateScale(view: view, from: 0.01, to: 1.0)
            }
            if alpha {
                transition.animateAlpha(view: view, from: 0.0, to: 1.0)
            }
        }
    }

    static func scaleIn() -> Transition.Appear {
        return Transition.Appear { component, view, transition in
            transition.animateScale(view: view, from: 0.01, to: 1.0)
        }
    }
}

internal extension Transition.AppearWithGuide {
    static func `default`(scale: Bool = false, alpha: Bool = false) -> Transition.AppearWithGuide {
        return Transition.AppearWithGuide { component, view, guide, transition in
            if scale {
                transition.animateScale(view: view, from: 0.01, to: 1.0)
            }
            if alpha {
                transition.animateAlpha(view: view, from: 0.0, to: 1.0)
            }
            transition.animatePosition(view: view, from: CGPoint(x: guide.x - view.center.x, y: guide.y - view.center.y), to: CGPoint(), additive: true)
        }
    }
}

internal extension Transition.Disappear {
    static func `default`(scale: Bool = false, alpha: Bool = true) -> Transition.Disappear {
        return Transition.Disappear { view, transition, completion in
            if scale {
                transition.setScale(view: view, scale: 0.01, completion: { _ in
                    if !alpha {
                        completion()
                    }
                })
            }
            if alpha {
                transition.setAlpha(view: view, alpha: 0.0, completion: { _ in
                    completion()
                })
            }
            if !alpha && !scale {
                completion()
            }
        }
    }
}

internal extension Transition.DisappearWithGuide {
    static func `default`(alpha: Bool = true) -> Transition.DisappearWithGuide {
        return Transition.DisappearWithGuide { stage, view, guide, transition, completion in
            switch stage {
            case .begin:
                if alpha {
                    transition.setAlpha(view: view, alpha: 0.0, completion: { _ in
                        completion()
                    })
                }
                transition.setFrame(view: view, frame: CGRect(origin: CGPoint(x: guide.x - view.bounds.width / 2.0, y: guide.y - view.bounds.height / 2.0), size: view.bounds.size), completion: { _ in
                    if !alpha {
                        completion()
                    }
                })
            case .update:
                transition.setFrame(view: view, frame: CGRect(origin: CGPoint(x: guide.x - view.bounds.width / 2.0, y: guide.y - view.bounds.height / 2.0), size: view.bounds.size))
            }
        }
    }
}

internal extension Transition.Update {
    static let `default` = Transition.Update { component, view, transition in
        let frame = component.size.centered(around: component._position ?? CGPoint())
        if let scale = component._scale {
            transition.setBounds(view: view, bounds: CGRect(origin: CGPoint(), size: frame.size))
            transition.setPosition(view: view, position: frame.center)
            transition.setScale(view: view, scale: scale)
        } else {
            if view.frame != frame {
                transition.setFrame(view: view, frame: frame)
            }
        }
        let opacity = component._opacity ?? 1.0
        if view.alpha != opacity {
            transition.setAlpha(view: view, alpha: opacity)
        }
    }
}
