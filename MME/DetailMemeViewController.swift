import UIKit

class DetailMemeViewController: UIViewController {
    
    @IBOutlet weak var memeImageView: UIImageView!
    
    var memeIndex: Int!
    var memes: [Meme]! {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    @IBOutlet weak var onEdit: UIBarButtonItem!
    
    @IBAction func onEdit(sender: AnyObject) {
        print("Edit")
        
        let editController = storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
//        print("Inex -> : " + String(memeIndex))
        editController.memeIndex = memeIndex
        navigationController!.navigationBarHidden = true;
        navigationController!.pushViewController(editController, animated: true)
        
    }
    
    @IBAction func onDelete(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Deleting meme",
                                    message: "Are you sure?",
                             preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { action in
            print("Meme was deleted")
            (UIApplication.sharedApplication().delegate as!
                AppDelegate).memes.removeAtIndex( self.memeIndex)
            self.navigationController?.popViewControllerAnimated(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
            print("Meme was not deleted")
        }))
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        memeImageView!.image = memes[memeIndex].memeImage
    }
}