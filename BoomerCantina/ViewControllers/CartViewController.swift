//
//  CartViewController.swift
//  BoomerCantina
//
//  Created by Nicolas Bellon on 21/03/2020.
//  Copyright © 2020 Nicolas Bellon. All rights reserved.
//

import Foundation
import UIKit

// MARK: - CartViewController

/// Display the Food user selection (cart)
/// If the user tap on food, they are removed from cart
/// The order buton action will remove all the food from the cart
/// and pop the viewController.
/// The list react to any external deletion from the cart.
class CartViewController: UIViewController {
    
    // MARK: Private properties
    
    // MARK: UIView
    
    /// Vertical CollectionView display all Food present in the user cart
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let dest = UICollectionView(frame: .zero, collectionViewLayout: layout)
        dest.translatesAutoresizingMaskIntoConstraints = false
        return dest
    }()
    
    /// Delete all Food From the cart and pop the ViewController
    private let orderButton: UIButton = {
        let dest = UIButton()
        dest.setTitle("ORDER", for: UIControl.State.normal)
        dest.backgroundColor = UIColor.green
        dest.translatesAutoresizingMaskIntoConstraints =  false
        return dest
    }()
    
    // MARK: Model
    
    /// Food Array model, user cart
    private var foods = [Food]()

    // MARK: Observable handle
    
    /// Store registerAddToCartObserver handle
    private var handleAddCart: UInt = 0
    
    /// Store registerDeleteToCartObserver handle
    private var handleDeleteFromCart: UInt = 0
    
    // MARK: Private methods
    
    // MARK: User Action
    
    /// Delete all Food From the cart and pop the ViewController
    @objc private func orderAction() {
        let alert = UIAlertController(title: nil, message: "ORDER OK", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { [weak self] _ in
            guard let `self` = self else { return }
            CantinaDataProvider.shared.clearCart()
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Setup methods
    
    /// Setup CollectionView, register cell, and set dataSource and delegate
    private func setupCollectionView() {
        self.collectionView.register(FoodCell.self, forCellWithReuseIdentifier: FoodCell.identifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    /// Setup view layout
    private func setupLayout() {
        var constraints = [NSLayoutConstraint]()
        constraints.append(self.collectionView.topAnchor.constraint(equalTo:
            self.view.safeAreaLayoutGuide.topAnchor, constant: 10))
        
        constraints.append(self.collectionView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor))
        constraints.append(self.collectionView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor))
        constraints.append(self.orderButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -15))
        
        constraints.append(self.orderButton.topAnchor.constraint(equalTo: self.collectionView.bottomAnchor, constant: 10))
        constraints.append(self.orderButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10))
        constraints.append(self.orderButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10))
        constraints.append(self.orderButton.heightAnchor.constraint(equalToConstant: 45))
        
        
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Setup view hierarchy, and set the viewController title
    private func setupView() {
        self.view.backgroundColor = UIColor.red
        self.collectionView.backgroundColor = UIColor.blue
        
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.orderButton)
    }
    
    /// Update ViewController title
    private func updateTitle() {
        self.title = "CART (\(self.foods.count))"
    }
    
    /// Perform back operation if needed
    private func backIfNeeded() {
        guard self.foods.count == 0 else { return }
        self.navigationController?.popViewController(animated: true)
    }
    
     /// Subscribe to add, and remove from Cart Event from `CantinaDataProvider`
    private func setupDataProvider() {
        
        self.handleAddCart = CantinaDataProvider.shared.registerAddToCartObserver { [weak self] food in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                guard self.foods.contains(food) == false else { return }
                self.foods.append(food)
                self.collectionView.insertItems(at: [IndexPath(item: self.foods.count - 1, section: 0)])
                self.updateTitle()
                self.backIfNeeded()
            }
        }
        
        self.handleDeleteFromCart = CantinaDataProvider.shared.registerDeleteToCartObserver { [weak self] food in
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                guard let index = self.foods.firstIndex(of: food) else { return }
                self.foods.remove(at: index)
                self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                self.updateTitle()
                self.backIfNeeded()
            }
        }
    }
    /// Setup buton action, view hierarchy, layout,
    /// collectionView, and dataProvider
    private func setup() {
        self.setupView()
        self.setupLayout()
        self.setupCollectionView()
        self.setupDataProvider()
        self.setupOrderButton()
    }
    
    /// Setup orederButton action
    private func setupOrderButton() {
        self.orderButton.addTarget(self, action: #selector(orderAction), for: .touchUpInside)
    }
    
    // MARK: UIViewController override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    deinit {
        CantinaDataProvider.shared.unsubscribeAddRemoveCartObserver(handle: self.handleDeleteFromCart)
        CantinaDataProvider.shared.unsubscribeAddRemoveCartObserver(handle: self.handleAddCart)
    }
}

// MARK: - UICollectionViewDelegate

extension CartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < self.foods.count, indexPath.item >= 0 else { return }
        let food = self.foods[indexPath.item]
        
        CantinaDataProvider.shared.getCart { cart in
            if cart.contains(food) == true {
                CantinaDataProvider.shared.removeFromCart(food: food)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CartViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: 80)
    }
}

// MARK: - UICollectionViewDataSource

extension CartViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: FoodCell.identifier, for: indexPath)
        guard let castedCell = cell as? FoodCell else { return cell }
        
        guard indexPath.item < self.foods.count, indexPath.item >= 0 else { return cell }
        
        castedCell.configure(food: self.foods[indexPath.item])
        
        return castedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.foods.count
    }
}
