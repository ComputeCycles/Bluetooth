//
//  Test.swift
//  Bluetooth
//
//  Created by Marco Estrella on 4/3/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

public extension BluetoothHostControllerInterface {
    
    /// LE Receiver Test Command
    ///
    /// This command is used to start a test where the DUT receives test reference packets at a fixed interval.
    /// The tester generates the test reference packets.
    func lowEnergyReceiverTest(rxChannel: LowEnergyRxChannel, timeout: HCICommandTimeout = .default) throws {
        
        let parameters = LowEnergyCommand.ReceiverTestParameter(rxChannel: rxChannel)
        
        try deviceRequest(parameters, timeout: timeout)
    }
    
    /// LE Transmitter Test Command
    ///
    /// This command is used to start a test where the DUT generates test reference packets
    /// at a fixed interval. The Controller shall transmit at maximum power.
    func lowEnergyTransmitterTest(txChannel: LowEnergyTxChannel,
                                  lengthOfTestData: UInt8,
                                  packetPayload: LowEnergyPacketPayload,
                                  timeout: HCICommandTimeout = .default) throws {
        
        let parameters = LowEnergyCommand.TransmitterTestParameter(txChannel: txChannel, lengthOfTestData: lengthOfTestData, packetPayload: packetPayload)
        
        try deviceRequest(parameters, timeout: timeout)
    }
    
    /// LE Test End Command
    ///
    /// This command is used to stop any test which is in progress.
    func lowEnergyTestEnd(timeout: HCICommandTimeout = .default) throws -> UInt16 {
        
        let value = try deviceRequest(LowEnergyCommand.TestEndReturnParameter.self,
                                      timeout: timeout)
        
        return value.numberOfPackets
    }
    
    /// LE Enhanced Receiver Test Command
    ///
    /// This command is used to start a test where the DUT receives test
    /// reference packets at a fixed interval. The tester generates the test
    /// reference packets.
    func lowEnergyEnhancedReceiverTest(rxChannel: LowEnergyRxChannel, phy: LowEnergyCommand.EnhancedReceiverTestParameter.Phy, modulationIndex: LowEnergyCommand.EnhancedReceiverTestParameter.ModulationIndex, timeout: HCICommandTimeout = .default) throws {
        
        let parameters = LowEnergyCommand.EnhancedReceiverTestParameter(rxChannel: rxChannel, phy: phy, modulationIndex: modulationIndex)
        
        try deviceRequest(parameters, timeout: timeout)
    }
    
    /// LE Enhanced Transmitter Test Command
    ///
    /// This command is used to start a test where the DUT generates test reference packets
    /// at a fixed interval. The Controller shall transmit at maximum power.
    func lowEnergyEnhancedTransmitterTest(txChannel: LowEnergyTxChannel, lengthOfTestData: UInt8, packetPayload: LowEnergyPacketPayload, phy: LowEnergyCommand.EnhancedTransmitterTest.Phy, timeout: HCICommandTimeout = .default) throws {
        
        let parameters = LowEnergyCommand.EnhancedTransmitterTest(txChannel: txChannel, lengthOfTestData: lengthOfTestData, packetPayload: packetPayload, phy: phy)
        
        try deviceRequest(parameters, timeout: timeout)
    }
}
