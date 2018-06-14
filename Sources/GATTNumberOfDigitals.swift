//
//  GATTNumberOfDigitals.swift
//  Bluetooth
//
//  Created by Carlos Duclos on 6/14/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

// MARK: - Number of Digitals
/// GATT Number of Digitals Descriptor
///
/// The Characteristic Number of Digitals descriptor is used for defining the number of digitals in a characteristic.
public struct GATTNumberOfDigitals: GATTDescriptor, RawRepresentable {
    
    public static let uuid: BluetoothUUID = .numberOfDigitals
    
    public static let length = 1
    
    public var rawValue: UInt8
    
    public init(rawValue: UInt8) {
        
        self.rawValue = rawValue
    }
    
    public init?(byteValue: Data) {
        
        guard byteValue.count == type(of: self).length
            else { return nil }
        
        rawValue = byteValue[0]
    }
    
    public var byteValue: Data {
        
        return Data([rawValue])
    }
    
    public var descriptor: GATT.Descriptor {
        
        return GATT.Descriptor(uuid: type(of: self).uuid,
                               value: byteValue,
                               permissions: [.read])
    }
}

extension GATTNumberOfDigitals: Equatable {
    
    public static func == (lhs: GATTNumberOfDigitals,
                           rhs: GATTNumberOfDigitals) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

extension GATTNumberOfDigitals: CustomStringConvertible {
    
    public var description: String {
        
        return rawValue.description
    }
}

extension GATTNumberOfDigitals: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        
        self.init(rawValue: value)
    }
}
