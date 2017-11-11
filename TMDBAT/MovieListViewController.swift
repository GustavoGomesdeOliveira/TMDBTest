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
    var canLoadMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieList = [Movie]()
        genreList = [[String:String]]()
        
        getMovielist()
        moviesImage = [UIImage]()
        getGenres()
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
//        group.enter()
//        getMovielist() {
//            self.getPosterImage()
//            group.leave()
//        }
        
      //  group.enter()
//        getPosterImage() {
//            group.leave()
//        }
//        
//        group.notify(queue: .main) {
//            print("both requests done")
//        }
//        
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getMovielist(){
        
        DispatchQueue.main.async {
            
            let appDelegate = UIApplication.shared.delegate as!  AppDelegate
            let apiKey = appDelegate.apiKey
            
            let parameters: Parameters = [
                
                "api_key":apiKey,
                "page": self.page.description
            ]
            
            let alert = UIAlertController(title: "Upcoming Movies", message: "Loading", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
            
            Alamofire.request("https://api.themoviedb.org/3/movie/upcoming?api_key&language=en-US&page", parameters: parameters).responseJSON(completionHandler: {(response) in
                print(response.request?.url)
                
                if let json = response.result.value{
                    
                    var upcomingMovie: Movie!
                    let movieDict = json as! NSDictionary
                    let movieArray = movieDict["results"] as! NSArray
                    
                    for movie in movieArray{
                        
                        upcomingMovie = Movie()
                        
                        upcomingMovie.tittle = (movie as! NSDictionary)["title"] as! String
                        upcomingMovie.overview = (movie as! NSDictionary)["overview"] as! String
                        
                        upcomingMovie.posterPath = (movie as! NSDictionary)["poster_path"] as! String
                        upcomingMovie.releaseDate = (movie as! NSDictionary)["release_date"] as! String
                        
                        upcomingMovie.genre = (movie as! NSDictionary)["genre_ids"] as! NSArray as! [Int]
                        
                        self.movieList.append(upcomingMovie)
                    }
                }
                self.getPosterImage()
            })
            
            alert.dismiss(animated: true, completion: nil)
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
                        
                        movie.posterImage = (UIImage(data: data)!)
                        
                    }
                    
                    self.movieListTableView.reloadData()
                    self.canLoadMore = true
                })
                
                
            }
            
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        
        cell.ImgMoviePoster.image = movie.posterImage
        cell.LblMovieName.text = movie.tittle
        cell.LblMovieReleaseDate.text = movie.releaseDate
        return cell;
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if (distanceFromBottom < height && canLoadMore) {
            
            canLoadMore = false
            self.page += page
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
            
            filteredData = movieList.filter({$0.tittle.contains(searchBar.text!)})
            
            DispatchQueue.main.async {
                self.movieListTableView.reloadData()
                
            }
        }
    }
}
