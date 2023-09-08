import SwiftUI
import SQLite3

import WebKit

var dbPointer1: OpaquePointer?

struct CatObject: Identifiable, Hashable {
    let id = UUID()
    var topic: String
    var catId: Int
}

struct ContentDBView<T: View>: View {
    @State var items: [CatObject] = []
    let detailView: (CatObject) -> T
    
    var body: some View {
        VStack {
            NavigationView {
                List(items) { item in
                    NavigationLink(destination: detailView(item)) {
                        Text(item.topic)
                    }
                }
                .navigationTitle("Bayan Points")
            }
        }
        .onAppear {
            let query = "SELECT category, catId FROM categories"
            fetchDataFromDatabase(query: query) { items in
                self.items = items
            }
        }
    }
}

struct SubListView: View {
    var item: CatObject
    @State var subItems: [CatObject] = []
    
    var body: some View {
        NavigationView {
            List(subItems) { subItem in
                NavigationLink(destination: DetailView(item: subItem)) {
                    Text(subItem.topic)
                }
            }
            .navigationTitle(item.topic)
        }
        .onAppear {
            let query = "SELECT name, artid FROM Articles WHERE catId=\(item.catId)"
            fetchDataFromDatabase(query: query) { items in
                self.subItems = items
            }
        }
    }
}

struct DetailView: View {
    var item: CatObject
    @State var subItems: [CatObject] = []
    
    var body: some View {
        VStack {
//            ForEach(subItems, id: \.id) { subItem in
//                Text(subItem.topic)
//            }
//            .padding()
            
            ForEach(subItems, id: \.id) { subItem in
//                            HTMLString(htmlContent: subItem.topic)
//                                .padding()
                
                WebView(htmlString: subItem.topic)
                      .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        }
        }
        .onAppear {
            let query = "SELECT description, artid FROM Articles WHERE artid=\(item.catId)"
            print("artid :: \(item.catId)")
            
            fetchDataFromDatabase(query: query) { items in
                self.subItems = items
            }
        }
        
        
    }
}

struct WebView: UIViewRepresentable {
    var htmlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

func fetchDataFromDatabase(query: String, completion: @escaping ([CatObject]) -> Void) {
    DispatchQueue.main.async {
        if let pointer = DBHelper.getDBPointer(dbName: "Articles.db") {
            dbPointer1 = pointer
        }
        
        var items: [CatObject] = []
        
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(dbPointer1, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                if let column1Data = sqlite3_column_text(queryStatement, 0),
                   let column2Data = sqlite3_column_text(queryStatement, 1) {
                    let topic = String(cString: column1Data)
                    let catIdString = String(cString: column2Data)
                    
                    if let catId = Int(catIdString) {
                        items.append(CatObject(topic: topic, catId: catId))
                    }
                }
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(dbPointer1))
            print("Error preparing SQL statement: \(errorMessage)")
        }
        
        sqlite3_finalize(queryStatement)
        sqlite3_close(dbPointer1)
        
        completion(items)
    }
}


struct ContentDBView_Previews: PreviewProvider {
    static var previews: some View {
        ContentDBView { item in
            SubListView(item: item)
        }
    }
}
