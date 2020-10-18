import UIKit
import RxSwift
import RxCocoa

var str = "Hello, playground"

let one = 1
let two = 2
let three = 3

let observable1 = Observable<Any>.never()
let observable2 = Observable.of([one, two, three])
observable1.subscribe(
    onNext: { element in
        print(element)
    },
    onCompleted: {
        print("Completed")
    }
)

let observable3 = Observable<String>.create { observer in
    observer.onNext("a")
    observer.onNext("b")
    observer.onCompleted()
    return Disposables.create()
}.do(
    onNext: { print($0) },
    onError: { print($0) },
    onCompleted: { print("Completed") },
    onSubscribed: { print("Subscribed") }
).debug("obs3", trimOutput: true)

observable3.subscribe(
    onNext: { print("sub: " + $0) }
)

// Published subject

let subject = PublishSubject<String>()
subject.onNext("r u listening?")

let subscription = subject.subscribe({ print("sub: ", $0.element ?? $0) })

subject.onNext("3")
