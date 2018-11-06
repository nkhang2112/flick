//
//  NowPlayingViewController.swift
//  Flick
//
//  Created by Khang Nguyen on 10/31/18.
//  Copyright © 2018 Khang Nguyen. All rights reserved.
//

import UIKit
import AlamofireImage

class NowPlayingViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var reloadAnimation: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    var movies:[[String:Any]] = []
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefesh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        reloadAnimation.startAnimating()
        fetchMovie()
        
        // Do any additional setup after loading the view.
    }
    
    @objc func didPullToRefesh(_ refreshControl: UIRefreshControl){
        reloadAnimation.startAnimating()
        fetchMovie()
    }
    
    func fetchMovie() {
        
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default , delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: url) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
                
                //handle alert when no internet
                let alertController = UIAlertController(title: "Cannot Get Movies", message: "The internet connection appeared to be offline", preferredStyle: .alert)
                let tryAgainAction = UIAlertAction(title: "Try Again", style: .default){(action) in
                    self.fetchMovie()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){(action) in
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(tryAgainAction)
                self.present(alertController, animated: true)
                
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                let movies = dataDictionary["results"] as! [[String:Any]]
                self.movies = movies
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.reloadAnimation.stopAnimating()
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = movies[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let posterPathString = movie["poster_path"] as! String
        let baseUrlString = "https://image.tmdb.org/t/p/w500"
        let posterUrl = URL(string: baseUrlString+posterPathString)!
        cell.posterImageView.af_setImage(withURL: posterUrl)
        return cell
    }
    
}
