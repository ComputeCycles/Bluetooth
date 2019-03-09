//
//  Data.swift
//  Bluetooth
//
//  Created by Alsey Coleman Miller on 5/30/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation

internal extension Data {
    
    #if swift(>=5.0)
    func subdataNoCopy(in range: Range<Int>) -> Data {
        
        let result = try? withUnsafeBytes { (buf: UnsafeRawBufferPointer) throws -> Result<UnsafeMutableRawPointer, Error> in
            guard let p = buf.baseAddress else {
                return Result<UnsafeMutableRawPointer, Error>.failure( NSError(domain: "domain", code: 1000, userInfo: [:]) )
            }
            return Result { UnsafeMutableRawPointer(mutating: p).advanced(by: range.lowerBound) }
        }
        switch result {
        case .success(let pointer)?:
            return Data(bytesNoCopy: pointer, count: range.count, deallocator: .none)
        default:
            return Data()
        }
    }
    #elseif swift(>=4.2)
    func subdataNoCopy(in range: Range<Int>) -> Data {
    
        let pointer = withUnsafeBytes { UnsafeMutableRawPointer(mutating: $0).advanced(by: range.lowerBound) }
        return Data(bytesNoCopy: pointer, count: range.count, deallocator: .none)
    }
    #else
    func subdataNoCopy(in range: CountableRange<Int>) -> Data {
        
        let pointer = withUnsafeBytes { UnsafeMutableRawPointer(mutating: $0).advanced(by: range.lowerBound) }
        return Data(bytesNoCopy: pointer, count: range.count, deallocator: .none)
    }
    
    /// Returns a new copy of the data in a specified range.
    func subdata(in range: CountableRange<Int>) -> Data {
        return Data(self[range])
    }
    #endif
    
    func suffixNoCopy(from index: Int) -> Data {
        
        return subdataNoCopy(in: index ..< count)
    }
    
    func suffixCheckingBounds(from start: Int) -> Data {
        
        if count > start {
            
            return Data(suffix(from: start))
            
        } else {
            
            return Data()
        }
    }
}
