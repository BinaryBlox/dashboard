//
//  ServiceModel.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import CoreData
import UIKit
import Combine

@objc(ServiceModel)
public class ServiceModel: NSManagedObject, Encodable {
    static var entityName: String {
        return String(describing: self)
    }
    
    @NSManaged var index: Int64
    @NSManaged var name: String
    @NSManaged var url: String
    @NSManaged var lastOnlineDate: Date
    
    /* TODO: This seems like a smell... the loading state should probably only be part of the view. But since
       in SwiftUI views are just functions of state, I'm unsure of where to put this
     */
    @NSManaged var isLoading: Bool
    
    /// Determine if the service was online in the last 5 minutes
    var wasOnlineRecently: Bool {
        return Date().timeIntervalSince(lastOnlineDate) <= 60 * 5
    }
    
    var statusImage: UIImage {
        return UIImage(named: wasOnlineRecently ? "check" : "server-error")!
    }

    var image: UIImage {
        get {
            return PersistenceClient.fetchImage(named: imageName) ?? UIImage(named: "missing-image")!
        }
    }
    
    var imageName: String {
        return "\(index)-\(name)" // arbitrary unique image name
    }
    
    func populate(index: Int64, name: String, url: String, lastOnlineDate: Date) {
        self.index = index
        self.name = name
        self.url = url
        self.lastOnlineDate = lastOnlineDate
        self.isLoading = false
    }
    
    // MARK: - Combine
    var didChange = PassthroughSubject<Void, Never>()
    
    public override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        didChange.send()
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case index
        case name
        case url
        case lastOnlineDate
    }
    
    // MARK - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(index, forKey: .index)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(lastOnlineDate, forKey: .lastOnlineDate)
    }
}

// Definitely a smell to duplicate the data here. However, turns out serializing Core Data models and decoding them on the watch is a bad idea too. TODO need to figure out best course action.
struct SimpleServiceModel: Decodable {
    var index: Int64
    var name: String
    var url: String
    var lastOnlineDate: Date
}
