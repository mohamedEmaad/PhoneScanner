
import UIKit

class ActionsViewController: UIViewController {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    private let phoneNumber: String

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, phoneNumber: String) {
        self.phoneNumber = phoneNumber
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setPhoneNumber()
    }

    private func setPhoneNumber() {
        self.phoneNumberLabel.text = self.phoneNumber
    }

    @IBAction private func callAction(_ sender: Any) {
         if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    application.openURL(phoneCallURL as URL)
                }
            }
        }
    }

    @IBAction private func shareAction(_ sender: UIButton) {
        let size = self.view.frame.size
        UIGraphicsBeginImageContext(size)
        self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        UIGraphicsEndImageContext()
        let objectsToShare = ["", self.phoneNumber] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo
        ]
        activityVC.popoverPresentationController?.sourceView = sender
        self.present(activityVC, animated: true, completion: nil)
    }

    @IBAction private func rescanAction(_ sender: Any) {
        print("here in the rescan")
        self.navigationController?.popViewController(animated: true)
    }
}
