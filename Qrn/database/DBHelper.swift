//
//  DBHelper.swift
//  Qrn
//
//  Created by Hamza on 02/06/23.
//

import Foundation
import SQLite3

class DBHelper {
    
    
    static func getDBPointer (dbName: String) -> OpaquePointer? {
        
        var dbPointer: OpaquePointer?
        
        let dbPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(dbName).path
        
        if FileManager.default.fileExists(atPath: dbPath){
            print("DB already found")
        }else{
            
            guard let bundleDBPath = Bundle.main.resourceURL?.appendingPathComponent(dbName).path else {
                print("Unwrapping Error: Bundle DB path dosnt exist")
                return nil
            }
            
            do {
                try FileManager.default.copyItem(atPath: bundleDBPath, toPath: dbPath)
                print("DB created (copied)")
            }catch {
                print("Error: \(error.localizedDescription)")
                return nil
            }
        }
        
        
        if sqlite3_open(dbPath, &dbPointer) == SQLITE_OK {
            print("Successfully open DB")
            print("DB path: \(dbPath)")
        }else{
            print("Could not open DB")
        }
        
        
        return dbPointer
    }
}
