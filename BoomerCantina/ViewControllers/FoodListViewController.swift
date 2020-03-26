//
//  FoodListViewController.swift
//  BoomerCantina
//
//  Created by Nicolas Bellon on 20/03/2020.
//  Copyright © 2020 Nicolas Bellon. All rights reserved.
//

import Foundation
import UIKit

// MARK: - FoodListViewController

/// Display a FoodList from FireBase and allow the user to
/// select some food to order
/// Also let the user to display Cart and reset the DB
class FoodListViewController: UIViewController {
    
    // MARK: Private properties
    
    // MARK: UIView
    
    /// Vertical CollectionView display `Food` list
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let dest = UICollectionView(frame: .zero, collectionViewLayout: layout)
        dest.translatesAutoresizingMaskIntoConstraints = false
        return dest
    }()
    
    /// Spiner displayed during `Food` list is loading
    private let spiner: UIActivityIndicatorView = {
        let dest = UIActivityIndicatorView(style: .large)
        dest.translatesAutoresizingMaskIntoConstraints = false
        return dest
    }()
    
    // MARK: Model
    
    /// Food Array model
    private var foods = [Food]()
    
    // MARK: DataProvider handle
    
    /// Store AddFoodObserver handle
    private var handleAddFood: UInt = 0
    
    /// Store RemoveFoodObserver handle
    private var handleRemoveFood: UInt = 0
    
    /// Store AddCartObserver handle
    private var handleAddCart: UInt = 0
    
    /// Store RemoveFromCartObserver handle
    private var handleRemoveFromCart: UInt = 0
    
    // MARK: Public methods
    
    // MARK: User action
    
    /// Show cart user action
    @objc private func showCart() {
        let cart = CartViewController()
        self.navigationController?.pushViewController(cart, animated: true)
    }
    
    /// Reset DB user action
    @objc private func reset() {
        self.updateCartButton(cartFoodCount: 0)
        CantinaDataProvider.shared.setupDB()
    }
    
    // MARK: Private methods
    
    // MARK: Setup methods
    
    /// Setup Reset NavBar button
    private func setupNavBar() {
        let resetButton = UIBarButtonItem(title: "Reset", style: UIBarButtonItem.Style.plain, target: self, action: #selector(reset))
        self.navigationItem.leftBarButtonItem = resetButton
    }
    
    /// Update CartButton display elements count present in the cart
    /// and hide the button if there is no food in the cart
    /// - Parameter cartFoodCount: food present in the cart
    private func updateCartButton(cartFoodCount: Int) {
        if cartFoodCount == 0 {
            self.navigationItem.setRightBarButton(nil, animated: true)
        } else {
            let dest = UIBarButtonItem(title: "Cart (\(cartFoodCount))", style: UIBarButtonItem.Style.plain, target: self, action: #selector(showCart))
            self.navigationItem.setRightBarButton(dest, animated: self.navigationItem.rightBarButtonItem == nil)
        }
    }
    
    /// Setup view hierarchy, and set the viewController title
    private func setupView() {
        self.view.backgroundColor = .red
        self.title = "BOOMER CANTINA"
        self.collectionView.backgroundColor = .blue
        
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.spiner)
    }
    
    /// Setup view layout
    private func setupLayout() {
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(self.collectionView.topAnchor.constraint(equalTo:
            self.view.safeAreaLayoutGuide.topAnchor, constant: 10))
        
        constraints.append(self.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor))
        
        constraints.append(self.collectionView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor))
        
        constraints.append(self.collectionView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor))
        
        constraints.append(self.spiner.centerYAnchor.constraint(equalTo: self.collectionView.centerYAnchor))
        constraints.append(self.spiner.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Setup CollectionView, register cell, and set dataSource and delegate
    private func setupCollectionView() {
        self.collectionView.register(FoodCell.self, forCellWithReuseIdentifier: FoodCell.identifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    /// Setup navBar, view hierarchy, layout,
    /// spiner, collectionView, and dataProvider
    private func setup() {
        self.setupNavBar()
        self.setupView()
        self.setupLayout()
        self.setupSpiner()
        self.setupCollectionView()
        self.setupDataProvider()
    }
    
    /// Setup the inital state of the spiner, before the loading process
    private func setupSpiner() {
        self.spiner.isHidden = false
        self.spiner.startAnimating()
    }
    
    /// Subscribe to add, and delete Food Event from `CantinaDataProvider`
    /// Subscribe also to add and remove from cart event
    private func setupDataProvider() {
        self.handleRemoveFood = CantinaDataProvider.shared.registerDeleteFoodsObserver { [weak self] food in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                guard let index = self.foods.firstIndex(of: food) else { return }
                self.foods.remove(at: index)
                self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                if self.foods.count == 0 {
                    self.spiner.isHidden = false
                    self.spiner.startAnimating()
                }
            }
        }
        
        self.handleAddFood = CantinaDataProvider.shared.registerAddFoodsObserver { [weak self] food in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                guard self.foods.contains(food) == false else { return }
                self.foods.append(food)
                self.spiner.isHidden = true
                self.spiner.stopAnimating()
                self.collectionView.insertItems(at: [IndexPath(item: self.foods.count - 1, section: 0)])
            }
        }
        
        self.handleAddCart = CantinaDataProvider.shared.registerAddToCartObserver(completion: { _ in
            CantinaDataProvider.shared.getCart { [weak self] cart in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.updateCartButton(cartFoodCount: cart.count)
                }
            }
        })
        
        self.handleRemoveFromCart = CantinaDataProvider.shared.registerDeleteToCartObserver(completion: { _ in
            CantinaDataProvider.shared.getCart { [weak self] cart in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.updateCartButton(cartFoodCount: cart.count)
                }
            }
        })
    }
    
    // MARK: UIViewController override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    // MARK: Deinit
    
    deinit {
        // Remove `DataProvider` observation subscription
        CantinaDataProvider.shared.unsubscribeAddDeleteFoodsObserver(handle: self.handleAddFood)
        CantinaDataProvider.shared.unsubscribeAddDeleteFoodsObserver(handle: self.handleRemoveFood)

        CantinaDataProvider.shared.unsubscribeAddRemoveCartObserver(handle: self.handleAddCart)
        CantinaDataProvider.shared.unsubscribeAddRemoveCartObserver(handle: self.handleRemoveFromCart)
    }
}

// MARK: - UICollectionViewDelegate

extension FoodListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < self.foods.count, indexPath.item >= 0 else { return }
        let food = self.foods[indexPath.item]

        CantinaDataProvider.shared.getCart { cart in
            if cart.contains(food) == true {
                CantinaDataProvider.shared.removeFromCart(food: food)
            } else {
                CantinaDataProvider.shared.addToCart(food: food)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FoodListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: 80)
    }
}

// MARK: - UICollectionViewDataSource

extension FoodListViewController: UICollectionViewDataSource {
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
