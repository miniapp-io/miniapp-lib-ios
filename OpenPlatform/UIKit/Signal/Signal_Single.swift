import Foundation

internal func single<T, E>(_ value: T, _ errorType: E.Type) -> Signal<T, E> {
    return Signal<T, E> { subscriber in
        subscriber.putNext(value)
        subscriber.putCompletion()
        
        return EmptyDisposable
    }
}

internal func fail<T, E>(_ valueType: T.Type, _ error: E) -> Signal<T, E> {
    return Signal<T, E> { subscriber in
        subscriber.putError(error)
        
        return EmptyDisposable
    }
}

internal func complete<T, E>(_ valueType: T.Type, _ error: E.Type) -> Signal<T, E> {
    return Signal<T, E> { subscriber in
        subscriber.putCompletion()
        
        return EmptyDisposable
    }
}

internal func never<T, E>(_ valueType: T.Type, _ error: E.Type) -> Signal<T, E> {
    return Signal { _ in
        return EmptyDisposable
    }
}
