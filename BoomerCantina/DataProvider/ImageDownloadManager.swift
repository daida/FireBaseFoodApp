//
//  ImageDownloadManager.swift
//  BoomerStore / BoomerCantina
//
//  Created by Nicolas Bellon on 31/01/2020.
//  Copyright © 2020 Nicolas Bellon. All rights reserved.
//

import Foundation
import UIKit

// MARK: - ImageDownloadManager

/// This controller download image from
/// internet and handle a "hot cache" in RAM memory
/// and also persist image on the FileSystem
struct ImageDownloadManager {
    
    // MARK: Private propeties
    
    /// NSCache object, store a ring buffer of 20 images
    /// the key is the URL requested absoluteString
    private let cacheManager: NSCache<NSString, UIImage> = {
        let dest = NSCache<NSString, UIImage>()
        dest.countLimit = 20
        return dest
    }()
    
    /// URLSession object used to download images
    private let session = URLSession(configuration: .default)
    
    /// Path to the directory where images will be stored
    private let path: URL = {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { fatalError("Error create imageDownloadManager path") }
        let dest = URL(fileURLWithPath: path).appendingPathComponent("imageDownloadManager")
        return dest
    }()
    
    // MARK: Public properties
    
    static let shared = ImageDownloadManager()
    
    // MARK: Public methods
    
    /// Clear all images in RAM and on the file system
    func clearCache() {
        self.cacheManager.removeAllObjects()
        do {
            try FileManager.default.removeItem(at: self.path)
        } catch {
            print("Error clear FileSystem")
        }
    }
    
    /// Download image from the internet
    /// Before trying to download the image,
    /// The RAM cache and the filesystem will be used in order to retrive the image.
    /// - Parameters:
    ///   - url: URL of the image requested
    ///   - completion: Completion closure, with an optional `UIImage`.
    func imageWith(_ url: URL,  completion: @escaping ((UIImage?) -> Void)) {
        
        if FileManager.default.fileExists(atPath: self.path.path) == false {
            do {
                try FileManager.default.createDirectory(at: self.path, withIntermediateDirectories: true)
            } catch {
                print("Error can't create image directory -> \(error.localizedDescription)")
            }
        }
        
        if let cachedImage = self.cacheManager.object(forKey: NSString(string: url.absoluteString)) {
            completion(cachedImage)
            return
        }
        
        let sha1 = sha256(str: url.absoluteString)
        
        if let imageFS = UIImage(contentsOfFile: self.path.appendingPathComponent(sha1).path) {
            self.cacheManager.setObject(imageFS, forKey: NSString(string: url.absoluteString))
            completion(imageFS)
            return
        }
        
        self.session.dataTask(with: url) { data, _, error in
            guard
                let data = data,
                let image = UIImage(data: data) else {
                completion(nil)
                return
            }
     
            do {
                try data.write(to: self.path.appendingPathComponent(sha1))
            } catch {
                print("Error save image from \(url) on filesystem: \(self.path.appendingPathComponent(sha1))")
            }
            
            self.cacheManager.setObject(image, forKey: NSString(string: url.absoluteString))
            
            completion(UIImage(data: data))
            
            return
        }.resume()
    }
}
