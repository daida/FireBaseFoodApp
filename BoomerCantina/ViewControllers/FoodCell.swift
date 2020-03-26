//
//  FoodCell.swift
//  BoomerCantina
//
//  Created by Nicolas Bellon on 20/03/2020.
//  Copyright © 2020 Nicolas Bellon. All rights reserved.
//

import Foundation
import UIKit

// MARK: - FoodCell

/// `UICollectionViewCell`, display name,
/// price and image of the food
/// react if any `Food` property is updated
class FoodCell: UICollectionViewCell {
    
    // MARK: Private properties
    
    // MARK: UIView
    
    /// Display Product name
    private let nameLabel: UILabel = {
        let dest = UILabel()
        dest.translatesAutoresizingMaskIntoConstraints = false
        return dest
    }()
    
    /// Display the price
    private let priceLabel: UILabel = {
        let dest = UILabel()
        dest.translatesAutoresizingMaskIntoConstraints = false
        return dest
    }()
    
    /// Display product image
    private let imageView: UIImageView = {
        let dest = UIImageView()
        dest.contentMode = .scaleAspectFill
        dest.clipsToBounds = true
        dest.translatesAutoresizingMaskIntoConstraints = false
        return dest
    }()
    
    /// CheckMark image, indicate if the product is in the Cart.
    private let checkMark: UIImageView = {
        let dest = UIImageView()
        dest.contentMode = .scaleToFill
        dest.clipsToBounds = true
        dest.image = UIImage(named: "check")
        dest.isHidden = true
        dest.translatesAutoresizingMaskIntoConstraints = false
        return dest
    }()
    
    /// Spinner, displayed during the image downloading
    private  let spiner: UIActivityIndicatorView = {
        let dest = UIActivityIndicatorView(style: .medium)
        dest.translatesAutoresizingMaskIntoConstraints =  false
        return dest
    }()
    
    // MARK: Model
    
    /// Model
    private var food: Food?
    
    // MARK: Observation handle
    
    /// Update Food observation handle, usefull to unsubscribe observer in the `prepareForReueuse` method
    private var handleUpdateFood: UInt = 0
    
    /// Add Cart observation handle, usefull to unsubscribe observer in the `prepareForReueuse` method
    private var handleAddCart: UInt = 0
    
    /// Delete Cart observation handle, usefull to unsubscribe observer in the `prepareForReueuse` method
    private var handleDeleteCart: UInt = 0
    
    // MARK: Public static property
    
    // MARK: Reuse Identifier
    
    /// Reuse Identifier, return the class name as a `String`-> "FoodCell"
    static let identifier = String(describing: FoodCell.self)
    
    // MARK: Public methods
    
    // MARK: Configure
    
    /// Configure the Cell with a `Food` model,
    /// should be use in the `CellForItem` method of `UICollectionViewDataSource` implentation.
    /// - Parameter food: `Food` object to configure.
    func configure(food: Food) {
        self.food = food
        
        self.handleUpdateFood = CantinaDataProvider.shared.observe(food: food) { [weak self] food in
            guard let `self` = self else { return }
            guard food == self.food else { return }
            
            DispatchQueue.main.async {
                self.updateCell(food: food)
            }
        }
        
        self.handleAddCart = CantinaDataProvider.shared.registerAddToCartObserver { [weak self] food in
            guard let `self` = self else { return }
            if food == self.food {
                DispatchQueue.main.async {
                    self.checkMark.isHidden = false
                }
            }
        }
        
        self.handleDeleteCart = CantinaDataProvider.shared.registerDeleteToCartObserver { [weak self] food in
            guard let `self` = self else { return }
            if food == self.food {
                DispatchQueue.main.async {
                    self.checkMark.isHidden = true
                }
            }
        }
    }
    
    // MARK: Private methods
    
    /// When a Food property is updated, the coresponding
    /// UILabel background will blink in orange for 2 secounds
    /// - Parameter food: food to process
    func blinkBackgroundIfNeeded(food: Food) {

        let foodSave = self.food
        
        if self.priceLabel.text != nil, self.priceLabel.text != food.price {
            self.priceLabel.backgroundColor = UIColor.orange
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { [weak self] in
                guard let `self` = self else { return }
                guard foodSave == self.food else { return }
                self.priceLabel.backgroundColor = UIColor.clear
            }
        }
        
        if self.nameLabel.text != nil, self.nameLabel.text != food.name {
            self.nameLabel.backgroundColor = UIColor.orange
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { [weak self] in
                guard let `self` = self else { return }
                guard foodSave == self.food else { return }
                self.nameLabel.backgroundColor = UIColor.clear
            }
        }
    }
    
    /// Call everytime a Food property is updatated, and the first time.
    /// This method will setup:
    /// - nameLabel text
    /// - priceLabel text
    /// - imageView image
    /// - Parameter food: food to update
    private func updateCell(food: Food) {
        
        self.spiner.isHidden = false
        self.spiner.startAnimating()
        ImageDownloadManager.shared.imageWith(food.pictureURL) { [weak self] image in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if food == self.food {
                    self.spiner.isHidden = true
                    self.spiner.stopAnimating()
                    self.imageView.image = image
                }
            }
        }
        
        self.blinkBackgroundIfNeeded(food: food)
        self.priceLabel.text = food.price
        self.nameLabel.text = food.name
        self.food = food
    }
    
    // MARK: Setup methods
    
    /// Setup the view hierarchy
    private func setupView() {
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.priceLabel)
        self.contentView.addSubview(self.checkMark)
        self.contentView.addSubview(self.spiner)
    }
    
    /// Setup the view layout
    private func setupLayout() {
        var constrains = [NSLayoutConstraint]()
        
        constrains.append(self.imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor))
        constrains.append(self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor))
        constrains.append(self.imageView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.3))
        constrains.append(self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor))
        
        
        constrains.append(self.nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10))
        constrains.append(self.nameLabel.leftAnchor.constraint(equalTo: self.imageView.rightAnchor, constant: 10))
        
        constrains.append(self.priceLabel.leftAnchor.constraint(equalTo: self.imageView.rightAnchor, constant: 10))
        
        constrains.append(self.priceLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 10))
        
        constrains.append(self.checkMark.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor))
        
        constrains.append(self.checkMark.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -10))
        
        constrains.append(self.spiner.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor))
        constrains.append(self.spiner.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor))
        
        constrains.append(self.checkMark.widthAnchor.constraint(equalToConstant: 30))
        constrains.append(self.checkMark.heightAnchor.constraint(equalToConstant: 30))
        
        NSLayoutConstraint.activate(constrains)
    }
    
    /// Setup view hierarchy and layout
    private func setup() {
        self.setupView()
        self.setupLayout()
    }
    
    // MARK: UICollectionView override
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let food = self.food {
            CantinaDataProvider.shared.removeObserver(handleID: self.handleUpdateFood, for: food)
        }
        
        CantinaDataProvider.shared.unsubscribeAddRemoveCartObserver(handle: self.handleAddCart)
        CantinaDataProvider.shared.unsubscribeAddRemoveCartObserver(handle: self.handleDeleteCart)
        
        self.imageView.image = nil
        self.nameLabel.text = nil
        self.priceLabel.text = nil
        self.checkMark.isHidden = true
        self.food = nil
        self.handleUpdateFood = 0
        self.handleDeleteCart = 0
        self.handleAddCart = 0
        self.spiner.isHidden = true
        self.spiner.stopAnimating()
        self.nameLabel.backgroundColor = UIColor.clear
        self.priceLabel.backgroundColor = UIColor.clear
    }
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
