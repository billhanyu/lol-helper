//
//  FirstViewController.swift
//  LOL-helper
//
//  Created by Bill Yu on 1/12/16.
//  Copyright © 2016 Bill Yu. All rights reserved.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController {
    
    var name: String?
    var ID: String!

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flush()
    }
    
    @IBAction func searchButtonClicked(sender: AnyObject) {
        searchField.resignFirstResponder()
        flush()
        
        if let name = searchField.text {
            let escapedName = name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            Alamofire.request(.GET, "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/\(escapedName)?api_key=f50c97b7-6a8c-4d81-aafc-4ef4e4fa1571")
                .responseJSON { response in
                    if response.response?.statusCode != 200 {
                        self.levelLabel.text = "No Result"
                    }
                    else {
                        let dictionary = parseJSON(response.data!)!
                        let unspacedName = name.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
                        let dict = dictionary[unspacedName] as! [String: AnyObject]
                        
                        self.ID = String(dict["id"]! as! Int)
                        self.getStats()
                        self.getRank()
                    
                        self.levelLabel.text = "Summoner Level: " + String(dict["summonerLevel"]! as! Int)
                    }
            }
        }
    }
    
    private func getStats() {
        print(ID)
        Alamofire.request(.GET, "https://na.api.pvp.net/api/lol/na/v1.3/stats/by-summoner/\(ID)/summary?season=SEASON2015&api_key=f50c97b7-6a8c-4d81-aafc-4ef4e4fa1571").responseJSON { response in
            if response.response?.statusCode == 200 {
                let dictionary = parseJSON(response.data!)!
                let summaries = dictionary["playerStatSummaries"]! as! [AnyObject]
                
                for typeOfStats in summaries {
                    let stat = typeOfStats as! [String: AnyObject]
                    let type = String(stat["playerStatSummaryType"]!)
                    
                    if  type == "Unranked" {
                        let winsString = String(stat["wins"]! as! Int)
                        self.winsLabel.text = "Wins: " + winsString
                    }
                }
            }
        }
    }
    
    private func getRank() {
        Alamofire.request(.GET, "https://na.api.pvp.net/api/lol/na/v2.5/league/by-summoner/\(ID)/entry?api_key=f50c97b7-6a8c-4d81-aafc-4ef4e4fa1571").responseJSON { response in
            if response.response?.statusCode == 200 {
                let dictionary = parseJSON(response.data!)!
                let statsOfRanks = dictionary[self.ID]! as! [AnyObject]
                
                for rank in statsOfRanks {
                    let type = rank["queue"]! as! String
                    if type == "RANKED_SOLO_5x5" {
                        let rankTier = rank["tier"]! as! String
                        print(rankTier)
                        self.rankLabel.text = rankTier
                    }
                    print(rank)
                }
            }
        }
    }
    
    private func flush() {
        levelLabel.text = ""
        winsLabel.text = ""
        rankLabel.text = ""
    }
}

