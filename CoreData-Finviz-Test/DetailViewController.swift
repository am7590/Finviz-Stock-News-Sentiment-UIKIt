//
//  DetailViewController.swift
//  CoreData-Finviz-Test
//
//  Created by Alek Michelson on 3/23/22.
//

import UIKit

class DetailViewController: UIViewController {

    // Reminder: refactor names
    let secondVC = MyStocksViewController()
    let thirdVC = SearchStocksViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSegment()
        
        
    }
    
    private func setupSegment() {
        
        
        addChild(secondVC)
        addChild(thirdVC)
        self.view.addSubview(secondVC.view)
        self.view.addSubview(thirdVC.view)
        
        secondVC.didMove(toParent: self)
        thirdVC.didMove(toParent: self)
        
        secondVC.view.frame = self.view.bounds
        thirdVC.view.frame = self.view.bounds
        
        thirdVC.view.isHidden = true


    }
    
    
    @IBAction func didTapSegment(segment: UISegmentedControl) {
        // Hide views first
        secondVC.view.isHidden = true
        thirdVC.view.isHidden = true
        
        
        if segment.selectedSegmentIndex == 0 {
            // Show MyStocks VC
            secondVC.view.isHidden = false
        } else {
            // Show SearchStocks VC
            thirdVC.view.isHidden = false

        }
    }


}
