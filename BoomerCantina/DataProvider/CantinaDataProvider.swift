//
//  CantinaDataProvider.swift
//  BoomerCantina
//
//  Created by Nicolas Bellon on 18/03/2020.
//  Copyright © 2020 Nicolas Bellon. All rights reserved.
//

import Foundation
import Firebase

// MARK: - CantinaDataProvider

/// Power by FireBase RealTime Database, retrive `Food` objects and provide
/// add and delete methods
/// add / delete and edit observation methods.
/// Provide also add / remove to cart methods with
/// coresponding observation methods.
/// All Modifications are sync with FireBase.
class CantinaDataProvider {
    
    // MARK: Private properties
    
    // MARK: FireBase Ref
    
    /// FireBase reference to Foods dictonary
    private let foodsRef = Database.database().reference().child("Foods")

    /// FireBase reference to Cart dictonary
    private let cartRef = Database.database().reference().child("Cart")
    
    // MARK: Static public properties
    
    // MARK: Singleton
    
    /// Singleton variable
    static let shared = CantinaDataProvider()
    
    // MARK: Private Init method
    
    /// Private init
    private init() {
        self.foodsRef.observe(DataEventType.childRemoved) { [weak self] snap in
            guard let self = self else { return }
            self.cartRef.child(snap.key).removeValue()
        }
    }
    
    // MARK: Public methods
    
    // MARK: Foods
    
    /// Retrive `Food` objects from FireBase ordered by creation date, the latest at the end.
    /// - Parameter completion: completion closure with `Food` array as parameter
    func getFoods(completion: @escaping (([Food]) -> Void)) {
        self.foodsRef.queryOrdered(byChild: "date").observeSingleEvent(of: DataEventType.value) { snap in
            let dest: [Food] = snap.children
                .allObjects
                .compactMap { $0 as? DataSnapshot }
                .compactMap { Food(data: $0) }
            completion(dest)
        }
    }
    
    /// Append a `Food` object to FireBase
    /// - Parameters:
    ///   - food: `Food` object to append
    ///   - completionBlock: completion block exectuted after the food is append
    /// if an error hapen, it will be passed to the closure
    func append(food: Food, completionBlock:((Error?) -> Void)? = nil) {
        self.foodsRef.child(food.id).setValue(food.valueDico) { error, _ in
            completionBlock?(error)
        }
    }
    
    /// Delete a `Food` object to FireBase
    /// - Parameters:
    ///   - food: `Food` object to append
    ///   - completionBlock: completion block exectuted after the food is deleted
    /// if an error hapen, it will be passed to the closure
    func delete(food: Food, completionBlock:((Error?) -> Void)?) {
        
        self.cartRef.child(food.id).observeSingleEvent(of: .value) { snap in
            if snap.exists() == true {
                self.cartRef.child(food.id).removeValue { _, _ in
                    self.foodsRef.child(food.id).removeValue { error, _ in
                        completionBlock?(error)
                    }
                }
            } else {
                self.foodsRef.child(food.id).removeValue { error, _ in
                    completionBlock?(error)
                }
            }
        }
    }
    
    /// Register Add Food Observation, everytime a `Food` object is added,
    /// the closure paremter will be called, and the `Food` object will
    /// be passed as parameter.
    /// the observable handle will be return, keep it, in order to unsubscribe the observation later.
    /// - Parameter completion: closure, will be called everytime a `Food` object is added
    func registerAddFoodsObserver(completion: @escaping ((Food) -> Void)) -> UInt {
        return self.foodsRef.queryOrdered(byChild: "date").observe(DataEventType.childAdded) { snap in
            if let dest = Food(data: snap) {
                completion(dest)
            }
        }
    }
    
    /// Register Delete Food Observation, everytime a `Food` object is deletedx,
    /// the closure paremter will be called, and the `Food` object will
    /// be passed as parameter.
    /// the observable handle will be return, keep it, in order to unsubscribe the observation later.
    /// - Parameter completion: closure, will be called everytime a `Food` object is deleted
    func registerDeleteFoodsObserver(completion: @escaping ((Food) -> Void)) -> UInt {
       return self.foodsRef.queryOrdered(byChild: "date").observe(DataEventType.childRemoved) { snap in
            if let snapValue = Food(data: snap) {
                completion(snapValue)
            } else {
                fatalError("Register delete food fatal error!! cast error")
            }
        }
    }
    
    /// Unsubscribe observation for Add or Delete `Food`
    /// - Parameter handle: handle return by `registerDeleteFoodsObserver` or `registerAddFoodsObserver`
    /// If you have register for Add and delete you should call this method
    /// twice with the according handle
    func unsubscribeAddDeleteFoodsObserver(handle: UInt) {
        self.foodsRef.removeObserver(withHandle: handle)
    }
    
    // MARK: Food
    
    /// Register observation for a specific food
    /// This closure will be called everytime a `Food` property are updated
    /// the observable handle will be return, keep it,
    /// in order to unsubscribe the observation later.
    ///
    /// - Parameters:
    ///   - food: the food to observe
    ///   - completion: the closure will be called everytime a property is updated
    func observe(food: Food, completion: @escaping (Food) -> Void) -> UInt {
        return self.foodsRef.child(food.id).observe(DataEventType.value) { snap in
            if let dest = Food(data: snap) {
                completion(dest)
            }
        }
    }
    
    /// Remove observation for a specific `Food` object, and a handleID
    /// - Parameters:
    ///   - handleID: handle returned by the `observe:food:completion` method
    ///   - food: food to unsubscribe observation
    func removeObserver(handleID: UInt, for food: Food) {
        self.foodsRef.child(food.id).removeObserver(withHandle: handleID)
    }
    
    // MARK: Cart
    
    /// Retrive `Food` objects from FireBase which are contain in the Cart
    /// - Parameter completion: completion closure with `Food` array as parameter
    func getCart(completion: @escaping ([Food]) -> Void) {
         self.cartRef.observeSingleEvent(of: .value) { [weak self] snap in
             guard let `self` = self else { return }
             let keys = snap.children.allObjects.compactMap { $0 as? DataSnapshot  }.compactMap { $0.key }
             self.getFoods { foods in
                 completion((foods.filter { keys.contains($0.id) }))
             }
         }
     }

    /// Add a `Food` object to the cart, the cart is sync to FireBase
    /// - Parameter food: food to add to the cart
    func addToCart(food: Food, completion: ((Error?) -> Void)? = nil) {
        self.cartRef.child(food.id).setValue("1") { error, _ in
            completion?(error)
        }
    }

    /// Remove a `Food` object from the cart, the cart is sync to FireBase
    /// The `Food` is remove from car but not from the `Food` list
    /// - Parameter food: food to add to the cart
    ///   - completionBlock: completion block exectuted after the food is removed from the cart
      /// if an error hapen, it will be passed to the closure
    func removeFromCart(food: Food, completion: ((Error?) -> Void)? = nil) {
        self.cartRef.child(food.id).removeValue() { error, _  in
            completion?(error)
        }
    }

    /// Register Add Food to Cart Observation, everytime a `Food` object is added to the Cart,
    /// the closure paremter will be called, and the `Food` object will
    /// be passed as parameter.
    /// the observable handle will be return, keep it, in order to unsubscribe the observation later.
    /// - Parameter completion: closure, will be called everytime a `Food` object is added to the Cart
    func registerAddToCartObserver(completion: @escaping (Food) -> Void) -> UInt {
        
        return self.cartRef.observe(DataEventType.childAdded) { [weak self] snap in
            guard let `self` = self else { return }
            self.foodsRef.child(snap.key).observeSingleEvent(of: DataEventType.value) { snap in
                guard let dest = Food(data: snap) else { return }
                completion(dest)
            }
        }
    }

    /// Register Delete Food to Cart Observation, everytime a `Food` object is deleted from the Cart,
    /// the closure paremter will be called, and the `Food` object will
    /// be passed as parameter.
    /// the observable handle will be return, keep it, in order to unsubscribe the observation later.
    /// - Parameter completion: closure, will be called everytime a `Food` object is deleted from the Cart
    func registerDeleteToCartObserver(completion: @escaping (Food) -> Void) -> UInt {
        return self.cartRef.observe(DataEventType.childRemoved) { [weak self] snap in
            guard let `self` = self else { return }
            self.foodsRef.child(snap.key).observeSingleEvent(of: DataEventType.value) { snap in
                guard let dest = Food(data: snap) else { return }
                completion(dest)
            }
        }
    }

    /// Unsubscribe observation for Add or Delete to Cart closure.
    /// - Parameter handle: handle return by `registerDeleteToCartObserver` or `registerAddFoodsObserver`
    /// If you have register for Add and delete you should call this method
    /// twice with the according handle
    func unsubscribeAddRemoveCartObserver(handle: UInt) {
        self.cartRef.removeObserver(withHandle: handle)
    }

    // MARK: Clear DataBase

    /// Remove All `Food` object from cart
     func clearCart() {
         self.cartRef.removeValue()
     }

    /// Remove All `Food` object from FireBase
    func clearFood() {
        self.foodsRef.removeValue()
    }
    
    /// Remove all `Food` from Cart and
    /// remove all `Food` from FireBase
    func clearDataBase() {
        self.clearCart()
        self.clearFood()
    }
} 
