//
//  ViewController.swift
//  Cache
//
//  Created by xiaopeng on 2017/5/31.
//  Copyright © 2017年 putao. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var response: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url: String = "https://api-park.putao.com/mall"
        
        var headers = [
            "Content-Type": "application/json; charset=UTF-8",
            ]
        
        let maxAge = 60*1 // 24小时 缓存的新鲜时间
        
        let status: ReachabilityStatus = Reach().connectionStatus()
        if status == .offline || status == .unknown {
            print("Not connected")
            headers["Cache-Control"] = "public, only-if-cached, max-stale=86400"//可以使用过期缓存
        } else {
            print("Connected via WWAN and WiFi")
            headers["Cache-Control"] = "public, max-age=\(maxAge)"
        }
        
         let req = Alamofire.request(url, method: .get, headers: headers)
        let cachedResponse = URLCache.shared.cachedResponse(for: req.request!)
  
        if let cache = cachedResponse {
            self.info.text = "读缓存"

            // 读缓存
            let json = try? JSONSerialization.jsonObject(with: cache.data, options:.allowFragments)
            print(json ?? "")
            
            self.response.text = "\(json)"
             print("读缓存")
        }else{
            if status == .offline || status == .unknown {
                print("response not found in cache and no internet connection")
            }else{
                // 拉取网络
                self.info.text = "拉取网络"

                
                //response not found in cache and internet connection available
                req.responseString(completionHandler: { [weak self](response) in
                    
                    let json = try? JSONSerialization.jsonObject(with: response.data!, options:.allowFragments)
                    print(json ?? "")
                    
                    // 存储response
                    let cachedURLResponse = CachedURLResponse(response: response.response!, data: response.data! as Data , userInfo: nil, storagePolicy: .allowed)
                    URLCache.shared.storeCachedResponse(cachedURLResponse, for: response.request!)
                    
                    self?.response.text = "\(json)"
                    print("拉取网络")
                    
                })
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

