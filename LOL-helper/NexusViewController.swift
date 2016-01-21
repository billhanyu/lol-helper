//
//  NexusViewController.swift
//  LOL-helper
//
//  Created by Bill Yu on 1/16/16.
//  Copyright © 2016 Bill Yu. All rights reserved.
//

import UIKit
import Alamofire

class NexusViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    var playerIDs: [String] = ["73659824", "72269897", "69993043", "30115863", "71721525", "72900212", "73719567", "73529976", "73339118", "73549812"]
    var playerNames: [String] = ["SammieNsanity", "pinkwolf109", "LOVEOOMR", "Khongkien", "lsettonl", "chasingagoal", "crystaleye22", "SlipandRIP", "CA1L3R87", "hazems"]
    
    var levelLabelTexts: [String] = ["Level: ", "Level: ", "Level: ", "Level: ", "Level: ", "Level: ", "Level: ", "Level: ", "Level: ", "Level: "]
    var winsLabelTexts: [String] = ["Wins: ", "Wins: ", "Wins: ", "Wins: ", "Wins: ", "Wins: ", "Wins: ", "Wins: ", "Wins: ", "Wins: "]
    
    let RATE_LIMIT = 5
    let dataGroup = dispatch_group_create()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.autocapitalizationType = .None
    }
    
    func populateData() {
        for i in 0...levelLabelTexts.count - 1 {
            levelLabelTexts[i] = ""
            winsLabelTexts[i] = ""
        }
        
        print("populating")
        
        for i in 0...playerNames.count - 1 {
            
            let name = self.playerNames[i]
            let ID = self.playerIDs[i]
            let escapedName = name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            fetchLevelData(i, name: name, escapedName: escapedName)
            fetchWinsData(i, ID: ID, escapedName: escapedName)
        }
        
        dispatch_group_notify(dataGroup, dispatch_get_main_queue(), {
            print("before reloading", self.levelLabelTexts)
            self.tableView.reloadData()
        })
    }
    
    func fetchLevelData(i: Int, name: String, escapedName: String) {
        dispatch_group_enter(dataGroup)
        print(i)
        Alamofire.request(.GET, "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/\(escapedName)?api_key=f50c97b7-6a8c-4d81-aafc-4ef4e4fa1571")
            .responseJSON { response in
            if response.response?.statusCode != 200 {
                print(i, response.response?.statusCode)
                delay(seconds: 0.33, completion: {
                    self.fetchLevelData(i, name: name, escapedName: escapedName)
                    dispatch_group_leave(self.dataGroup)
                })
            }
            else {
                let dictionary = parseJSON(response.data!)!
                let unspacedName = name.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
                let dict = dictionary[unspacedName] as! [String: AnyObject]
                
                let level = "Level: " + String(dict["summonerLevel"]! as! Int)
                self.levelLabelTexts[i] = level
                print(i, self.levelLabelTexts)
                dispatch_group_leave(self.dataGroup)
            }
        }
    }
    
    func fetchWinsData(i: Int, ID: String, escapedName: String) {
        
        dispatch_group_enter(dataGroup)
        Alamofire.request(.GET, "https://na.api.pvp.net/api/lol/na/v1.3/stats/by-summoner/\(ID)/summary?season=SEASON2015&api_key=f50c97b7-6a8c-4d81-aafc-4ef4e4fa1571").responseJSON { response in
            if response.response?.statusCode != 200 {
                print(i, response.response?.statusCode)
                delay(seconds: 0.33, completion: {
                    self.fetchWinsData(i, ID: ID, escapedName: escapedName)
                    dispatch_group_leave(self.dataGroup)
                })
            }
            else {
                let dictionary = parseJSON(response.data!)!
                let summaries = dictionary["playerStatSummaries"]! as! [AnyObject]
        
                for typeOfStats in summaries {
                    let stat = typeOfStats as! [String: AnyObject]
                    let type = String(stat["playerStatSummaryType"]!)
        
                    if  type == "Unranked" {
                        let winsString = String(stat["wins"]! as! Int)
        
                        let wins = "Wins: " + winsString
                        self.winsLabelTexts[i] = wins
                        dispatch_group_leave(self.dataGroup)
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Blue"
        }
        else {
            return "Red"
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell")! as! PlayerCell
        let name = playerNames[indexPath.section * 5 + indexPath.row]
        let levelLabelText = levelLabelTexts[indexPath.section * 5 + indexPath.row]
        let winsLabelText = winsLabelTexts[indexPath.section * 5 + indexPath.row]
        cell.initialize(name, levelLabelText: levelLabelText, winsLabelText: winsLabelText)
        return cell
    }
}

extension NexusViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let name = searchBar.text {
            let escapedName = name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            Alamofire.request(.GET, "https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/\(escapedName)?api_key=f50c97b7-6a8c-4d81-aafc-4ef4e4fa1571")
                .responseJSON { response in
                    if response.response?.statusCode != 200 {
                    }
                    else {
                        let dictionary = parseJSON(response.data!)!
                        let unspacedName = name.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
                        let dict = dictionary[unspacedName] as! [String: AnyObject]
                        let ID = String(dict["id"]! as! Int)
                        print(ID)
                        Alamofire.request(.GET, "https://na.api.pvp.net/observer-mode/rest/consumer/getSpectatorGameInfo/NA1/\(ID)?api_key=f50c97b7-6a8c-4d81-aafc-4ef4e4fa1571").responseJSON { response in
                            if response.response?.statusCode != 200 {
                                // not currently in a game
                                
                                // testing tableviewcell
                                self.populateData()
                            }
                            else {
                                let gameDictionary = parseJSON(response.data!)!
                                let playersDict = gameDictionary["participants"] as! [AnyObject]
                                
                                self.playerIDs.removeAll()
                                self.playerNames.removeAll()
                                for player in playersDict {
                                    let playerID = String(player["summonerId"]! as! Int)
                                    self.playerIDs.append(playerID)
                                    let playerName = String(player["summonerName"]! as! String)
                                    self.playerNames.append(playerName)
                                }
                                print(self.playerIDs)
                                print(self.playerNames)
                                
                                self.populateData()
                            }
                        }
                    }
            }
        }
    }
}
