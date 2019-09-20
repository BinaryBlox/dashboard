//
//  HomeView.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var network: NetworkService
    @EnvironmentObject var database: PersistenceClient
    
    @FetchRequest(fetchRequest: PersistenceClient.allServicesFetchRequest()) var services: FetchedResults<ServiceModel>
    
    // State variables are owned & managed by this view so they should be private 
    @State private var showingAddServices = false
    @State private var serviceToEdit: ServiceModel?
        
    var addServiceButton: some View {
        Button(action: { self.showingAddServices.toggle() }) {
            Image(systemName: "plus.circle")
                .scaledToFit()
                .accessibility(label: Text("Add Service"))
                .imageScale(.large)
                .frame(width: 25, height: 25)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(services, id: \.url) { service in
                    ServiceRow(name: service.name, url: service.url, image: service.image, statusImage: service.statusImage, isLoading: service.isLoading)
                        .onAppear { // TODO this doesn't appear to be called when a new row is added 🤔
                            self.network.updateServerStatus(for: service)
                    }
                    .onTapGesture {
                        self.network.updateServerStatus(for: service)
                    }
                    .contextMenu {
                        Button(action: {
                            self.serviceToEdit = service
                            self.showingAddServices.toggle() })
                        {
                            Text("Edit Service")
                        }
                    }
                }
                .onMove(perform: moveService)
                .onDelete(perform: deleteService)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("My Services", displayMode: .large)
            .navigationBarItems(leading: EditButton(),
                                trailing: addServiceButton)
            .sheet(isPresented: $showingAddServices) {
                AddServiceHostView(serviceToEdit: self.serviceToEdit)
                    .onDisappear() {
                        self.serviceToEdit = nil
                    }
            }
        }
    }
    
    private func moveService(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else {
            return // show error?
        }
        
        // Destination is an offset rather than an index, so massage it into an index
        let destinationIndex = sourceIndex > destination ? destination : destination - 1
        
        database.swap(service: services[sourceIndex], with: services[destinationIndex])
    }
    
    private func deleteService(at offsets: IndexSet) {
        guard let deletionIndex = offsets.first else {
            return
        }
        
        let service = services[deletionIndex]
        database.delete(service)
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView() // Need to mock environmentObjects to see a good preview
    }
}
#endif
