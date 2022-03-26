//
//  APIService.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/2/22.
//
 
import Foundation
import Combine
 
struct APIService {
    
    // Custom error
    enum APIServiceError: Error {
        case encoding
        case badRequest
    }
    
    // Get a randome key on each call
    var API_KEY: String {
        return keys.randomElement() ?? ""
    }
    
    // Select API key by random
    // These API keys are free but only handle a few requests per min
    let keys = ["CC57C4UA589EXWDK", "33490Y7WD4GBLC4Q", "GYH1VMWUNLRRHFCD", "AH3AGY03I21IBRSQ", "ZA4ALR2ERF1JOFIO", "77E9UNF6K23533MV", "04DZ3U7P4FYT4LNN", "9F3HU0FJD87QO93Z", "0SL8UICU6MNIYYBM"]
    
    
    // SearchResults is the success model, or Error if an error occurs
    // Fetch data for populating search table view data
    func fetchSymbolePublisher(ticker: String) -> AnyPublisher<SearchResults, Error> {
        
        let result = parseQuery(text: ticker)
        var symbol = String()
 
        switch result {
        case.success(let query):
            symbol = query
        case.failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        //guard let ticker = ticker.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
//            return Fail(error: APIServiceError.encoding).eraseToAnyPublisher()
//
//
//
//        print(ticker)
        
 
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(symbol)&apikey=\(API_KEY)"
        
        let urlResult = parseURL(urlString: urlString)
        
        switch urlResult {
        case .success(let url):
            // Return URLSession thats received on the main thread
            return URLSession.shared.dataTaskPublisher(for: url)
                .map({ $0.data })
                .decode(type: SearchResults.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        
        guard let url = URL(string: urlString) else { return Fail(error: APIServiceError.badRequest).eraseToAnyPublisher() }
        
        //print(url)
        
        // Return URLSession thats received on the main thread
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    
    private func parseQuery(text: String) -> Result<String, Error> {
        if let query = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return .success(query)
        } else {
            return .failure(APIServiceError.encoding)
        }
    }
    
    
    private func parseURL(urlString: String) -> Result<URL, Error> {
        if let url = URL(string: urlString) {
            return .success(url)
        } else {
            return .failure(APIServiceError.badRequest)
        }
    }
}
    
 

