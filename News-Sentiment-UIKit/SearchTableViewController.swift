//
//  SearchTableViewController.swift
//  News-Sentiment-UIKit
//
//  Created by Alek Michelson on 3/20/22.
//

import UIKit
import Combine

class SearchTableViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate {
        
    
    @Published private var searchQuery = String()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
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
