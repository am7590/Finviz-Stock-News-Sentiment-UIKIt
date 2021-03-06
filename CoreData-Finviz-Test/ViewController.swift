//
//  ViewController.swift
//  CoreData-Finviz-Test
//
//  Created by Alek Michelson on 3/23/22.
//

import UIKit
import Charts


class ViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barChart: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup tableview
        tableView.delegate = self
        tableView.dataSource = self
        
        //fetchSecurities()
        setupBarChart()
//        setupBarChart(data: sentimentArray)
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        fetchSecurities()
        setupBarChart()
    }
    
    
    // MARK: Get stock data from CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @Published private var listOfSecurities:[Stock]?
    
    
    func fetchSecurities() {
        
        do {
            self.listOfSecurities = try context.fetch(Stock.fetchRequest())  // Get all items
            
            for item in self.listOfSecurities! {
                getNews(ticker: item.name ?? "")
                getSentiment(ticker: item.name ?? "")
            }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
            
        } catch {
            
        }
        
    }
    
    
    // MARK: Populate Charts
    var sentimentArray = [String:Double]()
    var dataEntries: [BarChartDataEntry] = []

    
    func setupBarChart() {
        
        print(dataEntries)
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Sentimenet")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartDataSet.colors = ChartColorTemplates.colorful()

        barChart.data = chartData
        
    }
    
    
    
    // MARK: Tableview
    var parser = APIParser()
    var newsArray = [[String]]()
    var loading = true
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading {
            return 0
        } else {
            return newsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! ViewControllerTableViewCell
        cell.selectionStyle = .none

        // Configure cells
        if loading {
            //cell.textLabel?.text = "Loading news..."
        } else {
            
            
            let news = newsArray[indexPath.row]
            cell.configure(with: news)
            // print(news)
            
            // News data points: Ticker, Date, Time, Title, Source, Link
            
            
            //cell.textLabel?.text = news[0] + "       " + news[3]
            //cell.detailTextLabel?.text = news[2] + " " + news[1] + " " + news[4]
            //cell.detailTextLabel?.text = news.
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = newsArray[indexPath.row]
        let urlString = news[5]
            if let url = URL(string: urlString)
            {
                UIApplication.shared.openURL(url)
            }
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
                    
                    
                    self.newsArray = self.newsArray.sorted(by: {
                        ($0[1], $0[2]) > ($1[1], $1[2])
                    })


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
                    //print(parsedJSON.content)
                    self.sentimentArray = parsedJSON.content
                    
                    //print(self.sentimentArray )
                    
                    var count: Int = 0
                    for item in self.sentimentArray {
                        print(item.value)
                        self.dataEntries.append( BarChartDataEntry(x: Double(count), y: Double(item.value) ))
                        count += 1
                    }
                    self.setupBarChart()
                    
                } catch {
                    print("Error parsing JSON")
                }
            }
            
        }).resume()
    }

    

}


class ViewControllerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func configure(with news: [String]) {
        
        tickerLabel?.text = news[0]
        headlineLabel?.text = news[3]
        sourceLabel?.text = news[4]
        timeLabel?.text = news[1]
        dateLabel?.text = news[2]
          
    }
    
    
}
