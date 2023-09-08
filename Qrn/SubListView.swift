//
//  SubListView.swift
//  Qrn
//
//  Created by Hamza on 04/06/23.
//
import SwiftUI

struct SubListView: View {
    var item: CatObject
    var searchText = ""
    
    @State var subItems: [CatObject] = []
    
    @StateObject private var fontSizeManager = FontSizeManager()
    
    let SEARCH_ARTICLE_BY_CATID = "SELECT category, name, artid, fav, 'No' FROM Articles WHERE catId=? ORDER BY name"
 
    var body: some View {
        if !fontSizeManager.isDetailBack {
            List(subItems) { subItem in
                NavigationLink(destination: DetailView(item: subItem)) {
                    Text(subItem.topic)
                        .foregroundColor((subItem.fav.isEmpty || subItem.fav == "No" ) ? .primary : .blue)
                }
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            
            .navigationTitle(item.topic)
            .onAppear {
                fetchDataFromDatabase(query: SEARCH_ARTICLE_BY_CATID, parameter: "\(item.catId)") { items in
                    self.subItems = items
                }
            }
        } else {
            DetailView(item: item)
        }
        
    }
}
