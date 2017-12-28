//
//  imageViewController.swift
//  Picca
//
//  Created by Rens Gingnagel on 08/12/2017.
//  Copyright © 2017 Rens Gingnagel. All rights reserved.
//

import UIKit
import Disk
import Firebase
import FirebaseAuth


class imageViewController: UIViewController {


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Create outlets
    @IBOutlet weak var uiImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var photographerLabel: UILabel!
    @IBOutlet weak var infoView: UIStackView!
    
    var oldImageData: Photo?

    @IBAction func likeButtonPressed(_ sender: Any) {
        setNewPhoto(like: true)
    }
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        setNewPhoto(like: false)
    }
    
    
    @IBAction func closePressed(_ sender: Any) {
        //Disable the info popup.
        infoView.isHidden = true
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        //Show the photo info popup.
        infoView.isHidden = false
    }
    
    //Define the codable structs as they are used in the API.
    struct Urlstruct: Codable {
        var raw: String?
        var full: String?
        var regular: URL?
        var small: String?
        var thumb: String?
    }
    
    struct User: Codable {
        var id: String?
        var username: String?
        var name: String?
    }
    
    struct Photo: Codable {
        var id: String?
        var description: String?
        var urls: Urlstruct?
        var user: User?
    }
    
    struct imageData{
        var description: String?
        var author: String?
        var id: String?
    }

    //Call the unslplash API, decode the photo data contents and return them.
    func callAPI() -> Photo?{
        let url = URL(string: "https://api.unsplash.com/photos/random/?client_id=d045418f560e79b6e822ec2329ebc03de8bdadd2e180ce9044b4e663e3e25159&orientation=landscape&featured=True")!
        guard let data = try? Data(contentsOf: url) else{return nil}
        let jsonDec = JSONDecoder()
        guard let result = try? jsonDec.decode(Photo.self, from: data) else{ return nil}
        return result
    }
    
    func setNewPhoto(like: Bool){
        //Add image to the likes collection on firebase if the like button was pressed.
        if(like){
            let likesRef = Database.database().reference(withPath: "likes")
            let reference  = likesRef.childByAutoId()
            if let oldImageID = oldImageData?.id, let oldImageThumbnail = oldImageData?.urls?.thumb {
                reference.child("ID").setValue(oldImageID)
                reference.child("Thumbnail").setValue(oldImageThumbnail)
            }
           
        }
        
        //Unwrap Image
        guard let CurrentImageData = callAPI() else {
            print("There is no Image")
            setNewPhoto(like: like)
            return
        }
    
        //Unwrap Image URL
        guard let CurrentImageURL = CurrentImageData.urls?.regular else {
            print("There is no Image URL")
            setNewPhoto(like: like)
            return
        }
        
        //Save current image to be able to add to firebase later on.
        oldImageData = CurrentImageData
        //Save current image data to disk for persistency.
        do{
            try Disk.save(oldImageData, to: .documents, as: "oldImageData")
        } catch{
            print("Saving image data to disk failed.")
        }
        
        
        // Unwrap and set the photo description, photographer and id.
        if let CurrentImagePhotographer = CurrentImageData.user?.username, let CurrentImageDescription = CurrentImageData.description, let CurrentImageID = CurrentImageData.id {
            photographerLabel.text = CurrentImagePhotographer
            descriptionLabel.text = CurrentImageDescription
            IDLabel.text = CurrentImageID
        } else {
            print("There is no photographer, description or id.")
        }
        
        setPhotoInterface(CurrentImageURL: CurrentImageURL)
    }
    
    func setPhotoInterface(CurrentImageURL: URL){
        //Grab the image from the url specified in the data returned by the API and place in the ImageView.
        let session = URLSession(configuration: .default)
        //creating a dataTask
        let getImageFromUrl = session.dataTask(with: CurrentImageURL) { (data, response, error) in
            
            //if there is any error
            if let e = error {
                //displaying the message
                print("Error Occurred: \(e)")
                
            } else {
                //in case of now error, checking wheather the response is nil or not
                if (response as? HTTPURLResponse) != nil {
                    
                    //checking if the response contains an image
                    if let imageData = data {
                        
                        //getting the image
                        let image = UIImage(data: imageData)
                        
                        do{
                            try Disk.save(imageData, to: .documents, as: "oldImage.png")
                        } catch{
                            print("Saving image to disk failed.")
                        }
                        
                        //displaying the image
                        DispatchQueue.main.async() { self.uiImageView.image = image }
                        
                    } else {
                        print("Image file is currupted")
                    }
                } else {
                    print("No response from server")
                }
            }
        }
        
        //starting the download task
        getImageFromUrl.resume()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        infoView.isHidden = true
        
        // Check if an old image and it's data are stored on disk.
        do{
            // Get the old image data from the disk.
            let retrievedData = try Disk.retrieve("oldImageData", from: .documents, as: Photo.self)
            //Get the old image from the disk.
            let retrievedImage = try Disk.retrieve("oldImage.png", from: .documents, as: Data.self)
            let oldImage = UIImage(data: retrievedImage)
            //Set the old image as the UI image.
            DispatchQueue.main.async() { self.uiImageView.image = oldImage }
            //Set all of the old image data to the interface.
            if let CurrentImagePhotographer = retrievedData.user?.username, let CurrentImageDescription = retrievedData.description, let CurrentImageID = retrievedData.id {
                photographerLabel.text = CurrentImagePhotographer
                descriptionLabel.text = CurrentImageDescription
                IDLabel.text = CurrentImageID
            } else {
                print("There is no photographer, description or id.")
            }
        } catch{
            //If no old image and data were found request a new image.
            setNewPhoto(like: false)
        }
        
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


