import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var albomButton: UIBarButtonItem!
    @IBOutlet weak var imagePicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBAction func onShareButton(sender: AnyObject) {
        
        let memeObject = self.generateMemedImage()
        let activity = UIActivityViewController(activityItems:[memeObject], applicationActivities: nil)
        self.presentViewController(activity , animated: true, completion: nil)
        activity.completionWithItemsHandler = complitionHandler
        
    }
    func complitionHandler(activity: String?, success: Bool,items: [AnyObject]?, error: NSError?) {
            print("complitionHandler result: " + String(success))
        if success {
            save()
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
        
        topText.text    = "TOP"
        bottomText.text = "BOTTOM"
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
        self.presentViewController(pickerController, animated: true, completion:nil)
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]){
            print("imagePickerController")
            
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imagePicker.image = image
                print("update")
            }
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
            print("imagePickerControllerDidCancel")
            self.dismissViewControllerAnimated(true, completion: nil)
        
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
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
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
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // Unsubscribe
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    func generateMemedImage() -> UIImage
    {
        //Hide extra UI
        self.toolBar.hidden = true
        self.navBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show hidden UI
        self.toolBar.hidden = false
        self.navBar.hidden = false
        
        return memedImage
    }
    
    func save() {
        //Create the meme
        var gImage: UIImage
        gImage = self.generateMemedImage()
        
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originImage: imagePicker.image!, memeImage: gImage)
        
        // Add it to the memes array in the Application Delegate
        (UIApplication.sharedApplication().delegate as!
            AppDelegate).memes.append(meme)
        print("memes: " + String((UIApplication.sharedApplication().delegate as!AppDelegate).memes))
            
    }
}