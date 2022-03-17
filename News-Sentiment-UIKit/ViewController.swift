//
//  ViewController.swift
//  News-Sentiment-UIKit
//
//  Created by Alek Michelson on 3/17/22.
//

import UIKit

class ViewController: UIViewController {
    
    var parser = APIParser()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // getNews(ticker: "TSLA")
        getSentiment(ticker: "TSLA")
    }
    
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

