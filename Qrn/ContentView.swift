import SwiftUI
import SQLite3
import WebKit

var dbPointer: OpaquePointer?

struct CatObject: Identifiable, Hashable {
    let id = UUID()
    var category: String
    var topic: String
    var catId: Int
    var fav: String
    var slug: String
}

struct ContentView: View {
    
    @StateObject private var fontSizeManager = FontSizeManager()
    
    var body: some View {
        
        
        NavigationView {
            ContentListView(isBasicMode: true) { item in
                SubListView(item: item)
            }
        }
        .onAppear {
            openDatabaseConnection()
        }
        
    }
    
    private func openDatabaseConnection() {
        if dbPointer == nil, let pointer = DBHelper.getDBPointer(dbName: "Articles.db") {
            dbPointer = pointer
        }
    }
}


//
struct FontSizeKey: EnvironmentKey {
    static let defaultValue: CGFloat = 15
}

//struct IsBasicModeKey: EnvironmentKey {
//    static let defaultValue: Bool = true
//}

struct IsDetailBackKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var fontSize: CGFloat {
        get { self[FontSizeKey.self] }
        set { self[FontSizeKey.self] = newValue }
    }
    
    var isDetailBack: Bool {
        get { self[IsDetailBackKey.self] }
        set { self[IsDetailBackKey.self] = newValue }
    }
}


class FontSizeManager: ObservableObject {
    @Published var fontSize: CGFloat {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }
    
    @Published var isDetailBack: Bool {
        didSet {
            UserDefaults.standard.set(isDetailBack, forKey: "isDetailBack")
        }
    }
    
    init() {
        self.fontSize = UserDefaults.standard.object(forKey: "fontSize") as? CGFloat ?? 15
        self.isDetailBack = UserDefaults.standard.object(forKey: "isDetailBack") as? Bool ?? false
    }
}


var currentTask: DispatchWorkItem?
let databaseQueue = DispatchQueue(label: "com.example.databaseQueue", qos: .userInitiated)

func fetchDataFromDatabase(query: String, parameter: String, completion: @escaping ([CatObject]) -> Void) {
    // Check if there's an ongoing task and cancel it
    currentTask?.cancel()
    
    // Create a new task
    let task = DispatchWorkItem {
        guard let dbPointer = dbPointer else {
            DispatchQueue.main.async {
                completion([])
            }
            return
        }

        var items: [CatObject] = []
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dbPointer, query, -1, &queryStatement, nil) == SQLITE_OK {
            
            if parameter != "NULL" {
                let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                if sqlite3_bind_text(queryStatement, 1, parameter, -1, SQLITE_TRANSIENT) != SQLITE_OK {
                    let errorMessage = String(cString: sqlite3_errmsg(dbPointer))
                    print("Error binding parameter: \(errorMessage)")
                    sqlite3_finalize(queryStatement)
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }
            }
            
            let finalQuery = String(cString: sqlite3_expanded_sql(queryStatement))
            print("Final Query: \(finalQuery)")
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                if let column0Data = sqlite3_column_text(queryStatement, 0),
                   let column1Data = sqlite3_column_text(queryStatement, 1),
                   let column2Data = sqlite3_column_text(queryStatement, 2),
                   let column3Data = sqlite3_column_text(queryStatement, 3),
                   let column4Data = sqlite3_column_text(queryStatement, 4){
                    let category = String(cString: column0Data)
                    let topic = String(cString: column1Data)
                    let catIdString = String(cString: column2Data)
                    let favString = String(cString: column3Data)
                    let slug = String(cString: column4Data)
                    
                    if let catId = Int(catIdString) {
                        items.append(CatObject(category: category, topic: topic, catId: catId, fav: favString, slug:slug))
                    }
                }
                
                // Check for cancellation after processing each row
                if currentTask?.isCancelled ?? false {
                    DispatchQueue.main.async {
                        completion([])
                    }
                    sqlite3_finalize(queryStatement)
                    return
                }
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(dbPointer))
            print("Error preparing SQL statement: \(errorMessage)")
        }
        
        sqlite3_finalize(queryStatement)
        
        DispatchQueue.main.async {
            completion(items)
        }
    }
    
    // Store the new task
    currentTask = task
    
    // Execute the task on the dedicated database queue
    databaseQueue.async(execute: task)
}

func updateFavInDatabase(artid: Int, status: String) {
    
    guard let dbPointer = dbPointer else {
        //        DispatchQueue.main.async {
        //            completion([])
        //        }
        return
    }
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    // Begin the transaction
    let beginTransactionQuery = "BEGIN TRANSACTION;"
    if sqlite3_exec(dbPointer, beginTransactionQuery, nil, nil, nil) != SQLITE_OK {
        print("Failed to begin transaction.")
        return
    }
    
    var statement: OpaquePointer?
    let updateQuery = "UPDATE Articles SET fav = ? WHERE artid = ?;"
    
    // Prepare the update statement
    if sqlite3_prepare_v2(dbPointer, updateQuery, -1, &statement, nil) == SQLITE_OK {
        // Bind the new value and record ID to the statement
        sqlite3_bind_text(statement, 1, status, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(statement, 2, Int32(artid))
        
        let finalQuery = String(cString: sqlite3_expanded_sql(statement))
        print("Final Update Query: \(finalQuery)")
        
        // Execute the update statement
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Record updated successfully.")
        } else {
            print("Failed to update record.")
        }
    } else {
        print("Error preparing update statement.")
    }
    
    // Finalize the statement
    sqlite3_finalize(statement)
    
    
    // Commit the changes
    let commitQuery = "COMMIT;"
    
    if sqlite3_exec(dbPointer, commitQuery, nil, nil, nil) == SQLITE_OK {
        print("Changes committed successfully.")
    } else {
        let errorMessage = String(cString: sqlite3_errmsg(dbPointer))
        print("Error: \(errorMessage)")
        print("Failed to commit changes.")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .colorScheme(.dark)
    }
}
