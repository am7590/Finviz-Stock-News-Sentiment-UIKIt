//
//  SearchTableViewController.swift
//  News-Sentiment-UIKit
//
//  Created by Alek Michelson on 3/20/22.
//

import UIKit
import Combine

class SearchStocksViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
        
    // Control which tableview is shown
    private enum Mode {
        case selected
        case search
    }
    
    @Published private var searchQueryTextOccupied = false
    @Published private var mode: Mode = .selected
    @Published private var orignalSearchQuery = ["TSLA", "GME"]
    @Published private var searchQuery = String() {
        didSet {
              if searchQuery.count > 1 {
                  print("changed")
                  searchQueryTextOccupied = true
                 //Update Table Data
              } else {
                  print("not changed")
                  searchQueryTextOccupied = false
                 //Hide Table and show so info of no data
              }
           }
    }
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
    }
    
    private func observeForm() {
            
            // Call the API every 750 milliseconds
            $searchQuery
                .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
                .sink { [unowned self] (searchQuery) in
                    
                    print(searchQueryTextOccupied)
//                    print(searchQuery.isEmpty)
//                    print(searchQuery.count)
                    
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
            
            // Observe mode
//            $mode.sink { [unowned self] (mode) in
//                switch mode {
//                case .selected:
//                    self.tableView.backgroundView = SelectedStockView()
//
//                case .search:
//                    self.tableView.backgroundView = nil
//                }
//            }.store(in: &subscribers)
        }
     


    
    
    
    // MARK: Search view controller
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name or ticker symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        sc.searchBar.scopeButtonTitles = ["Stocks", "Crypto"]
        return sc
    }()
    
    func updateSearchResults(for searchController: UISearchController) {
        
        searchQueryTextOccupied = searchController.searchBar.text == ""
        // let scopeButton = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonImage]
        
        guard let searchQuery = searchController.searchBar.text,
              !searchQuery.isEmpty else {
            //if !searchController.isActive {
                //self.tableView.backgroundView = SelectedStockView()
            //}
            
            return
            
        }
        
        //filterTableView(searchText: searchController.searchBar.text ?? "")  // and scopebutton when enabled
        
        self.searchQuery = searchQuery
        tableView.reloadData()
    }
    
    
//    private func filterTableView(searchText: String) {
//        // Check out https://www.youtube.com/watch?v=DAHG0orOxKo for how to do this
//        //i
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
            return orignalSearchQuery.count
   
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
                let searchResult = orignalSearchQuery[indexPath.row]
                print("Search result: \(searchResult)")
                
                //if notSearchingQuery {
                cell.textLabel?.text = searchResult.description
            }
            
        
            
            return cell
        }
        
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//           let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
//           vc?.image = UIImage(named: names[indexPath.row] )!
//           vc?.name = names[indexPath.row]
//           navigationController?.pushViewController(vc!, animated: true)
//    }
      
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let searchResults = self.searchResults {
                let searchResult = searchResults.items[indexPath.item]
                let symbol = searchResult.symbol
                handleSelection(for: symbol, searchResult: searchResult)
                
                // Send data to SelectedStockView
//                let vc = SelectedStockView()
//                myArray.append(symbol)
//                print("Adding \(searchResult.name) to myArray")
//                print("myArray: \(myArray)")
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)

                
            }
            
            // Prevent cells from being selected
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
        
        // Called when the user types on the table view cell
        private func handleSelection(for symbol: String, searchResult: SearchResult) {
            
            // Loading animation
            // showLoadingAnimation()
            
            // Fetch data
//            apiService.fetchTimeSeriesMonthlyAdjustedPublisher(ticker: symbol).sink { (completionResult) in
//                self.hideLoadingAnimation()
//                switch completionResult {
//                case .failure(let error):
//                    print(error)
//                case .finished: break  // Unlikely to happen
//                }
//
//            } receiveValue: { (timeSeriesMonthlyAdjusted) in
//                self.hideLoadingAnimation()
//                let asset = Asset(searchResult: searchResult, timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted)
//                self.performSegue(withIdentifier: "showCalculator", sender: asset)
//    //            print("success: \(timeSeriesMonthlyAdjusted.getMonthInfo())")
//                self.searchController.searchBar.text = nil  // Gets rid of redundent api calls after navigating back from calculator view
//
//
//            }.store(in: &subscribers)
     
            
            
            //performSegue(withIdentifier: "showCalculator", sender: nil)
        }
        
    
//            override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//                if segue.identifier == "showCalculator",
//                    let destination = segue.destination as? Sele,
//                    let asset = sender as? Asset {
//                    destination.asset = asset
//                }
//            }
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
