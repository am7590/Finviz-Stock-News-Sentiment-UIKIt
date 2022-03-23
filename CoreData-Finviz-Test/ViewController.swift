//
//  ViewController.swift
//  CoreData-Finviz-Test
//
//  Created by Alek Michelson on 3/23/22.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup tableview
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchSecurities()
        // Do any additional setup after loading the view.
    }
    
    
    
    // MARK: Get stock data from CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @Published private var listOfSecurities:[Stock]?
    
    
    func fetchSecurities() {
        
        do {
            self.listOfSecurities = try context.fetch(Stock.fetchRequest())  // Get all items
            
            for item in self.listOfSecurities! {
                print(item.name)
                getNews(ticker: item.name ?? "")
            }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
            
        } catch {
            
        }
        
    }
    
    
    // MARK: Tableview
    var parser = APIParser()
    var newsArray = [[String]]()
    var loading = true
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading {
            return 1
        } else {
            return newsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
        
        // Configure cells
        if loading {
            cell.textLabel?.text = "Loading news..."
        } else {
            
            
            let news = newsArray[indexPath.row]
            print(news)
            cell.textLabel?.text = news[0] + "       " + news[3]
            cell.detailTextLabel?.text = news[2] + " " + news[1] + " " + news[4]
            //cell.detailTextLabel?.text = news.
        }
        
        return cell
    }
    

    // MARK: Get API data
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
                           
                    self.newsArray += (parsedJSON.content)


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
                                        

                } catch {
                    print("Error parsing JSON")
                }
            }
            
        }).resume()
    }

    

}

