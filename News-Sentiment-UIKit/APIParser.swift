//
//  APIParser.swift
//  News-Sentiment-UIKit
//
//  Created by Alek Michelson on 3/17/22.
//

import Foundation

class APIParser {

    var newsComponent = URLComponents(string: "http://0.0.0.0:5000/news/")
    var sentimentComponent = URLComponents(string: "http://0.0.0.0:5000/sentiment/")

    
    func getNewsRequest(ticker : String) -> URLComponents {
        newsComponent?.queryItems = [
            URLQueryItem(name: "ticker", value: ticker),
        ]
        
        return newsComponent!
    }
    
    
    func getSentimentRequest(ticker : String) -> URLComponents {
        sentimentComponent?.queryItems = [
            URLQueryItem(name: "ticker", value: ticker),
        ]
        
        return sentimentComponent!
    }
}
