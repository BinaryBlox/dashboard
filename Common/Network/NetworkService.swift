//
//  NetworkService.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import Foundation
import FavIcon
import PinkyPromise

public enum NetworkError: Error {
    case InvalidUrl
    case NoResponse
}

public class NetworkService {
    
    private static let baseUrl: String = "http://patrickgatewood.com:9000/dashboard"
    
    public static func sendDeviceTokenToServer(_ deviceToken: Data) -> Promise<Int> {
        print("sending token to server")
        let url = URL(string: "\(baseUrl)/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    
        let user = UserModel(pushToken: deviceToken)
        
        return Promise { fulfill in
            do {
                let userJson = try JSONEncoder().encode(user)
                request.httpBody = userJson
                
                let task = URLSession.shared.dataTask(with: request) { (_ data, response, error) in
                    if let error = error {
                        fulfill(.failure(error))
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse else {
                        fulfill(.failure(NetworkError.NoResponse))
                        return
                    }
                    
                    print("success sending token")
                    fulfill(.success(response.statusCode))
                }
                
                task.resume()
            
            } catch {
                fulfill(.failure(NetworkError.InvalidUrl))
                // TODO throw json encode error
            }
        }
    }
    
    public static func fetchServerStatus(url: String) -> Promise<Int> {
        guard let url = URL(string: url) else {
            return Promise(error: NetworkError.InvalidUrl)
        }
     
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        return Promise { fulfill in
            let task = URLSession.shared.dataTask(with: request) { (_ data, response, error) in
                if let error = error {
                    fulfill(.failure(error))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    fulfill(.failure(NetworkError.NoResponse))
                    return
                }
                
                fulfill(.success(response.statusCode))
            }
            
            task.resume()
        }
    }
    
    public static func fetchFavicon(for url: String) -> Promise<UIImage> {
        return Promise { fulfill in
            do {
                try FavIcon.downloadPreferred(url, width: 500, height: 500) { result in
                    if case let .success(image) = result {
                        fulfill(.success(image))
                        return
                    } else if case let .failure(error) = result {
                        fulfill(.failure(error))
                    }
                }
            } catch let error {
                fulfill(.failure(error))
            }
        }
    }
}
