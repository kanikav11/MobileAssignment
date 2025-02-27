//
//  ContentView.swift
//  Assignment
//
//  Created by Kunal on 03/01/25.
//


import UIKit

class ContentViewController: UIViewController {
    
    private let viewModel = ContentViewModel()
    private var devices: [DeviceData] = []
    private var filteredDevices: [DeviceData] = []
    private var tableView: UITableView!
    private var activityIndicator: UIActivityIndicatorView!
    private var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search Devices"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DeviceCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        fetchData()
        
        navigationItem.title = "Computers"
        view.backgroundColor = .white
    }
    
    func fetchData() {
        self.viewModel.fetchAPI { bool in
            if bool == true{
                self.activityIndicator.startAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let data = self.viewModel.data {
                        self.devices = data
                        self.filteredDevices = data
                        self.tableView.reloadData()
                    }
                    self.activityIndicator.stopAnimating()
                    self.tableView.isHidden = false
                }
            }
        }
    }
    
    func updateSearchedTextData(_ query: String){
        if query == ""{
            self.filteredDevices = devices
        }else{
            self.filteredDevices = DataService.sharedInstance.searchResults(searchText: query)
        }
        self.tableView.reloadData()
    }
}

extension ContentViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.updateSearchedTextData(searchText)
    }
    
}

extension ContentViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        let device = filteredDevices[indexPath.row]
        cell.textLabel?.text = device.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDevice = filteredDevices[indexPath.row]
        _ = DetailViewController(device: selectedDevice)
    }
}
