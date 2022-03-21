//
//  SearchTableViewController.swift
//  News-Sentiment-UIKit
//
//  Created by Alek Michelson on 3/20/22.
//

import UIKit
import Combine

class SearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
        
    // Control which tableview is shown
    private enum Mode {
        case selected
        case search
    }
    
    
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
    }
    
    private func observeForm() {
            
            // Call the API every 750 milliseconds
            $searchQuery
                .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
                .sink { [unowned self] (searchQuery) in
                    
                    // Stops function from searching empty query (bug fix)
                    guard !searchQuery.isEmpty else {
                        notSearchingQuery = true
                        return
                        
                    }
                    
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
            $mode.sink { [unowned self] (mode) in
                switch mode {
                case .selected:
                    self.tableView.backgroundView = SelectedStockView() as? UIView

                case .search:
                    self.tableView.backgroundView = nil
                }
            }.store(in: &subscribers)
        }
     


    
    
    
    // MARK: Search view controller
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name or ticker symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text, !searchQuery.isEmpty else { return }
        self.searchQuery = searchQuery
    }
    
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.title = "My Stocks"
    }
    
    
}


// MARK: Tableview
extension SearchTableViewController {
    
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if notSearchingQuery {
                return searchResults?.items.count ?? 0
            } else {
                return 0
                
            }
            
        }
        
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
            if let searchResults = self.searchResults {
                let searchResult = searchResults.items[indexPath.row]
                
                if notSearchingQuery {
                    cell.textLabel?.text = searchResult.symbol
                    cell.detailTextLabel?.text = searchResult.name
                } else {
                    cell.textLabel?.text = "searchResult.symbol"
                    cell.detailTextLabel?.text = "searchResult.name"
                }
                
            }
            
        
            
            return cell
        }
        
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let searchResults = self.searchResults {
                let searchResult = searchResults.items[indexPath.item]
                let symbol = searchResult.symbol
                handleSelection(for: symbol, searchResult: searchResult)
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
        
    
    //        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //            if segue.identifier == "showCalculator",
    //                let destination = segue.destination as? CalculatorTableViewController,
    //                let asset = sender as? Asset {
    //                destination.asset = asset
    //            }
    //        }
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
