//
//  PiccaCollectionViewController.swift
//  Picca
//
//  Created by Rens Gingnagel on 15/12/2017.
//  Copyright © 2017 Rens Gingnagel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


//Initialize variables
var arrayLikes: [Any] = []
var likesThumbnails: [String] = []

class PiccaCollectionViewController: UICollectionViewController {
    private let reuseIdentifier = "myCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch all of the liked images from the firebase database.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Make reference to the firebase database.
        let likesRef = Database.database().reference(withPath: "likes")
        //Get all of the items in the likes database.
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else{return}
            
            arrayLikes = Array(value.values)
            
            guard let arrayLikes = arrayLikes as? [[String: String]] else {return}
            likesThumbnails = arrayLikes.flatMap {$0["Thumbnail"]}
            //Reload the view so that the new data is loaded in.
            self.collectionView?.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        // There should be same amount of items in the section as there are liked images.
//      Make a cell for every liked image.
        return likesThumbnails.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Make cell that is of the custom made class.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! PiccaCollectionViewCell
        
        cell.backgroundColor = UIColor.white
        let thisThumbnail = likesThumbnails[indexPath.item]
        
        
        guard let url = URL(string: thisThumbnail) else {return cell}
        let data = try? Data(contentsOf: url)
        //Load the image from the url to the imageview.
        cell.imageView.image = UIImage(data: data!)

        
        return cell
    }
    

}
