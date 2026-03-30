import Foundation
import AuthenticationServices

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#else
#error("Unsupported platform.")
#endif

@available(iOS 13.0, *)
extension FlutterError: Error {
    convenience init(from error: ASAuthorizationError) {
        var code = ""
        switch (error.code) {
        case ASAuthorizationError.unknown:
            code = "unknown"
            break
        case ASAuthorizationError.canceled:
            //            if (error.localizedDescription.contains("No credentials available for login.")) {
            //                code = "no-credentials-available"
            //            } else {
            //                code = "cancelled"
            //            }
            //            break
            let nsError = error as NSError
            
            
            
            let reason = nsError.userInfo[NSLocalizedFailureReasonErrorKey] as? String
            // Log để debug (rất quan trọng)
            print("---Authorization ERROR---")
            print("reason:", reason ?? "nil")
            print("domain:", nsError.domain)
            print("code:", nsError.code)
            print("localizedDescription:", nsError.localizedDescription)
            print("failureReason:", nsError.userInfo[NSLocalizedFailureReasonErrorKey] ?? "nil")
            print("userInfo:", nsError.userInfo)
            print("---Authorization ERROR END---")
            // 👉 iOS không phân biệt rõ cancel vs no credential
            // nên phải infer dựa vào context
            
            if let reason = nsError.userInfo[NSLocalizedFailureReasonErrorKey] as? String,
               reason.lowercased().contains("credential") {
                code = "no-credentials-available"
            } else {
                code = "cancelled"
            }
            break
        case ASAuthorizationError.invalidResponse:
            code = "invalidResponse"
            break
        case ASAuthorizationError.notHandled:
            code = "notHandled"
            break
        case ASAuthorizationError.failed:
            if (error.localizedDescription.contains("is not associated with domain")) {
                code = "domain-not-associated"
            } else {
                code = "failed"
            }
            break
        default:
            code = "unknown"
            break
        }
        
        self.init(code: code, message: error.localizedDescription, details: "")
    }
    
    convenience init(fromNSError error: NSError) {
        var code = ""
        if (error.domain == "WKErrorDomain" && error.code == 8) {
            code = "exclude-credentials-match"
        }else if(error.domain == "WKErrorDomain" && error.code == 31){
            // This error happens when the security key prompt times out (2 minutes)
            code = "ios-security-key-timeout"
        } else {
            code = "ios-unhandled-" + error.domain
        }
 
        self.init(code: code, message: error.localizedDescription, details: "")
    }

    convenience init(code: CustomErrors, message: String = "") {
        self.init(code: String(describing: code), message: message, details: "")
    }
}

enum CustomErrors: Error {
    case deviceNotSupported
    case decodingChallenge
    case unexpectedAuthorizationResponse
    case unknown
}
