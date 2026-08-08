import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    
    private static var window: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
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
