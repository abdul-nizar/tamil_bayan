//
//  ContentListView.swift
//  Qrn
//
//  Created by Hamza on 04/06/23.
//
import SwiftUI


struct ContentListView<T: View>: View {
    @State private var items: [CatObject] = []
    @State private var searchText = ""
    
    @State private var isShowingFontSizePopup = false
    @StateObject private var fontSizeManager = FontSizeManager()
    
    @State private var selectedOption = true
    
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var isBookmarkActivated:Bool = true
    
    @State private var isBookmarkView:Bool = false
    
    let detailView: (CatObject) -> T
    
    //
    let isBasicMode: Bool
    init(isBasicMode: Bool, detailView: @escaping (CatObject) -> T) {
        self.isBasicMode = isBasicMode
        self.detailView = detailView
    }
    
    private var filteredItems: [CatObject] {
        return items
    }
    
    let SEARCH_BY_CATEGORY = "SELECT category, category, catId, 'No', slug FROM categories order by slug"
    let SEARCH_ARTICLE_BY_NAME = "SELECT category, name, artid, fav, 'No' FROM Articles WHERE name LIKE ? order by category"
    let SEARCH_ARTICLE_BY_FAV = "SELECT category, name, artid, fav, 'No' FROM Articles WHERE fav != ? order by fav desc"
    
    
    var body: some View {
        
        VStack {
            
            HStack{
                
                // Search Field
                TextField("      Search", text: $searchText)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .overlay(
                        ZStack {
                            HStack {
                                if searchText.isEmpty {
                                    
                                    // Search Icon
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 8)
                                    Spacer()
                                }
                            }
                            HStack {
                                Spacer()
                                if !searchText.isEmpty {
                                    
                                    // Clear x button
                                    Button(action: {
                                        searchText = ""
                                    }, label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    })
                                    
                                }
                            }
                        }
                    )
                    .focused($isTextFieldFocused)
                if !searchText.isEmpty || isTextFieldFocused{
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        searchText = ""
                    }, label: {
                        Text("Cancel")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    })
                }
            }
            .padding(.horizontal)
            
            
            // Search Mode
            /*
             Picker(selection: $selectedOption, label: Text("")) {
             Text("Title").tag(true)
             Text("Content").tag(false)
             }
             .pickerStyle(SegmentedPickerStyle())
             .padding(.horizontal)
             */
            
            // List
            List(filteredItems) { item in
                NavigationLink(destination: detailView(item)) {
                    HStack{
                        
                        // ICON
                        if isBookmarkView {
                            getIcon(for: "fav")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                            //VStack{
                            Text(item.category)
                                .foregroundColor(.primary) +
                            Text("\n\(item.topic)")
                                .font(.system(size: 12))
                                .foregroundColor(.blue) +
                            Text("\n\(item.fav)")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            
                            // }
                        } else {
                            getIcon(for: item.slug)
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                            Text(item.topic)
                                .foregroundColor((item.fav.isEmpty || item.fav == "No" ) ? .primary : .blue)
                        }
                        
                    }
                }
            }.padding(0)
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .navigationTitle("Tamil Bayan Points")
                .navigationBarItems(trailing:
                                        HStack{
                    
                    // Bookmark
                    Button(action: {
                        
                        //
                        showAllBookmarked()
                        
                    }) {
                        
                        if isBookmarkActivated {
                            Image(systemName: "bookmark")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(.blue)
                        }
                        
                    }
                    .foregroundColor(.primary)
                    .font(.system(size: 17))
                    
                    // Setting
                    /*
                     Button(action: {
                        
                        isShowingFontSizePopup = true
                        
                        // close the keypad
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        
                        searchText = ""
                        
                    }) {
                        // Setting Icon
                        Image(systemName: "gearshape")
                    }
                    .foregroundColor(.primary)
                    .font(.system(size: 17))*/
                }
                )
            
            // SettingsView
                .sheet(isPresented: $isShowingFontSizePopup) {
                    SettingsView(fontSize: $fontSizeManager.fontSize, isPresented: $isShowingFontSizePopup)
                }
                .onAppear {
                    
                    fontSizeManager.isDetailBack = false
                    isBookmarkActivated = true
                    
                    isBookmarkView = false
                    
                    if searchText.isEmpty {
                        
                        fetchDataFromDatabase(query: SEARCH_BY_CATEGORY, parameter: "NULL") { items in
                            self.items = items
                            print("onAppear::Default List Result")
                        }
                    }
                    else {
                        fontSizeManager.isDetailBack = true
                        
                        // TODO: search by Title or Content
                        fetchDataFromDatabase(query: SEARCH_ARTICLE_BY_NAME, parameter: "%\(searchText)%") { items in
                            self.items = items
                            print("onAppear::DB Search Result")
                            
                        }
                    }
                    
                }
            
            // onchange triggers when search text changes
                .onChange(of: searchText) { newText in
                    
                    fontSizeManager.isDetailBack = false
                    
                    isBookmarkView = false
                    
                    if newText.isEmpty {
                        fetchDataFromDatabase(query: SEARCH_BY_CATEGORY, parameter: "NULL") { items in
                            self.items = items
                            print("onChange::Default List Result")
                        }
                    } else {
                        
                        fontSizeManager.isDetailBack = true
                        
                        // TODO: search by Title or Content
                        fetchDataFromDatabase(query: SEARCH_ARTICLE_BY_NAME, parameter: "%\(newText)%") { items in
                            self.items = items
                            print("onChange::DB Search Result")
                            
                        }
                    }
                }
            
        }
    }
    
    func showAllBookmarked () {
        
        isBookmarkView = false
        
        isBookmarkActivated = !isBookmarkActivated
        
        // searchText = ""
        
        fontSizeManager.isDetailBack = false
        
        if isBookmarkActivated {
            fetchDataFromDatabase(query: SEARCH_BY_CATEGORY, parameter: "NULL") { items in
                self.items = items
                print("showAllBookmarked::Default List Result")
            }
        } else {
            
            fontSizeManager.isDetailBack = true
            
            
            
            // TODO: search by Title or Content
            fetchDataFromDatabase(query: SEARCH_ARTICLE_BY_FAV, parameter: "") { items in
                self.items = items
                print("showAllBookmarked::DB FAV Search Result")
                
                isBookmarkView = true
                
            }
        }
        
    }
}

//struct HighlightedText: View {
//    let searchText: String
//    let text: String
//    
//    var body: some View {
//        let highlightedText = NSMutableAttributedString(string: text)
//        let range = highlightedText.mutableString.range(of: searchText, options: .caseInsensitive)
//        if range.location != NSNotFound {
//            highlightedText.addAttribute(.foregroundColor, value: UIColor.red, range: range)
//        }
//        
//        return Text("").font(.body).attributedText(highlightedText)
//    }
//}

struct ContentListView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            ContentListView(isBasicMode: true) { item in
                SubListView(item: item)
            }
        }
    }
}


@ViewBuilder
func getIcon(for slug: String) -> some View {
    switch slug.first {
        
    case "a":
        Image(systemName: "moon.circle")
            .foregroundColor(.green)
    case "b":
        Image(systemName: "note.text")
            .foregroundColor(.orange)
    case "q":
        Image(systemName: "q.circle")
            .foregroundColor(.purple)
    case "u":
        Image(systemName: "book")
            .foregroundColor(.blue)
    case "f":
        Image(systemName: "bookmark")
        // .foregroundColor(.blue)
    default:
        Image(systemName: "circle.dashed")
            .foregroundColor(.yellow)
    }
}
