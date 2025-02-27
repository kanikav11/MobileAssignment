//
//  Untitled.swift
//  Assignment
//
//  Created by Kanika Verma on 27/02/25.
//


import Foundation


class DataService{
    
    static let sharedInstance = DataService()
    private let cacheDirectoryURL: URL
    private let sourcesURL = URL(string: "https://api.restful-api.dev/objects")!
    
    private var data: [DeviceData]? = []
    
    init() {
        let fileManager = FileManager.default
        let cachedFolder = "OfflineSyncing"
        
        cacheDirectoryURL = fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathExtension(cachedFolder) ?? URL(fileURLWithPath: "")
        
        if fileManager.fileExists(atPath: cacheDirectoryURL.path) == false {
            try? fileManager.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true)
        }
    }
    
    private func cacheData(_ device: [DeviceData]){
        do{
            let data = try JSONEncoder().encode(device)
            let cacheURL = cacheDirectoryURL.appendingPathComponent("deviceData.json")
            try data.write(to: cacheURL)
        } catch {
            print("Error caching data")
        }
    }
    
    
    private func loadCachedData() -> [DeviceData]? {
        guard FileManager.default.fileExists(atPath: cacheDirectoryURL.appendingPathComponent("deviceData.json").path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: cacheDirectoryURL.appendingPathComponent("deviceData.json"))
            let device = try JSONDecoder().decode([DeviceData].self, from: data)
        } catch {
            print("Error loading data from cache")
        }
        return nil
    }
    
    func fetchDeviceDetails(completion : @escaping ([DeviceData]) -> ()){
        URLSession.shared.dataTask(with: sourcesURL) { (data, urlResponse, error) in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion([]) // Return an empty array on network failure
                return
            }
            
            if let cachedData = self.loadCachedData() {
                completion(cachedData)
                return
            }
            
            if let data = data {
                let jsonDecoder = JSONDecoder()
                let empData = try! jsonDecoder.decode([DeviceData].self, from: data)
                self.cacheData(empData)
                self.data = empData
                if (empData.isEmpty) {
                    completion([])
                    // Error
                }else{
                    completion(empData)
                }
            }
        }.resume()
    }
    
    func searchResults(searchText: String) -> [DeviceData]{
        guard let cachedData = data else {
            return []
        }
        
        return cachedData.filter { singleData in
            singleData.name.lowercased().contains(searchText.lowercased())
        }
    }
}
