import Foundation
import UIKit
import ObjectiveC

internal class ComponentLayoutResult {
    var availableSize: CGSize?
    var size: CGSize?
}

internal protocol _TypeErasedComponentContext: AnyObject {
    var erasedEnvironment: _Environment { get }
    var erasedState: ComponentState { get }

    var layoutResult: ComponentLayoutResult { get }
}

internal class AnyComponentContext<EnvironmentType>: _TypeErasedComponentContext {
    var erasedComponent: AnyComponent<EnvironmentType> {
        get {
            preconditionFailure()
        } set(value) {
            preconditionFailure()
        }
    }
    var erasedState: ComponentState {
        preconditionFailure()
    }
    var erasedEnvironment: _Environment {
        get {
            return self.environment
        } set(value) {
            self.environment = value as! Environment<EnvironmentType>
        }
    }

    let layoutResult: ComponentLayoutResult
    var environment: Environment<EnvironmentType>

    init(environment: Environment<EnvironmentType>) {
        self.layoutResult = ComponentLayoutResult()
        self.environment = environment
    }
}

internal class ComponentContext<ComponentType: Component>: AnyComponentContext<ComponentType.EnvironmentType> {
    override var erasedComponent: AnyComponent<ComponentType.EnvironmentType> {
        get {
            return AnyComponent(self.component)
        } set(value) {
            self.component = value.wrapped as! ComponentType
        }
    }

    var component: ComponentType
    let state: ComponentType.State

    override var erasedState: ComponentState {
        return self.state
    }

    init(component: ComponentType, environment: Environment<ComponentType.EnvironmentType>, state: ComponentType.State) {
        self.component = component
        self.state = state
        
        super.init(environment: environment)
    }
}

private var UIView_TypeErasedComponentContextKey: Int?

internal extension UIView {
    func context<EnvironmentType>(component: AnyComponent<EnvironmentType>) -> AnyComponentContext<EnvironmentType> {
        return self.context(typeErasedComponent: component) as! AnyComponentContext<EnvironmentType>
    }

    func context<ComponentType: Component>(component: ComponentType) -> ComponentContext<ComponentType> {
        return self.context(typeErasedComponent: component) as! ComponentContext<ComponentType>
    }

    func context(typeErasedComponent component: _TypeErasedComponent) -> _TypeErasedComponentContext{
        if let context = objc_getAssociatedObject(self, &UIView_TypeErasedComponentContextKey) as? _TypeErasedComponentContext {
            return context
        } else {
            let context = component._makeContext()
            objc_setAssociatedObject(self, &UIView_TypeErasedComponentContextKey, context, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return context
        }
    }
}

internal class ComponentState {
    open var _updated: ((Transition, Bool) -> Void)?
    var isUpdated: Bool = false
    
    public init() {
    }
    
    public final func updated(transition: Transition = .immediate, isLocal: Bool = false) {
        self.isUpdated = true
        self._updated?(transition, isLocal)
    }
}

internal final class EmptyComponentState: ComponentState {
}

internal protocol _TypeErasedComponent {
    func _makeView() -> UIView
    func _makeContext() -> _TypeErasedComponentContext
    func _update(view: UIView, availableSize: CGSize, environment: Any, transition: Transition) -> CGSize
    func _isEqual(to other: _TypeErasedComponent) -> Bool
}

internal protocol ComponentTaggedView: UIView {
    func matches(tag: Any) -> Bool
}

internal final class GenericComponentViewTag {
    public init() {
    }
}

internal protocol Component: _TypeErasedComponent, Equatable {
    associatedtype EnvironmentType = Empty
    associatedtype View: UIView = UIView
    associatedtype State: ComponentState = EmptyComponentState
    
    func makeView() -> View
    func makeState() -> State
    func update(view: View, availableSize: CGSize, state: State, environment: Environment<EnvironmentType>, transition: Transition) -> CGSize
}

internal extension Component {
    func _makeView() -> UIView {
        return self.makeView()
    }

    func _makeContext() -> _TypeErasedComponentContext {
        return ComponentContext<Self>(component: self, environment: Environment<EnvironmentType>(), state: self.makeState())
    }

    func _update(view: UIView, availableSize: CGSize, environment: Any, transition: Transition) -> CGSize {
        let view = view as! Self.View
        
        return self.update(view: view, availableSize: availableSize, state: view.context(component: self).state, environment: environment as! Environment<EnvironmentType>, transition: transition)
    }

    func _isEqual(to other: _TypeErasedComponent) -> Bool {
        if let other = other as? Self {
            return self == other
        } else {
            return false
        }
    }
}

internal extension Component where Self.View == UIView {
    func makeView() -> UIView {
        return UIView()
    }
}

internal extension Component where Self.State == EmptyComponentState {
    func makeState() -> State {
        return EmptyComponentState()
    }
}

internal class ComponentGesture {
    public static func tap(action: @escaping() -> Void) -> ComponentGesture {
        preconditionFailure()
    }
}

internal class AnyComponent<EnvironmentType>: _TypeErasedComponent, Equatable {
    public let wrapped: _TypeErasedComponent

    public init<ComponentType: Component>(_ component: ComponentType) where ComponentType.EnvironmentType == EnvironmentType {
        self.wrapped = component
    }

    public static func ==(lhs: AnyComponent<EnvironmentType>, rhs: AnyComponent<EnvironmentType>) -> Bool {
        return lhs.wrapped._isEqual(to: rhs.wrapped)
    }

    public func _makeView() -> UIView {
        return self.wrapped._makeView()
    }

    public func _makeContext() -> _TypeErasedComponentContext {
        return self.wrapped._makeContext()
    }

    public func _update(view: UIView, availableSize: CGSize, environment: Any, transition: Transition) -> CGSize {
        return self.wrapped._update(view: view, availableSize: availableSize, environment: environment as! Environment<EnvironmentType>, transition: transition)
    }

    public func _isEqual(to other: _TypeErasedComponent) -> Bool {
        return self.wrapped._isEqual(to: other)
    }
}

internal final class AnyComponentWithIdentity<Environment>: Equatable {
    public let id: AnyHashable
    public let component: AnyComponent<Environment>

    public init<IdType: Hashable>(id: IdType, component: AnyComponent<Environment>) {
        self.id = AnyHashable(id)
        self.component = component
    }

    public static func == (lhs: AnyComponentWithIdentity<Environment>, rhs: AnyComponentWithIdentity<Environment>) -> Bool {
        if lhs.id != rhs.id {
            return false
        }
        if lhs.component != rhs.component {
            return false
        }
        return true
    }
}
