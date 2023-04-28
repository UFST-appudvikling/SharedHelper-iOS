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

/// Documentaion
/// This is a Test Class for CoreDataHelper.
/// It has some test cases for testing the CoreDataHelper.
/// It has the following test cases:
/// 1. testInit()
/// it's testing the init of CoreDataHelper.
/// 2. testSaveAndFetchData()
/// it's testing the save and fetch data from CoreData by using fake data.
/// 3. testDeleteStoredDataModel()
/// it's testing the delete data from CoreData by using fake data.
/// 4. testStoredDataModelExpiration()
/// it's testing the expiration of data from CoreData by using fake data.
/// 5. testFormattedDateOfData()
/// it's testing the formatted date of data from CoreData by using fake data.
/// 6. testExpirationDay()
/// it's testing the expiration day of data from CoreData by using fake data.
class CoreDataHelperTests: XCTestCase {
    var coreDataHelper: SecurityHandler.CoreDataHelper!
    var viewContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        coreDataHelper = SecurityHandler.CoreDataHelper()
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
            let storedData = try SecurityHandler.CoreDataHelper.saveDataToCoreDataForTesting(data: data, viewContext: viewContext, symmetricKeyIdentifier: symmetricKeyIdentifier, expiryDuration: expiryDuration, cryptoHelper: SecurityHandler.MockCryptoHelper.self)
            XCTAssertNotNil(storedData)
            
            let fetchedData = SecurityHandler.CoreDataHelper.fetch(viewContext: viewContext)
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
            let storedData = try SecurityHandler.CoreDataHelper.saveDataToCoreDataForTesting(data: data, viewContext: viewContext, symmetricKeyIdentifier: symmetricKeyIdentifier, expiryDuration: expiryDuration, cryptoHelper: SecurityHandler.MockCryptoHelper.self)
            XCTAssertNotNil(storedData)

            try SecurityHandler.CoreDataHelper.deleteStoredDataModel(storedData, viewContext: viewContext)
            
            let fetchedData = SecurityHandler.CoreDataHelper.fetch(viewContext: viewContext)
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
            let storedData = try SecurityHandler.CoreDataHelper.saveDataToCoreDataForTesting(data: data, viewContext: viewContext, symmetricKeyIdentifier: symmetricKeyIdentifier, expiryDuration: expiryDuration, cryptoHelper: SecurityHandler.MockCryptoHelper.self)
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
            let storedData = try SecurityHandler.CoreDataHelper.saveDataToCoreDataForTesting(data: data, viewContext: viewContext, symmetricKeyIdentifier: symmetricKeyIdentifier, expiryDuration: expiryDuration, cryptoHelper: SecurityHandler.MockCryptoHelper.self)
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
            let storedData = try SecurityHandler.CoreDataHelper.saveDataToCoreDataForTesting(data: data, viewContext: viewContext, symmetricKeyIdentifier: symmetricKeyIdentifier, expiryDuration: expiryDuration, cryptoHelper: SecurityHandler.MockCryptoHelper.self)
            XCTAssertNotNil(storedData)
            XCTAssertNotNil(storedData.expirationDay)
        } catch {
            XCTAssertThrowsError(error)
        }
    }
}
