//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 20/04/2023.
//

import Foundation
import XCTest
import CoreData
@testable import SecurityHandler


class CoreDataHelperTests: XCTestCase {
    var coreDataHelper: CoreDataHelper!
    var viewContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        coreDataHelper = CoreDataHelper()
        viewContext = coreDataHelper.container.viewContext
        
    }

    override func tearDown() {
        coreDataHelper = nil
        viewContext = nil
        super.tearDown()
    }

    func testInit() {
        XCTAssertNotNil(coreDataHelper)
        XCTAssertNotNil(coreDataHelper.container)
        XCTAssertNotNil(viewContext)
    }

    func testSaveAndFetchData() {
        let data = Data("Test Data".utf8)
        let symmetricKeyIdentifier = "testKey"
        let expiryDuration: TimeInterval = 3600
        do {
            let storedData = try CoreDataHelper.saveDataToCoreDataForTesting(data: data, viewContext: viewContext, symmetricKeyIdentifier: symmetricKeyIdentifier, expiryDuration: expiryDuration, cryptoHelper: SecurityHandler.MockCryptoHelper.self)
            XCTAssertNotNil(storedData)
            
            let fetchedData = CoreDataHelper.fetch(viewContext: viewContext)
            XCTAssertFalse(fetchedData.isEmpty)
        } catch {
            XCTAssertThrowsError(error)
        }
    }

    func testDeleteStoredDataModel() {
        let data = Data("Test Data".utf8)
        let symmetricKeyIdentifier = "testKey"
        let expiryDuration: TimeInterval = 3600

        do {
            let storedData = try CoreDataHelper.saveDataToCoreDataForTesting(data: data, viewContext: viewContext, symmetricKeyIdentifier: symmetricKeyIdentifier, expiryDuration: expiryDuration, cryptoHelper: SecurityHandler.MockCryptoHelper.self)
            XCTAssertNotNil(storedData)

            try CoreDataHelper.deleteStoredDataModel(storedData, viewContext: viewContext)
            
            let fetchedData = CoreDataHelper.fetch(viewContext: viewContext)
            XCTAssertTrue(fetchedData.filter({ model in model == storedData }).isEmpty)
        } catch {
            XCTAssertThrowsError(error)
        }
        

    }

    func testStoredDataModelExpiration() {
        let data = Data("Test Data".utf8)
        let symmetricKeyIdentifier = "testKey"
        let expiryDuration: TimeInterval = -3600
        do {
            let storedData = try CoreDataHelper.saveDataToCoreDataForTesting(data: data, viewContext: viewContext, symmetricKeyIdentifier: symmetricKeyIdentifier, expiryDuration: expiryDuration, cryptoHelper: SecurityHandler.MockCryptoHelper.self)
            XCTAssertNotNil(storedData)
            
            XCTAssertTrue(storedData.isExpired)
        } catch {
            XCTAssertThrowsError(error)
        }
    }

    func testFormattedDateOfData() {
        let data = Data("Test Data".utf8)
        let symmetricKeyIdentifier = "testKey"
        let expiryDuration: TimeInterval = 3600
        do {
            let storedData = try CoreDataHelper.saveDataToCoreDataForTesting(data: data, viewContext: viewContext, symmetricKeyIdentifier: symmetricKeyIdentifier, expiryDuration: expiryDuration, cryptoHelper: SecurityHandler.MockCryptoHelper.self)
            XCTAssertNotNil(storedData)
            XCTAssertNotNil(storedData.formattedDateOfData)
        } catch {
            XCTAssertThrowsError(error)
        }
    }

    func testExpirationDay() {
        let data = Data("Test Data".utf8)
        let symmetricKeyIdentifier = "testKey"
        let expiryDuration: TimeInterval = 3600
        do {
            let storedData = try CoreDataHelper.saveDataToCoreDataForTesting(data: data, viewContext: viewContext, symmetricKeyIdentifier: symmetricKeyIdentifier, expiryDuration: expiryDuration, cryptoHelper: SecurityHandler.MockCryptoHelper.self)
            XCTAssertNotNil(storedData)
            XCTAssertNotNil(storedData.expirationDay)
        } catch {
            XCTAssertThrowsError(error)
        }
    }
}
