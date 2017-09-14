//
//  TMlocalContact.swift
//  consumer
//
//  Created by Vlad Z on 8/19/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Contacts

// MARK: - Parsing local data logic
extension CNContact {
    
    func transferToJSON() -> [String: Any] {
        
        var inputDictionary = [String: Any]()
        
        let config = TMConsumerConfig.shared
        inputDictionary["user_id"] = config.currentUser!.id
        
        inputDictionary["first_name"] = givenName
        inputDictionary["last_name"] = familyName
        inputDictionary["job_title"] = jobTitle
        inputDictionary["organization_name"] = organizationName
        
        inputDictionary["address_book_id"] = identifier
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        
        if
            let birthday = birthday,
            let birthdayDate = Calendar.current.date(from: birthday) {
            inputDictionary["birthday"] = dateFormatter.string(from: birthdayDate) + "Z"
        }
        
        let addresses = postalAddresses
        inputDictionary["addresses"] = CNContact.parseAddressesToJSON(addresses, name: "\(givenName) \(familyName)")

        
        inputDictionary["phone_numbers"] = CNContact.parsePhonesToJSON(phoneNumbers)
        
        inputDictionary["email_addresses"] = CNContact.parseEmailsToJSON(emailAddresses)
        
        inputDictionary["social_profiles"] = CNContact.parseProfilesToJSON(socialProfiles)
        
        return inputDictionary
    }
    
    // parsing social profiles array into JSON data structure
    class func parseProfilesToJSON(_ socialProfiles: [CNLabeledValue<CNSocialProfile>]?)-> [[String: Any]] {
        
        var resultArray = [[String: Any]]()
        
        guard let _socialProfiles = socialProfiles else {
            
            return resultArray
        }
        
        for socialProfile in _socialProfiles {
            
            var socialPropertiesDictionary = [String: String]()
            
            
            socialPropertiesDictionary["service"] = socialProfile.value.service
            
            socialPropertiesDictionary["username"] = socialProfile.value.username

            socialPropertiesDictionary["url_string"] = socialProfile.value.urlString

            socialPropertiesDictionary["user_identifier"] = socialProfile.value.userIdentifier
            
            if socialPropertiesDictionary.count > 0 {
                resultArray.append(socialPropertiesDictionary)
            }
        }
        
        return resultArray
    }
    
    // parsing phones array into JSON data structure
    class func parsePhonesToJSON(_ phones: [CNLabeledValue<CNPhoneNumber>]?)-> [[String: Any]] {
        
        var resultArray = [[String: Any]]()
        
        guard let _phones = phones else {
            
            return resultArray
        }
        
        for phone in _phones {
            
            var phoneDictionary = [String: String]()
            
            let number = phone.value.stringValue
            
            do {
                
                let phoneNumberKit = PhoneNumberKit()
                
                let numberPhone = try phoneNumberKit.parse(number, withRegion: "US")
                
                let formattedPhone = phoneNumberKit.format(numberPhone, toType: .e164)
                
                phoneDictionary["phone_number"] = formattedPhone
            } catch { }
        
            phoneDictionary["label"] = cleanLabel(phone.label)
            
            if phoneDictionary.count > 0 {
                resultArray.append(phoneDictionary)
            }
        }
        
        return resultArray
    }
    
    // parsing emails array into JSON data structure
    class func parseEmailsToJSON(_ emails: [CNLabeledValue<NSString>]?)-> [[String: Any]] {
        
        var resultArray = [[String: Any]]()
        
        guard let _emails = emails else {
            
            return resultArray
        }
        
        for email in _emails {
            
            var emailDictionary = [String: String]()
            
            if TMInputValidation.isValidEmail(email.value as String) {
                emailDictionary["email_address"] = email.value as String
            }
            
            if let label = email.label {
                if label.length > 0 {
                    emailDictionary["label"] = self.cleanLabel(label)
                }
            }
            
            if emailDictionary.count > 0 {
                resultArray.append(emailDictionary)
            }
        }
        
        return resultArray
    }
    
    // parsing addresses array into JSON data structure
    class func parseAddressesToJSON(_ addresses: [CNLabeledValue<CNPostalAddress>]?, name: String?)-> [[String: Any]] {
        
        var resultArray = [[String: Any]]()
        
        guard let _addresses = addresses else {
            
            return resultArray
        }
        
        for address in _addresses {
            
            var addressDictionary = [String: String]()
            
            // checking for nil, before adding to array (JSON method does not support nils)
            let street = address.value.street
                
            let delimiter = "\n"
            let arrayOfStreets = street.components(separatedBy: delimiter)
            
            if let str1 = arrayOfStreets.first {
                
                addressDictionary["street1"] = str1
            }
            
            if arrayOfStreets.count > 1 {
                let str2 = arrayOfStreets[1]
                addressDictionary["street2"] = str2
            }
            
            addressDictionary["city"] = address.value.city

            addressDictionary["state"] = address.value.state
            
            addressDictionary["zip"] = address.value.postalCode
            
            addressDictionary["country"] = address.value.isoCountryCode.uppercased()

            addressDictionary["label"] = self.cleanLabel(address.label)

            
            if let name = name {
                
                addressDictionary["name"] = name
            }
            
            // checking if array.count > 0
            if addressDictionary.count > 0 {
                resultArray.append(addressDictionary)
            }
        }
        
        return resultArray
    }
    
    class func cleanLabel(_ string: String?)-> String {
        
        guard let string = string else { return "" }
        
        var resultString = string
        
        resultString = resultString.replacingOccurrences(of: "_$!<", with: "")
        resultString = resultString.replacingOccurrences(of: ">!$_", with: "")
        
        return resultString
    }
}
