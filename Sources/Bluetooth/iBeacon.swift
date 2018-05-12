//
//  iBeacon.swift
//  Bluetooth
//
//  Created by Alsey Coleman Miller on 1/2/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

import Foundation

// swiftlint:disable type_name
/// Describes an iBeacon to be advertised.
public struct iBeacon {
// swiftlint:enable type_name
    
    /// The unique ID of the beacons being targeted.
    public var uuid: Foundation.UUID
    
    /// The value identifying a group of beacons.
    public var major: UInt16
    
    /// The value identifying a specific beacon within a group.
    public var minor: UInt16
    
    /// The received signal strength indicator (RSSI) value (measured in decibels) for the device.
    public var rssi: RSSI
    
    /// The advertising interval.
    public var interval: UInt16
    
    public init(uuid: Foundation.UUID,
                major: UInt16 = 0,
                minor: UInt16 = 0,
                rssi: RSSI,
                interval: UInt16 = 200) {
        
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.rssi = rssi
        self.interval = interval
    }
}

public extension iBeacon {
    
    var advertisingDataCommand: LowEnergyCommand.SetAdvertisingDataParameter {
        
        var dataParameter = LowEnergyCommand.SetAdvertisingDataParameter()
        
        dataParameter.data.length = 30
        
        dataParameter.data.bytes.0 = 0x02  // length of flags
        dataParameter.data.bytes.1 = 0x01  // flags type
        dataParameter.data.bytes.2 = 0x1a  // Flags: 000011010
        dataParameter.data.bytes.3 = 0x1a  // length
        dataParameter.data.bytes.4 = 0xff  // vendor specific
        dataParameter.data.bytes.5 = 0x4c  // Apple, Inc
        dataParameter.data.bytes.6 = 0x00  // Apple, Inc
        dataParameter.data.bytes.7 = 0x02  // iBeacon
        dataParameter.data.bytes.8 = 0x15  // length: 21 = 16 byte UUID + 2 bytes major + 2 bytes minor + 1 byte RSSI
        
        // set UUID bytes
        
        let uuidBytes = BluetoothUUID(uuid: uuid).bigEndian.data
        
        dataParameter.data.bytes.9 = uuidBytes[0]
        dataParameter.data.bytes.10 = uuidBytes[1]
        dataParameter.data.bytes.11 = uuidBytes[2]
        dataParameter.data.bytes.12 = uuidBytes[3]
        dataParameter.data.bytes.13 = uuidBytes[4]
        dataParameter.data.bytes.14 = uuidBytes[5]
        dataParameter.data.bytes.15 = uuidBytes[6]
        dataParameter.data.bytes.16 = uuidBytes[7]
        dataParameter.data.bytes.17 = uuidBytes[8]
        dataParameter.data.bytes.18 = uuidBytes[9]
        dataParameter.data.bytes.19 = uuidBytes[10]
        dataParameter.data.bytes.20 = uuidBytes[11]
        dataParameter.data.bytes.21 = uuidBytes[12]
        dataParameter.data.bytes.22 = uuidBytes[13]
        dataParameter.data.bytes.23 = uuidBytes[14]
        dataParameter.data.bytes.24 = uuidBytes[15]
        
        let majorBytes = major.bigEndian.bytes
        
        dataParameter.data.bytes.25 = majorBytes.0
        dataParameter.data.bytes.26 = majorBytes.1
        
        let minorBytes = minor.bigEndian.bytes
        
        dataParameter.data.bytes.27 = minorBytes.0
        dataParameter.data.bytes.28 = minorBytes.1
        
        dataParameter.data.bytes.29 = UInt8(bitPattern: rssi.rawValue)
        
        return dataParameter
    }
}

public extension BluetoothHostControllerInterface {
    
    /// Enable iBeacon functionality.
    func iBeacon(_ iBeacon: iBeacon,
                 timeout: HCICommandTimeout = .default) throws {
        
        // set advertising parameters
        let advertisingParameters = LowEnergyCommand.SetAdvertisingParametersParameter(interval: (iBeacon.interval, iBeacon.interval))
                
        try deviceRequest(advertisingParameters, timeout: timeout)
        
        // start advertising
        do { try enableLowEnergyAdvertising(timeout: timeout) }
        catch HCIError.commandDisallowed { /* ignore, means already turned on */ }
        
        // set iBeacon data
        let advertisingDataCommand = iBeacon.advertisingDataCommand
        
        try deviceRequest(advertisingDataCommand, timeout: timeout)
    }
}
