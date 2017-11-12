//
//  MovieListViewController.swift
//  TMDBAT
//
//  Created by Gustavo Gomes de Oliveira on 11/11/17.
//  Copyright © 2017 Gustavo Gomes de Oliveira. All rights reserved.
//

import UIKit
import Alamofire

class MovieListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var movieListTableView: UITableView!
    
    var page = 1
    var genreList: [[String: String]]!
    var movieList: [Movie]!
    var moviesImage: [UIImage]!
    var movieToSend: Movie!
    var isSearching = false
    var filteredData: [Movie]!
    var canLoadMore = true
    var alert: UIAlertController!
    var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieList = [Movie]()
        genreList = [[String:String]]()
        
        self.loadingView = LoadingView.instanceFromNib()
        loadingView.center = self.view.center
        self.view.addSubview(loadingView)
        
        
        getMovielist()
        moviesImage = [UIImage]()
        getGenres()
        
        searchBar.returnKeyType = UIReturnKeyType.done
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getMovielist(){
        
        if (canLoadMore) {
        
            DispatchQueue.main.async {
                self.loadingView.isHidden = false
                self.canLoadMore = false
                let appDelegate = UIApplication.shared.delegate as!  AppDelegate
                let apiKey = appDelegate.apiKey
            
                let parameters: Parameters = [
                
                    "api_key":apiKey,
                    "page": self.page.description
                ]
            
                Alamofire.request("https://api.themoviedb.org/3/movie/upcoming?api_key&language=en-US&page", parameters: parameters).responseJSON(completionHandler: {(response) in
                
                    if let json = response.result.value{
                    
                        if(((json as! NSDictionary)["results"] as! NSArray).count != 0) {
                        
                        
                            var upcomingMovie: Movie!
                            let movieArray = (json as! NSDictionary)["results"] as! NSArray
                        
                            for movie in movieArray {
                            
                                upcomingMovie = Movie()
                            
                                upcomingMovie.overview = self.applyStringValue(value: (movie as! NSDictionary)["overview"] as AnyObject)
                            
                                upcomingMovie.tittle = self.applyStringValue(value: (movie as! NSDictionary)["title"] as AnyObject)
                            
                                upcomingMovie.posterPath = self.applyStringValue(value: (movie as! NSDictionary)["poster_path"] as AnyObject)
                            
                                upcomingMovie.releaseDate = self.applyStringValue(value: (movie as! NSDictionary)["release_date"] as AnyObject)
                            
                                upcomingMovie.genre = self.applyIntArrayValue(value: (movie as! NSDictionary)["genre_ids"] as AnyObject)

                                self.movieList.append(upcomingMovie)
                            
                            }
                        
                            self.getPosterImage()
                        
                        } else {
                        
                            let alert = UIAlertController(title: "No more movies", message: "No more upcoming   movies avaiable", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.loadingView.isHidden = true
                            self.loadingView.removeFromSuperview()
                        }
                    
                    }
                })
            }
        }

    }
    
    
    func applyStringValue(value: AnyObject) -> String{
        
        var retorno = ""
        
        if (nullToNil(value: value) != nil){
            
            retorno = value as! String
            
        }
        
        return retorno
    }
    
    func applyIntArrayValue(value: AnyObject) -> [Int]{
        
        var retorno = [Int]()
        
        if (nullToNil(value: value) != nil){
            
            retorno = value as! [Int]
            
        }
        
        return retorno
    }
    
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    func getPosterImage(){
        
        let appDelegate = UIApplication.shared.delegate as!  AppDelegate
        let baseURL = appDelegate.baseURLForPostes
        let posterSize = appDelegate.posterSize
        
        DispatchQueue.main.async {
            
            for movie in self.movieList{

                
                Alamofire.request(baseURL! + posterSize! + movie.posterPath).responseData(completionHandler:{(response) in
                    
                    
                    if let data = response.data {
                        
                        if ((self.nullToNil(value: data as AnyObject)) != nil){
                            
                            if let image = UIImage(data: data) {
                                movie.posterImage = image
                            }
                        }
                        
                    }
                    self.movieListTableView.reloadData()
                    
                })
                
                self.loadingView.isHidden = true
                
            }
            self.canLoadMore = true
            
        }
        
    }
    
    
    func getGenres(){
        
        DispatchQueue.main.async {
            
            let appDelegate = UIApplication.shared.delegate as!  AppDelegate
            let apiKey = appDelegate.apiKey
            
            let parameters: Parameters = [
                
                "api_key":apiKey,
                "page": self.page.description
            ]
            
            Alamofire.request("https://api.themoviedb.org/3/genre/movie/list?api_key", parameters: parameters).responseJSON(completionHandler: {(response) in
            
                
                if let json = response.result.value {
                    
                    let genres = (json as! NSDictionary)["genres"] as! NSArray
                    
                    for genre in genres {

                        
                        let genreHelper = genre as! NSDictionary
                        let genreDict = [
                            "id":String(describing: genreHelper["id"]!),
                            "name":genreHelper["name"] as! String
                        ]
                        
                        self.genreList.append(genreDict)
                    }
                    
                }
                
                
            })
        
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "segueMovie"){
            
            let destinationVC = segue.destination as! MovieViewController
            destinationVC.movie = self.movieToSend!
            destinationVC.genreList = self.genreList!
            
        }
        
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.movieToSend = movieList[indexPath.row]
        performSegue(withIdentifier: "segueMovie", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (isSearching){
            
            return filteredData.count
        }
        
        return movieList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var movie = Movie()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMovie") as! MovieTableViewCell;
        
        if (isSearching){
         
            movie = filteredData[indexPath.row]
        } else {
            
            movie = movieList[indexPath.row]
        }
        
        if (movie.posterImage != nil) {
            
            cell.ImgMoviePoster.image = movie.posterImage
            cell.LoadingImageIndicator.stopAnimating()
        } else {
            
            cell.ImgMoviePoster.image = nil
            cell.LoadingImageIndicator.startAnimating()

        }
        
        cell.LblMovieName.text = movie.tittle
        cell.LblMovieReleaseDate.text = movie.releaseDate
        return cell;
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if (distanceFromBottom < height && canLoadMore) {
            
            self.page = page + 1
            getMovielist()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchBar.text == nil || searchBar.text == "") {
            
            isSearching = false
            view.endEditing(true)
            DispatchQueue.main.async {
                self.movieListTableView.reloadData()
                
            }
                
        } else {
            
            isSearching = true
            self.loadingView.isHidden = true
            filteredData = movieList.filter({$0.tittle.contains(searchBar.text!)})
            
            DispatchQueue.main.async {
                self.movieListTableView.reloadData()
                
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchBar.returnKeyType = UIReturnKeyType.done
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        view.endEditing(true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        searchBar.returnKeyType = UIReturnKeyType.done
    }
    

}
