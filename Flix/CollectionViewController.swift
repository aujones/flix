//
//  CollectionViewController.swift
//  Flix
//
//  Created by Audrey Jones on 6/22/17.
//  Copyright © 2017 Audrey Jones. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var movies: [[String: Any]] = []
    var filteredMovies : [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
        activityIndicator.startAnimating()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=3e7d90028adc30c483b7983f82af2a8b")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            }else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String: Any]]
                self.movies = movies
                self.filteredMovies = movies
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
            }
            
        }
        task.resume()

        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionMovieCell", for: indexPath) as! CollectionMovieCell
        let movie = filteredMovies[indexPath.row]
        let baseURLString = "https://image.tmdb.org/t/p/w500"
        let posterPathString = movie["poster_path"] as! String
        let fullPosterPath = baseURLString + posterPathString
        let posterURL = URL(string: fullPosterPath)
        cell.posterImage.af_setImage(withURL: posterURL!)
        return cell
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        // ... Create the URLRequest `myRequest` ...
        
        // Configure session so that completion handler is executed on main UI thread
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=3e7d90028adc30c483b7983f82af2a8b")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            }else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String: Any]]
                self.movies = movies
                self.collectionView.reloadData()
                
                refreshControl.endRefreshing()
                
            }
            
        }
        task.resume()
    }
 
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        
        if searchText.isEmpty {
            filteredMovies = movies
        }
        else {
            filteredMovies = movies.filter { (movie: [String : Any]) -> Bool in
                let title = movie["title"] as! String
                return title.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            }
        }
        
        collectionView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell
        if let indexPath = collectionView.indexPath(for: cell) {
        let movie = filteredMovies[indexPath.row]
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
     
     }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
