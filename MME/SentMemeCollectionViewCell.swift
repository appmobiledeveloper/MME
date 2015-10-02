import UIKit

class SentMemeCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textTop: UITextField!
    @IBOutlet weak var textBottom: UITextField!
    @IBOutlet weak var cellImageView: UIImageView!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 15)!,
        NSStrokeWidthAttributeName : -3.0,
    ]
    
    func prepareCell() {
        
        setTextAttributes(textTop)
        setTextAttributes(textBottom)
        
    }
    
    func setTextAttributes(textFeild: UITextField){
        textFeild.defaultTextAttributes = memeTextAttributes
        textFeild.adjustsFontSizeToFitWidth = true
        textFeild.textAlignment = .Center
        textFeild.autocapitalizationType = .AllCharacters
    }
    
}
