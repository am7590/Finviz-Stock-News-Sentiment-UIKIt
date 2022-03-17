//
//  APIStruct.swift
//  News-Sentiment-UIKit
//
//  Created by Alek Michelson on 3/17/22.
//

import Foundation

//{"ticker": "tsla",
// "content": [["tsla", "Mar-16-22", "10:28PM", "Tesla says it is trying to keep production going at Shanghai factory", "Reuters", "https://finance.yahoo.com/news/tesla-says-trying-keep-production-022841904.html"], ["tsla", "Mar-16-22", "10:05PM", "Elon Musk Prepares His Fight to End Russian Invasion of Ukraine", "TheStreet.com", "https://www.thestreet.com/technology/elon-musk-prepares-his-fight-to-end-russian-invasion-of-ukraine?puc=yahoo&cm_ven=YAHOO"], ["tsla", "Mar-16-22", "09:56PM", "Elon Musk Prepares for Russian Duel to End The Invasion of Ukraine", "TheStreet.com"],
//  "time_called": "1:21.35"}


struct NewsStruct: Decodable {
    var ticker: String
    var content: [[String]]
    var time_called: String
}



// {"ticker": "tsla",
//  "content": {"Mar-16-22": 0.0, "Mar-15-22": 0.0, "Mar-14-22": 0.0},
//  "time_called": "1:44.35"}

struct SentimentStruct: Decodable {
    var ticker: String
    var content: [String:Double]
    var time_called: String
}

