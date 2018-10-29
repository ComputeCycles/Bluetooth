//
//  ATTFindInformationResponse.swift
//  Bluetooth
//
//  Created by Alsey Coleman Miller on 6/13/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation

/// Find Information Response
///
/// The *Find Information Response* is sent in reply to a received *Find Information Request*
/// and contains information about this server.
public struct ATTFindInformationResponse: ATTProtocolDataUnit, Equatable {
    
    public static let attributeOpcode = ATTOpcode.findInformationResponse
    
    /// Length ranges from 6, to the maximum MTU size.
    internal static let length = 6
    
    /// The information data whose format is determined by the Format field.
    public var attributeData: AttributeData
    
    public init(attributeData: AttributeData) {
        
        self.attributeData = attributeData
    }
    
    public init?(data: Data) {
        
        guard data.count >= type(of: self).length
            else { return nil }
        
        let attributeOpcodeByte = data[0]
        let formatByte = data[1]
        let remainderData = data.subdataNoCopy(in: 2 ..< data.count)
        
        guard attributeOpcodeByte == type(of: self).attributeOpcode.rawValue,
            let format = Format(rawValue: formatByte),
            let attributeData = AttributeData(data: remainderData, format: format)
            else { return nil }
        
        self.attributeData = attributeData
    }
    
    public var data: Data {
        
        // first 2 bytes are opcode and format
        return Data([type(of: self).attributeOpcode.rawValue, attributeData.format.rawValue]) + attributeData.data
    }
}

// MARK: - Supporting Types

public extension ATTFindInformationResponse {

    public enum Format: UInt8 {
        
        /// A list of 1 or more handles with their 16-bit Bluetooth UUIDs.
        case bit16      = 0x01
        
        /// A list of 1 or more handles with their 128-bit UUIDs.
        case bit128     = 0x02
        
        public init?(uuid: BluetoothUUID) {
            
            switch uuid {
            case .bit16: self = .bit16
            case .bit32: return nil
            case .bit128: self = .bit128
            }
        }
        
        internal var length: Int {
            
            switch self {
            case .bit16: return 2 + 2
            case .bit128: return 2 + 16
            }
        }
    }
}

public extension ATTFindInformationResponse {
    
    /// 16 Bit Attribute
    public struct Attribute16Bit: Equatable {
        
        internal static var format: Format { return .bit16 }
        
        /// Attribute Handle
        public let handle: UInt16
        
        /// Attribute UUID
        public let uuid: UInt16
    }
    
    /// 128 Bit Attribute
    public struct Attribute128Bit: Equatable {
        
        internal static var format: Format { return .bit128 }
        
        /// Attribute Handle
        public let handle: UInt16
        
        /// Attribute UUID
        public let uuid: UInt128
    }
}

public extension ATTFindInformationResponse {
    
    /// Found Attribute Data.
    public enum AttributeData: Equatable {
        
        /// Handle and 16-bit Bluetooth UUID
        case bit16([Attribute16Bit])
        
        /// Handle and 128-bit UUIDs
        case bit128([Attribute128Bit])
        
        /// The data's format.
        public var format: Format {
            
            switch self {
            case .bit16: return .bit16
            case .bit128: return .bit128
            }
        }
        
        /// Number of items.
        public var count: Int {
            
            switch self {
            case let .bit16(value): return value.count
            case let .bit128(value): return value.count
            }
        }
        
        internal init?(data: Data, format: Format) {
            
            let pairLength = format.length
            
            guard data.count % pairLength == 0
                else { return nil }
            
            let pairCount = data.count / pairLength
            
            var bit16Pairs: [Attribute16Bit] = []
            var bit128Pairs: [Attribute128Bit] = []
            
            switch format {
            case .bit16: bit16Pairs.reserveCapacity(pairCount)
            case .bit128: bit128Pairs.reserveCapacity(pairCount)
            }
            
            for pairIndex in 0 ..< pairCount {
                
                let byteIndex = pairIndex * pairLength
                let pairBytes = data.subdataNoCopy(in: byteIndex ..< byteIndex + pairLength)
                let handle = UInt16(littleEndian: UInt16(bytes: (pairBytes[0], pairBytes[1])))
                
                switch format {
                case .bit16:
                    let uuid = UInt16(littleEndian: UInt16(bytes: (pairBytes[2], pairBytes[3])))
                    bit16Pairs.append(Attribute16Bit(handle: handle, uuid: uuid))
                case .bit128:
                    let uuidBytes = pairBytes.subdataNoCopy(in: 2 ..< 18)
                    let uuid = UInt128(littleEndian: UInt128(data: uuidBytes)!)
                    bit128Pairs.append(Attribute128Bit(handle: handle, uuid: uuid))
                }
            }
            
            switch format {
            case .bit16: self = .bit16(bit16Pairs)
            case .bit128: self = .bit128(bit128Pairs)
            }
        }
        
        public var data: Data {
            
            var data = Data()
            
            switch self {
            case let .bit16(value):
                data.reserveCapacity(value.count * type(of: value).Element.format.length)
                for pair in value {
                    let handleBytes = pair.handle.littleEndian.bytes
                    let uuidBytes = pair.uuid.littleEndian.bytes
                    data += [handleBytes.0, handleBytes.1, uuidBytes.0, uuidBytes.1]
                }
                
            case let .bit128(value):
                data.reserveCapacity(value.count * type(of: value).Element.format.length)
                for pair in value {
                    let handleBytes = pair.handle.littleEndian.bytes
                    let uuidBytes = pair.uuid.littleEndian.bytes
                    data += [handleBytes.0, handleBytes.1, uuidBytes.0, uuidBytes.1, uuidBytes.2, uuidBytes.3, uuidBytes.4, uuidBytes.5, uuidBytes.6, uuidBytes.7, uuidBytes.8, uuidBytes.9, uuidBytes.10, uuidBytes.11, uuidBytes.12, uuidBytes.13, uuidBytes.14, uuidBytes.15]
                }
            }
            
            return data
        }
    }
}
