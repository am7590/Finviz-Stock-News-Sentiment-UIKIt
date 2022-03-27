//
//  SearchTableViewController.swift
//  News-Sentiment-UIKit
//
//  Created by Alek Michelson on 3/20/22.
//

import UIKit
import Combine
import CoreData

class SearchStocksViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
        
    // Control which tableview is shown
    private enum Mode {
        case selected
        case search
    }
    
    @Published private var searchQueryTextOccupied = false
    @Published private var mode: Mode = .selected
    @Published private var searchQuery = String()
    private var searchResults: SearchResults?
    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    var loading = true
    var notSearchingQuery = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        observeForm()
        // setupTableView()
        fetchSecurities()
        
        
    }
    
    
    // MARK: Core data
    // Reference to Core Data managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Second table view
    @Published private var orignalSearchQuery = ["TSLA", "GME"]

    @Published private var listOfSecurities:[Stock]?
    
    
    func addDummyStockData() {
        // Add TSLA as starter data
        let stock = NSEntityDescription.insertNewObject(forEntityName: "Stock", into: context) as! Stock
        stock.name = "TSLA"
    }
    
    func fetchSecurities() {
        
        do {
            self.listOfSecurities = try context.fetch(Stock.fetchRequest())  // Get all items
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } catch {
            
        }
        
    }
    
    
    
    
    
    
    
    
    private func observeForm() {
            
            // Call the API every 750 milliseconds
            $searchQuery
                .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
                .sink { [unowned self] (searchQuery) in
                    
                    // Stops function from searching empty query (bug fix)
                    guard !searchQuery.isEmpty else {
                        notSearchingQuery = true
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        return
                        
                    }
                    searchQueryTextOccupied = false
                    
                    // Loading animation
                    // showLoadingAnimation()
                    
                    
                    self.apiService.fetchSymbolePublisher(ticker: searchQuery).sink { (completion) in
                        // If error
                        
                        // Hide animation upon callback
                        // hideLoadingAnimation()
     
                        switch completion {
                        case .failure(let error):
                            print(error.localizedDescription)
                        case .finished: break
            
                        }
                        
                    } receiveValue: { (searchResults) in
                        // If success
                        //print(searchResults)
                        self.searchResults = searchResults
     
                        // Reload tableview data
                        self.tableView.reloadData()
                        
                        self.tableView.isScrollEnabled = true  // Enable scrolling w/ results
                        
                    }.store(in: &self.subscribers)
                }.store(in: &subscribers)
            
        }
     


    
    
    
    // MARK: Search view controller
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search to add another stock"
        sc.searchBar.autocapitalizationType = .allCharacters
        sc.searchBar.scopeButtonTitles = ["Stocks", "Crypto"]
        return sc
    }()
    
    func updateSearchResults(for searchController: UISearchController) {
        
        searchQueryTextOccupied = searchController.searchBar.text == ""
        // let scopeButton = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonImage]
        
        guard let searchQuery = searchController.searchBar.text,
              !searchQuery.isEmpty else {
            
            return
            
        }
        
        //filterTableView(searchText: searchController.searchBar.text ?? "")  // and scopebutton when enabled
        
        self.searchQuery = searchQuery
        tableView.reloadData()
    }
    
    
//    private func filterTableView(searchText: String) {
//        // Check out https://www.youtube.com/watch?v=DAHG0orOxKo for how to do this
//    }
    
    
    private func setupNavigationBar() {
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        navigationItem.title = "My Stocks"
    }
    
    
}


// MARK: Tableview
extension SearchStocksViewController {
    
        // Triggers when the search bar is tapped
    func willPresentSearchController(_ searchController: UISearchController) {
        mode = .search
    }
    
    
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if searchController.isActive {
                return searchResults?.items.count ?? 0
                
            }
            //return orignalSearchQuery.count
            return self.listOfSecurities?.count ?? 0
        }
        
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
            if let searchResults = self.searchResults {
                
                if searchController.isActive {
                    
                    
                    let searchResult = searchResults.items[indexPath.row]
                    if searchQueryTextOccupied { return cell}
                    
                    if notSearchingQuery {
                        cell.textLabel?.text = searchResult.symbol
                        cell.detailTextLabel?.text = searchResult.name
                    } else {
                        cell.textLabel?.text = "searchResult.symbol"
                        cell.detailTextLabel?.text = "searchResult.name"
                    }

                }
               
                                
               
                
            } else {
//                let searchResult = orignalSearchQuery[indexPath.row]
//                print("Search result: \(searchResult)")
//
//                //if notSearchingQuery {
//                cell.textLabel?.text = searchResult.description
                
                let security = self.listOfSecurities![indexPath.row]
                cell.textLabel?.text = security.name
                cell.detailTextLabel?.text = ""
                
            }
            
        
            
            return cell
        }
        
    
        
        override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            if self.searchResults == nil {
                // Create swipe action
                let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
                    
                    // Which person to remove
                    let stockToRemove = self.listOfSecurities![indexPath.row]
                    
                    // Remove person
                    self.context.delete(stockToRemove)
                    
                    // Save data
                    do {
                        try self.context.save()
                    } catch {
                        
                    }
                    
                    // Re-fetch data
                    self.fetchSecurities()
               
                    
                }
                let configuration = UISwipeActionsConfiguration(actions: [action])
                     configuration.performsFirstActionWithFullSwipe = false
                     return configuration
            }
            
            return nil
            
            
        }

      
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let searchResults = self.searchResults {
                let searchResult = searchResults.items[indexPath.item]
                let symbol = searchResult.symbol
                orignalSearchQuery.append(symbol)
                print(orignalSearchQuery)
                handleSelection(for: symbol, searchResult: searchResult)
                
                // Save to core data
                do {
                    let newStock = Stock(context: self.context)
                    newStock.name = symbol.uppercased()
                    try self.context.save()
                } catch {
                    // Error
                }
               
                // Re-fetch data
                self.fetchSecurities()
                
            }
            
            // Prevent cells from being selected
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
        
        // Called when the user types on the table view cell
        private func handleSelection(for symbol: String, searchResult: SearchResult) {
            
            // Loading animation
            // showLoadingAnimation()
            
        }
}


class SearchTableViewCell: UITableViewCell {
//    func configure(with assetName: String, companyName: String) {
//        // Configure cells
//        if loading {
//            cell.textLabel?.text = "Loading news..."
//        } else {
//            let news = newsArray[indexPath.row]
//            cell.textLabel?.text = news[3]
//            cell.detailTextLabel?.text = news[2] + " " + news[1] + " " + news[4]
//            //cell.detailTextLabel?.text = news.
//        }
//    }
}
