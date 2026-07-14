import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    private static var isShown = false
    static var isShowing: Bool { isShown }
    
    static func show() {
        isShown = true
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        isShown = false
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
