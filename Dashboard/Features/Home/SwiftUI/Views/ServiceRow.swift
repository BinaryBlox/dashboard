//
//  ServiceItem.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct ServiceRow: View {
    var name: String
    var url: String
    var image: UIImage
    var statusImage: UIImage
    var isLoading: Bool // This seems like it could be eitehr state or binding... 
    
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .padding(10)
                .frame(width: 80, height: 50)
            
            Spacer()
            
            Text(name)
            
            Spacer()
            
            if isLoading {
                // TODO port UIActivityIndicator to SwiftUI
                Text("loading...")
            } else {
                Image(uiImage: statusImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 50)
            }
        }
        .frame(height: 80)
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

#if DEBUG
struct ServiceItem_Previews: PreviewProvider {
    static var previews: some View {
        return ServiceRow(name: "Test Service", url: "test.com", image: UIImage(named: "missing-image")!, statusImage: UIImage(named: "check")!, isLoading: false)
    }
}
#endif
