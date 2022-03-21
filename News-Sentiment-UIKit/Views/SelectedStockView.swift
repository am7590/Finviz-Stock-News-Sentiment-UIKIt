//
//  SelectedStockView.swift
//  News-Sentiment-UIKit
//
//  Created by Alek Michelson on 3/20/22.
//

import UIKit

//class SelectedStockView: UIView {
//    

//    
//}

class SelectedStockView: UIView, UITableViewDelegate, UITableViewDataSource {

    private let myArray: NSArray = ["Tesla"] //"GME","Third"
    private var myTableView: UITableView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        myTableView = UITableView(frame: CGRect(x: 0, y: 124, width: 400, height: 200))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.clipsToBounds = true
        addSubview(myTableView)
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(myArray[indexPath.row])")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(myArray[indexPath.row])"
        return cell
    }
}

