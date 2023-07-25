//
//  AppConfiguration.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 7/5/23.
//

import UIKit

/// Main interface class that supplies the different configuration values
/// stored in the Info.plist to the application. NOTE: The values for the
/// keys provided are stored in the AppName.xcconfig file for the app.
/// Do not edit these values directly or what's contained in the Info.plist.
@objc @objcMembers class AppConfiguration: NSObject {
    // MARK: - App Information
    
    // See the xcconfig file for color definitions.
    class var accountCode: String {
        do {
            return try DMGConfiguration.value(for: "ACCOUNT_CODE")
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    // See the xcconfig file for color definitions.
    class var supportEmail: String {
        do {
            return try DMGConfiguration.value(for: "SUPPORT_EMAIL")
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    // See the xcconfig file for color definitions.
    class var appNameShort: String {
        do {
            return try DMGConfiguration.value(for: "APP_NAME_SHORT")
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    // See the xcconfig file for color definitions.
    class var appNameLong: String {
        do {
            return try DMGConfiguration.value(for: "APP_NAME_LONG")
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    // See the xcconfig file for color definitions.
    class var enableMyMoves: Bool {
        do {
            let value = try DMGConfiguration.value(for: "DMG_MYMOVES_ENABLED") as String
            return (value as NSString).boolValue
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Color Information
    
    // See the xcconfig file for color definitions.
    class var loginViewTextColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_LOGINVIEW_TEXTCOLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // See the xcconfig file for color definitions.
    class var backgroundColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_BACKGROUND_COLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // See the xcconfig file for color definitions.
    class var homeIconForegroundColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_HOME_ICON_FOREGROUND_COLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    // See the xcconfig file for color definitions.
    class var menuIconColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_MENU_ICON_COLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // See the xcconfig file for color definitions.
    class var headerColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_HEADER_COLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    // See the xcconfig file for color definitions.
    class var headerTextColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_HEADER_TEXTCOLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }

    // See the xcconfig file for color definitions.
    class var buttonColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_BUTTON_COLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    // See the xcconfig file for color definitions.
    class var buttonTextColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_BUTTON_TEXTCOLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // See the xcconfig file for color definitions.
    class var switchOnColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_SWITCH_ON_COLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // See the xcconfig file for color definitions.
    class var footerColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_FOOTER_COLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    // See the xcconfig file for color definitions.
    class var footerTextColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_FOOTER_TEXTCOLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }

    // See the xcconfig file for color definitions.
    class var chartColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_CHART_COLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    // See the xcconfig file for color definitions.
    class var chartPointColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_CHART_POINT_COLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // See the xcconfig file for color definitions.
    class var calendarMoveDayColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_CALENDAR_MOVEDAY_COLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }

    // See the xcconfig file for color definitions.
    class var chatSenderColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_CHAT_SENDER_COLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    // See the xcconfig file for color definitions.
    class var chatSenderTextColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_CHAT_SENDER_TEXTCOLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    // See the xcconfig file for color definitions.
    class var chatRecipientColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_CHAT_RECIPIENT_COLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    // See the xcconfig file for color definitions.
    class var chatRecipientTextColor: UIColor {
        do {
            let colorHex = try DMGConfiguration.value(for: "DMG_CHAT_RECIPIENT_TEXTCOLOR") as String
            return UIColorFromHexString(colorHex)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Images
    
    // See the xcconfig file for color definitions.
    class var loginBackgroundImage: UIImage? {
        do {
            let imageName = try DMGConfiguration.value(for: "DMG_LOGIN_BACKGROUND_IMAGE") as String
            return UIImage(named: imageName)
        } catch {
            if let error = error as? ConfigError {
                fatalError(error.description)
            } else {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    /// Function that iterates through all of the possible values and
    /// ensures they are set. If you add a new value to the Info.plist,
    /// ensure it's set here as a test.
    public class func validateConfiguration() {
        assert(self.accountCode.count > 0, "Account Code is not set!")
        debugPrint("accountCode: \(self.accountCode)")
        assert(self.supportEmail.count > 0, "Support Email is not set!")
        debugPrint("supportEmail: \(self.supportEmail)")
        assert(self.appNameShort.count > 0, "App Name Short is not set!")
        debugPrint("appNameShort: \(self.appNameShort)")
        assert(self.appNameLong.count > 0, "App Name Long is not set!")
        debugPrint("appNameLong: \(self.appNameLong)")
        debugPrint("enableMyMoves: \(self.enableMyMoves == true ? "YES" : "NO")")

        assert(self.backgroundColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("backgroundColor: \(self.backgroundColor.hexString())")

        assert(self.homeIconForegroundColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("homeIconForegroundColor: \(self.homeIconForegroundColor.hexString())")
        assert(self.menuIconColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("menuIconColor: \(self.menuIconColor.hexString())")

        assert(self.headerColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("headerColor: \(self.headerColor.hexString())")
        assert(self.headerTextColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("headerTextColor: \(self.headerTextColor.hexString())")

        assert(self.buttonColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("buttonColor: \(self.buttonColor.hexString())")
        assert(self.buttonTextColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("buttonTextColor: \(self.buttonTextColor.hexString())")

        assert(self.switchOnColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("switchOnColor: \(self.switchOnColor.hexString())")

        assert(self.footerColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("footerColor: \(self.footerColor.hexString())")
        assert(self.footerTextColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("footerTextColor: \(self.footerTextColor.hexString())")

        assert(self.chartColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("chartColor: \(self.chartColor.hexString())")
        assert(self.chartPointColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("chartPointColor: \(self.chartPointColor.hexString())")

        assert(self.calendarMoveDayColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("calendarMoveDayColor: \(self.calendarMoveDayColor.hexString())")

        assert(self.chatSenderColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("chatSenderColor: \(self.chatSenderColor.hexString())")
        assert(self.chatSenderTextColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("chatSenderTextColor: \(self.chatSenderTextColor.hexString())")
        assert(self.chatRecipientColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("chatRecipientColor: \(self.chatRecipientColor.hexString())")
        assert(self.chatRecipientTextColor.isKind(of: UIColor.self), "Color is not a color!")
        debugPrint("chatRecipientTextColor: \(self.chatRecipientTextColor.hexString())")

        assert(self.loginBackgroundImage != nil, "Image must be present!")
        debugPrint("loginBackgroundImage: \(String(describing: self.loginBackgroundImage))")
    }
}

/// An enum that handles fetching from the bundle or throwing an error.
private enum ConfigError: Swift.Error {
    case missingKey
    case invalidValue
}
private enum DMGConfiguration {
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw ConfigError.missingKey
        }

        switch object {
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw ConfigError.invalidValue
        }
    }
}

/// Error messages.
extension ConfigError: CustomStringConvertible {
   var description: String {
      switch self {
         case .missingKey:
            return "The key requested is missing!"
         case .invalidValue:
            return "The value is invalid!"
      }
   }
}

extension UIColor {
    /// Returns a hex string of the color.
    func hexString() -> String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
     }
}
