//
//  GATTObjectSize.swift
//  Bluetooth
//
//  Created by Carlos Duclos on 7/11/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation

/**
 Object Size
 
 - SeeAlso: [Object Size](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.object_size.xml)
 */
public struct GATTObjectSize: GATTCharacteristic {
    
    internal static let length = MemoryLayout<UInt16>.size * 2
    
    public static var uuid: BluetoothUUID { return .objectSize }
    
    public var currentSize: Size
    
    public var allocatedSize: Size
    
    public init(currentSize: Size, allocatedSize: Size) {
        
        self.currentSize = currentSize
        self.allocatedSize = allocatedSize
    }
    
    public init?(data: Data) {
        
        guard data.count == type(of: self).length
            else { return nil }
        
        guard let currentSize = Size(rawValue: UInt32(littleEndian: UInt32(bytes: (data[0], data[1], data[2], data[3]))))
            else { return nil }
        
        guard let allocatedSize = Size(rawValue: UInt32(littleEndian: UInt32(bytes: (data[0], data[1], data[2], data[3]))))
            else { return nil }
        
        self.init(currentSize: currentSize, allocatedSize: allocatedSize)
    }
    
    public var data: Data {
        
        let currentSizeBytes = currentSize.rawValue.littleEndian.bytes
        let allocatedSizeBytes = allocatedSize.rawValue.littleEndian.bytes
        
        return Data([currentSizeBytes.0, currentSizeBytes.1, allocatedSizeBytes.0, allocatedSizeBytes.1])
    }
}

extension GATTObjectSize {
    
    public struct Size: RawRepresentable {
        
        public var rawValue: UInt32
        
        public init?(rawValue: UInt32) {
            
            self.rawValue = rawValue
        }
    }
}
