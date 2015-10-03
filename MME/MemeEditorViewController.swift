import UIKit

class MemeEditorViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var imagePicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
    var memeIndex: Int = -1
    
    var memes: [Meme]! {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    @IBAction func onCancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onShareButton(sender: AnyObject) {
        
        let memeObject = generateMemedImage()
        let activity = UIActivityViewController(activityItems:[memeObject], applicationActivities: nil)
        presentViewController(activity , animated: true, completion: nil)
        activity.completionWithItemsHandler = complitionHandler
        
    }
    func complitionHandler(activity: String?, success: Bool,items: [AnyObject]?, error: NSError?) {
        print("complitionHandler result: " + String(success))
        if success {
            save()
            dismissViewControllerAnimated(true, completion: nil)
            navigationController?.navigationBarHidden = false;
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 35)!,
        NSStrokeWidthAttributeName : -3.0,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        print("Inex: " + String(memeIndex))
        
        if memeIndex == -1 {
            topText.text    = "TOP"
            bottomText.text = "BOTTOM"
        }else{
            topText.text      = memes[memeIndex].topText
            bottomText.text   = memes[memeIndex].bottomText
            imagePicker.image = memes[memeIndex].originImage
        }
        
        topText.delegate = self
        bottomText.delegate = self
        
        setTextAttributes(topText)
        setTextAttributes(bottomText)
        
    }
    
    func setTextAttributes(textFeild: UITextField){
        textFeild.defaultTextAttributes = memeTextAttributes
        textFeild.adjustsFontSizeToFitWidth = true
        textFeild.textAlignment = .Center
        textFeild.autocapitalizationType = .AllCharacters
    }


    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
    
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(pickerController, animated: true, completion:nil)
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]){
            print("imagePickerController")
            
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imagePicker.image = image
                print("update")
            }
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
            print("imagePickerControllerDidCancel")
            dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func textFieldDidBeginEditing(textFeild: UITextField){
        
        if textFeild.text == "TOP" || textFeild.text == "BOTTOM"{
            textFeild.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        print("pickAnImageFromCamera")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if (bottomText.isFirstResponder()){
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // Unsubscribe
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func generateMemedImage() -> UIImage
    {
        //Hide extra UI
        toolBar.hidden = true
        navBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame,
            afterScreenUpdates: true)
        
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Secial case for empty image
        //Saving just background
        if imagePicker.image == nil {
            topText.hidden = true
            bottomText.hidden = true
            
            UIGraphicsBeginImageContext(view.frame.size)
            view.drawViewHierarchyInRect(view.frame,
                afterScreenUpdates: true)
            
            let oImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            topText.hidden = false
            bottomText.hidden = false
            imagePicker.image = oImage
        }
        // Show hidden UI
        toolBar.hidden = false
        navBar.hidden = false
        
        return memedImage
    }
    
    func save() {
        //Create the meme
        var gImage: UIImage
        gImage = generateMemedImage()
        
        let oImage: UIImage = imagePicker.image!
        
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originImage: oImage, memeImage: gImage)
        
        if memeIndex != -1 {
            (UIApplication.sharedApplication().delegate as!
                AppDelegate).memes.insert(meme, atIndex: memeIndex)
            (UIApplication.sharedApplication().delegate as!
                AppDelegate).memes.removeAtIndex(memeIndex + 1)
        }else{
            (UIApplication.sharedApplication().delegate as!
                AppDelegate).memes.append(meme)
        }
        print("memes: " + String((UIApplication.sharedApplication().delegate as!AppDelegate).memes))
    }
}