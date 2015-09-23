import Foundation
import UIKit


class Meme{
    var topText:     String!
    var bottomText:  String!
    var originImage: UIImage!
    var memeImage:   UIImage!
    init(tText: String, bText: String, oImage: UIImage, mImage: UIImage ) {
       
        topText     = tText
        bottomText  = bText
        originImage = oImage
        memeImage   = mImage
    }
    
}
