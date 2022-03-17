//
//  ViewController.swift
//  News-Sentiment-UIKit
//
//  Created by Alek Michelson on 3/17/22.
//

import UIKit

class ViewController: UITableViewController {
    
    var parser = APIParser()
    var newsArray = [[String]]()
    var loading = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getNews(ticker: "TSLA")
        // getSentiment(ticker: "TSLA")
    }
    
    
    // MARK: Table View Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading {
            return 1
        } else {
            return newsArray.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
        
        // Configure cells
        if loading {
            cell.textLabel?.text = "Loading news..."
        } else {
            let news = newsArray[indexPath.row]
            cell.textLabel?.text = news[3]
            cell.detailTextLabel?.text = news[2] + " " + news[1] + " " + news[4]
            //cell.detailTextLabel?.text = news.
        }
        
        return cell
    }
    
    
    
    // MARK: Parse API data
    private func getNews(ticker: String) {
        let component : URLComponents = parser.getNewsRequest(ticker: ticker)
        // var returnJSON : [String : Int] = [:]

        let urlRequest = URLRequest(url: component.url!)
        print(urlRequest.url ?? "Failed to load URL")
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let data = data {
    
                // let json = String(data: data, encoding: .utf8)
                let jsonDecoder = JSONDecoder()
                
                do {
                    let parsedJSON = try jsonDecoder.decode(NewsStruct.self, from: data)
                    
                    print(parsedJSON.content.description)
                    
                    
                    
                    self.newsArray = parsedJSON.content
                    
                    //returnJSON = self.parser.sortData(parsedJSON: parsedJSON)
                    
                    //DispatchQueue.main.async {
                        //self.query.text = returnJSON.description
                        //self.queryText.text = returnJSON.description
                    //}

                } catch {
                    print("Error parsing JSON")
                }
            }
            
            self.loading = false
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            
        }).resume()
    }

    
    private func getSentiment(ticker: String) {
        let component : URLComponents = parser.getSentimentRequest(ticker: ticker)
        // var returnJSON : [String : Int] = [:]

        let urlRequest = URLRequest(url: component.url!)
        print(urlRequest.url ?? "Failed to load URL")
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let data = data {
    
                // let json = String(data: data, encoding: .utf8)
                let jsonDecoder = JSONDecoder()
                
                do {
                    let parsedJSON = try jsonDecoder.decode(SentimentStruct.self, from: data)
                    
                    print(parsedJSON)
                    
                    //returnJSON = self.parser.sortData(parsedJSON: parsedJSON)
                    
                    //DispatchQueue.main.async {
                        //self.query.text = returnJSON.description
                        //self.queryText.text = returnJSON.description
                    //}

                } catch {
                    print("Error parsing JSON")
                }
            }
            
        }).resume()
    }

}

