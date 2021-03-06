//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Sónia Rosa on 16/04/15.
//  Copyright (c) 2015 Sónia Rosa. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Properties
    var thisFeedItem: FeedItem!
    
    var collectionView: UICollectionView!
    
    let kIntensity = 0.7
    
    var context: CIContext = CIContext(options: nil)
    
    var filters: [CIFilter] = []
    
    let placeHolderImage = UIImage(named: "Placeholder")
    
    let tmp = NSTemporaryDirectory()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                
        var layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        
        self.view.addSubview(collectionView)
        
        filters = photoFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCell
        
        //if cell.imageView.image == nil {
            
        cell.imageView.image = placeHolderImage
        
        let filterQueue: dispatch_queue_t = dispatch_queue_create("filter.queue", nil)
        
        dispatch_async(filterQueue, { () -> Void in
            
//                let filterImage = self.filteredImageFromImage(self.thisFeedItem.thumbNail, filter: self.filters[indexPath.row])
            
            let filterImage = self.getCacheImage(indexPath.row)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                cell.imageView.image = filterImage
            })
        })
    
            // cell.imageView.image = filteredImageFromImage(thisFeedItem.image, filter: filters[indexPath.row])
        //}
         return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        creatUIAlertController(indexPath)
        
    }
    
    // MARK: - Helper Functions
    
    func photoFilters () -> [CIFilter] {
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
        
    }
    
    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        
        let filteredImage: CIImage  = filter.outputImage
        
        let extent = filteredImage.extent()
        let cgImage: CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
        let finalImage = UIImage(CGImage: cgImage)
        
        //let finalImage = UIImage(CIImage: filteredImage)
        
        return finalImage!
    }
    
    // MARK: - UIAlertController - Helper Functions
    
    func creatUIAlertController(indexPath: NSIndexPath) {
        
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            
            textField.placeholder = "Add Caption!"
            textField.secureTextEntry = false
        }
        
        
        let textField = alert.textFields![0] as UITextField
        
        
        let photoAction = UIAlertAction(title: "Post Photo to Facebook with Caption", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            
            self.sharedToFacebook(indexPath)
            
            var text = textField.text
            
            self.saveFilterToCoreData(indexPath, caption: text)
            
        }
        
        alert.addAction(photoAction)
        
        let saveFilterAction = UIAlertAction(title: "Save Filter without posting on Facebook", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            
            var text = textField.text

            
            self.saveFilterToCoreData(indexPath, caption: text)

        }
        
        alert.addAction(saveFilterAction)
        
        let cancelAction = UIAlertAction(title: "Select another Filter", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
            
        }
        
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveFilterToCoreData(indexPath: NSIndexPath, caption: String) {
        
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        self.thisFeedItem.image = imageData
        
        let thumbNailData = UIImageJPEGRepresentation(filterImage, 0.1)
        self.thisFeedItem.image = thumbNailData
        
        thisFeedItem.caption = caption
        thisFeedItem.filtered = true
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func sharedToFacebook(indexPath: NSIndexPath) {
        
        let filterImage = filteredImageFromImage(thisFeedItem.image, filter: filters[indexPath.row])
        
        let photos: NSArray = [filterImage]
        var params = FBPhotoParams()
        params.photos = photos
        
        FBDialogs.presentMessageDialogWithPhotoParams(params, clientState: nil) { (call, result, error) -> Void in
            
            if result? != nil {
                
                println(result)
            }
            else {
                
                println(error)
            }
        }
        
    }
    
    // MARK: - Caching Functions
    
    func cacheImage(imageNumber: Int) {
        
        //let fileName = "\(imageNumber)\(thisFeedItem.image.length)"
        let fileName = "\(thisFeedItem.uniqueID)\(imageNumber)"
        let uniqPath = tmp.stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fileName) {
            
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniqPath, atomically: true)
        }
    }
    
    func getCacheImage(imageNumber: Int) -> UIImage {
        
        //let fileName = "\(imageNumber)\(thisFeedItem.image.length)"
        let fileName = "\(thisFeedItem.uniqueID)\(imageNumber)"
        let uniqPath = tmp.stringByAppendingPathComponent(fileName)
        var image: UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniqPath) {
            
            var returnImage = UIImage(contentsOfFile: uniqPath)!
            image = UIImage(CGImage: returnImage.CGImage, scale: 1.0, orientation: .Up)!
        }
        else {
            self.cacheImage(imageNumber)
            var returnImage = UIImage(contentsOfFile: uniqPath)!
            image = UIImage(CGImage: returnImage.CGImage, scale: 1.0, orientation: .Up)!
        }
        return image
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
