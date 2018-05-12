//
//  LocalName.swift
//  Bluetooth
//
//  Created by Alsey Coleman Miller on 3/26/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

public extension BluetoothHostControllerInterface {
    
    /// Read Local Name Command
    ///
    /// Provides the ability to read the stored user- friendly name for the BR/EDR Controller.
    func writeLocalName(_ newValue: String, timeout: HCICommandTimeout = .default) throws {
        
        guard let command = HostControllerBasebandCommand.WriteLocalNameParameter(localName: newValue)
            else { fatalError("") }
        
        try deviceRequest(command, timeout: timeout)
    }
    
    /// Write Local Name Command
    ///
    /// Provides the ability to modify the user- friendly name for the BR/EDR Controller.
    func readLocalName(timeout: HCICommandTimeout = .default) throws -> String {
        
        let value = try deviceRequest(HostControllerBasebandCommand.ReadLocalNameReturnParameter.self,
                                      timeout: timeout)
        
        return value.localName
    }
}
