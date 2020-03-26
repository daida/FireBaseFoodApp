//
//  DataProvider+SetupDB.swift
//  BoomerCantina
//
//  Created by Nicolas Bellon on 19/03/2020.
//  Copyright © 2020 Nicolas Bellon. All rights reserved.
//

import Foundation

extension CantinaDataProvider {
    
    /// Reset FireBase Cantina DataBase
    func setupDB() {
        CantinaDataProvider.shared.clearDataBase()
        
        let buritos = Food(name: "Burrito",
                           pictureURL: "https://assets.afcdn.com/recipe/20120924/25665_w800h600c1cx256cy192.jpg",
                           price: "7 euros")!
        
        CantinaDataProvider.shared.append(food: buritos, completionBlock: nil)
       
         let salade = Food(name: "Avocado toast", pictureURL: "https://www.fourchette-et-bikini.fr/sites/default/files/styles/full_320x256/public/shutterstock_1054928576.jpg?itok=u4-KojOU", price: "8 euros")!
        
        CantinaDataProvider.shared.append(food: salade, completionBlock: nil)
        
         let cheese = Food(name: "Cheeseburger", pictureURL: "https://img.cuisineaz.com/610x610/2013-12-20/i113795-cheeseburger.jpg", price: "12 euros")!
        
          CantinaDataProvider.shared.append(food: cheese, completionBlock: nil)
        
         let ravioli = Food(name: "Ravioli", pictureURL: "https://cache.marieclaire.fr/data/photo/w999_c17/cuisine/43/raviolis1.jpg", price: "15 euros")!
          
        CantinaDataProvider.shared.append(food: ravioli, completionBlock: nil)
        
         let pizza = Food(name: "Pizza", pictureURL: "https://www.simpleetbon.com/system/recipes/photos/000/000/347/original/pizza_poivron_oignon.jpg?1529502064", price: "15 euros")!
        
        CantinaDataProvider.shared.append(food: pizza, completionBlock: nil)
        
        let nuggets = Food(name: "Nuggets", pictureURL: "https://img-3.journaldesfemmes.fr/G72jWguIHwxAVdVh85kO_3bMCZQ=/748x499/smart/image-icu/1005262_1338991411.jpg", price: "6 euros")!
        
        CantinaDataProvider.shared.append(food: nuggets, completionBlock: nil)
        
          let nems = Food(name: "Nems", pictureURL: "https://cac.img.pmdstatic.net/fit/http.3A.2F.2Fprd2-bone-image.2Es3-website-eu-west-1.2Eamazonaws.2Ecom.2Fcac.2F2018.2F09.2F25.2F862aad50-97a5-473f-a8f9-13cd9e18da6b.2Ejpeg/410x230/quality/80/crop-from/center/nems.jpeg", price: "10 euros")!
        
         CantinaDataProvider.shared.append(food: nems, completionBlock: nil)
        
         let panini = Food(name: "Panini", pictureURL: "https://recettes.de/images/blogs/une-cuillere-en-bois/pain-panini-rapide-et-facile-336.640x480.jpg", price: "12 euros")!
        
         CantinaDataProvider.shared.append(food: panini, completionBlock: nil)
        
          let kebab = Food(name: "Kebab", pictureURL: "https://www.ledahu.net/dahu/wp-content/uploads/cache/images/A-3/A-3-202976579.jpg", price: "10 euros")!
        
         CantinaDataProvider.shared.append(food: kebab, completionBlock: nil)
        
         let toritilla = Food(name: "toritilla de patates", pictureURL: "https://www.recetasderechupete.com/wp-content/uploads/2016/08/Tortilla-de-patatas.jpg", price: "8 euros")!
        
        CantinaDataProvider.shared.append(food: toritilla, completionBlock: nil)
        
           let bagel = Food(name: "bagel saumon fumé", pictureURL: "https://cache.marieclaire.fr/data/photo/w1000_c17/cuisine/4o/bagel-au-saumon-de-norvege-123.jpg", price: "8 euros")!
        
        CantinaDataProvider.shared.append(food: bagel, completionBlock: nil)


        let cheesecake = Food(name: "Cheesecake au citron", pictureURL: "https://www.academiedugout.fr/images/12077/948-580/fotolia_51734974_subscription_xxl.jpg?poix=50&poiy=50", price: "6 euros")!
        
         CantinaDataProvider.shared.append(food: cheesecake, completionBlock: nil)
        
         let cookie = Food(name: "Cookie", pictureURL: "https://fr.rc-cdn.community.thermomix.com/recipeimage/dkf9c40p-9850e-860759-cfcd2-v49usz4k/44ca7131-0492-4ed2-a053-31332710649c/main/cookies-aux-pepites-de-chocolat.jpg", price: "3 euros")!
        
        CantinaDataProvider.shared.append(food: cookie, completionBlock: nil)
        
        let cafe = Food(name: "Café", pictureURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/A_small_cup_of_coffee.JPG/280px-A_small_cup_of_coffee.JPG", price: "2 euros")!
        
        CantinaDataProvider.shared.append(food: cafe, completionBlock: nil)

        
        let croque = Food(name: "Croque-monnsieur", pictureURL: "https://fac.img.pmdstatic.net/fit/http.3A.2F.2Fprd2-bone-image.2Es3-website-eu-west-1.2Eamazonaws.2Ecom.2Ffac.2F2018.2F07.2F30.2Ffd17f7f1-1ce8-4916-8edc-dcc78a89a9a3.2Ejpeg/748x372/quality/80/crop-from/center/croque-monsieur.jpeg", price: "13 euros")!
        
        CantinaDataProvider.shared.append(food: croque, completionBlock: nil)
    }
}
