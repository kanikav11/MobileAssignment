//
//  ContentViewModel.swift
//  Assignment
//
//  Created by Kunal on 10/01/25.
//

import Foundation

class ContentViewModel : ObservableObject {
    
    private let apiService = ApiService()
    @Published var navigateDetail: DeviceData? = nil
    var data: [DeviceData]? = []

    func fetchAPI(completion : @escaping (Bool) -> ()) {
        DataService.sharedInstance.fetchDeviceDetails { data in
            self.data = data
            completion(true)
        }
    }
    
    func navigateToDetail(navigateDetail: DeviceData) {
        self.navigateDetail = navigateDetail
    }
}
