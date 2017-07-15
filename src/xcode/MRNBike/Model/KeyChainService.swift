import Foundation
import Security

// Constant Identifiers
let userAccount = "AuthenticatedUser"
let accessGroup = "SecuritySerivice"


/**
 *  User defined keys for new entry
 *  Note: add new keys for new secure item and use them in load and save methods
 */

let emailKey = "KeyForEmail"
let passwordKey = "KeyForPassword"
let routeKey = "KeyForRouteIDs"
let rememberMeKey = "no"


// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

public class KeychainService: NSObject {
    
    /**
     * Exposed methods to perform save and load queries.
     */
    
    //EMail
    public class func saveEmail(token: NSString) {
        self.save(service: emailKey as NSString, data: token)
    }
    
    public class func loadEmail() -> NSString? {
        return self.load(service: emailKey as NSString)
    }
    
    //Password
    public class func savePassword(token: NSString) {
        self.save(service: passwordKey as NSString, data: token)
    }
    
    public class func loadPassword() -> NSString? {
        return self.load(service: passwordKey as NSString)
    }

    //RememberMe
    public class func saveRemember(token: NSString) {
        self.save(service: rememberMeKey as NSString, data: token)
    }
    
    public class func loadRemember() -> NSString? {
        return self.load(service: rememberMeKey as NSString)
    }
    
    //IDs
    public class func saveIDs(IDs: [Int]) {
        let IDsAsString = IDs.map{ String($0) }.joined(separator: ",") as NSString

        self.save(service: routeKey as NSString, data: IDsAsString)
    }
    
    public class func loadIDs() -> [Int]? {
        let arrString = self.load(service: routeKey as NSString) as String?
        
        return arrString?.components(separatedBy: ",").map{ return Int($0) } as? [Int]
    }
    
    /**
     * Internal methods for querying the keychain.
     */
    
    private class func delete(service: NSString) {
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        // Delete any existing items
        let status = SecItemDelete(keychainQuery as CFDictionary)
        if (status != errSecSuccess) {
            print("Delete failed")
        }
        
    }
    
    private class func save(service: NSString, data: NSString) {
        let dataFromString: NSData = data.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)! as NSData
        
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
        
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)
        
        // Add the new keychain item
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    private class func load(service: NSString) -> NSString? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var dataTypeRef :AnyObject?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: NSString? = nil
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? NSData {
                contentsOfKeychain = NSString(data: retrievedData as Data, encoding: String.Encoding.utf8.rawValue)
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
}
