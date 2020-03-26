//
//  Observable.swift
//  BoomerCantina
//
//  Created by Nicolas Bellon on 22/03/2020.
//  Copyright © 2020 Nicolas Bellon. All rights reserved.
//

import Foundation

 class Observable<ObservedType> {

    typealias Observer = (Observable<ObservedType>, ObservedType) -> Void

    private var observers: [Observer]

    var value: ObservedType {
        didSet {
            notifyObservers(value)
        }
    }

    init(_ value: ObservedType) {
        self.value = value
        observers = []
    }

    func bind(observer: @escaping Observer) {
        self.observers.append(observer)
    }

    func notifyObservers(_ value: ObservedType) {
        
        self.observers.forEach { [weak self] observer in
            guard let self = `self` else { return }
            observer(self, value)
        }
    }

    func clearAllObserver() {
        self.observers.removeAll()
    }
}
