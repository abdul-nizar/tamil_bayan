//
//  DetailView.swift
//  Qrn
//
//  Created by Hamza on 04/06/23.
//

import SwiftUI
import WebKit
//

//
struct DetailView: View {
    var item: CatObject
    @State var subItems: [CatObject] = []
    
    @StateObject private var fontSizeManager = FontSizeManager()
    @State private var currentFontSize: CGFloat = 15
    
    @State var isBookmarked:Bool = false
    
    @State private var isShowingFontSizePopup = false
    
    let SELECT_ARTICLE_BY_ARTID = "SELECT category, description, artid, fav, 'No' FROM Articles WHERE artid=?"
    
    var body: some View {
        
        VStack {
            // Detail
            ForEach(subItems, id: \.id) { subItem in
                WebView(htmlString: subItem.topic, fontSizeManager: fontSizeManager)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            
            // Detail
            //            ForEach(subItems, id: \.id) { subItem in
            //                WebView(htmlString: subItem.topic, fontSize: fontSizeManager.fontSize)
            //                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            //
            //            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(item.topic)
        .navigationBarItems(trailing:
                                HStack{
            
            // Bookmark
            Button(action: {
                
                // update fav
                
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let dateString = dateFormatter.string(from: currentDate)
                
                // Update fav
                let newStatus = isBookmarked ? "" : dateString
                updateFavInDatabase(artid: item.catId, status: newStatus)
                
                // Enable/Disable bookmark
                isBookmarked = !newStatus.isEmpty
                
                
            }) {
                // Setting Icon
                if isBookmarked {
                    Image(systemName: "bookmark.slash.fill")
                        .font(.system(size: 17))
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "bookmark")
                        .font(.system(size: 17))
                        .foregroundColor(.blue)
                }
            }
            .foregroundColor(.primary)
            //            .padding(.trailing)
            
            // Setting
            Button(action: {
                isShowingFontSizePopup = true
            }) {
                Image(systemName: "textformat.size")
                    .foregroundColor(.blue)
                    .font(.system(size: 17))
            }
            /*.popover(isPresented: $isShowingFontSizePopup, content: {
                            HStack(spacing: 20) {
                                Button(action: {
                                    fontSizeManager.fontSize -= 2
                                    if fontSizeManager.fontSize  < 10{
                                        fontSizeManager.fontSize = 10
                                    }
                                }) {
                                    Image(systemName: "textformat.size.smaller")
                                        .font(.system(size: 25))
                                        .foregroundColor(.blue)
                                }
                                Button(action: {
                                    fontSizeManager.fontSize += 2
                                    if fontSizeManager.fontSize  > 30{
                                        fontSizeManager.fontSize = 30
                                    }
                                }) {
                                    Image(systemName: "textformat.size.larger")
                                        .font(.system(size: 25))
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(maxWidth: 200)

                            Text("Font Size: \(Int(fontSizeManager.fontSize))")
                                .font(.subheadline)
                        })*/
                        
           /* Button(action: {
                            isShowingFontSizePopup = true
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
                .border(Color.gray, width: 2)
                .background(Color.white)
                .presentationCornerRadius(10)
                .presentationDetents([.height(200)])
                
        }
        //        .onChange(of: fontSizeManager.fontSize) { _ in
        //                    // Redraw the WebView when fontSizeManager.fontSize changes
        //                    // This will reflect the updated font size
        //                    subItems = subItems // Force view refresh
        //
        //            print("fontSizeManager.fontSize:: \(fontSizeManager.fontSize)")
        //                }
        
        //        .onReceive(fontSizeManager.$fontSize, perform: { newFontSize in
        //            currentFontSize = newFontSize
        //        })
        .onAppear {
            
            isBookmarked = !item.fav.isEmpty
            
            //openDatabaseConnection()
            
            print("Detail View \(item.catId)")
            fetchDataFromDatabase(query: SELECT_ARTICLE_BY_ARTID, parameter: "\(item.catId)") { items in
                self.subItems = items
                fontSizeManager.isDetailBack = true
            }
        }
        
    }
    
    private func openDatabaseConnection() {
        if dbPointer == nil, let pointer = DBHelper.getDBPointer(dbName: "Articles.db") {
            dbPointer = pointer
        }
    }
}


struct WebView: UIViewRepresentable {
    var htmlString: String
    @ObservedObject var fontSizeManager: FontSizeManager
    
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.scrollView.backgroundColor = UIColor.systemBackground
//        webView.backgroundColor = UIColor.systemBackground
//        webView.isOpaque = false
//        return webView
//    }
    
    func makeUIView(context: Context) -> WKWebView {
        
        let fontSize = (fontSizeManager.fontSize * 10) + 120
        
        let webView = WKWebView()
        webView.scrollView.backgroundColor = UIColor.systemBackground
        webView.backgroundColor = UIColor.systemBackground
        webView.isOpaque = false
        webView.configuration.userContentController.addUserScript(userScript(for: fontSize))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let fontSize = (fontSizeManager.fontSize * 10) + 120
        let css = """
                <style>
                    @media (prefers-color-scheme: dark) {
                        body {
                            background-color: #000;
                            color: #FFF;
                        }
                        
                        h1 {
                            color: #007AFF;
                        }
                        
                        p {
                            font-size: 16px;
                        }
                    }
                    
                    @media (prefers-color-scheme: light) {
                        body {
                            background-color: #ECECEC;
                            color: #333;
                        }
                        
                        h1 {
                            color: #007AFF;
                        }
                        
                        p {
                            font-size: 16px;
                        }
                    }
                </style>
            """
        
        let htmlStringWithCSS = "\(css)\(htmlString)"
        uiView.loadHTMLString(htmlStringWithCSS, baseURL: nil)
        uiView.configuration.userContentController.addUserScript(userScript(for: fontSize))
    }
    
    private func userScript(for fontSize: CGFloat) -> WKUserScript {
        let scriptString = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '\(fontSize)%';"
        let script = WKUserScript(source: scriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        return script
    }
}


struct HTMLTextView: UIViewRepresentable {
    var htmlText: String
    var fontSize: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        textView.backgroundColor = UIColor.systemBackground
        textView.font = UIFont.systemFont(ofSize: fontSize) // Set the font size
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.backgroundColor = UIColor.systemBackground
        if let attributedText = htmlText.htmlToAttributedString {
            // Modify the text color and font size of the attributed string
            let modifiedText = NSMutableAttributedString(attributedString: attributedText)
            modifiedText.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: modifiedText.length))
            modifiedText.addAttribute(.font, value: UIFont.systemFont(ofSize: fontSize), range: NSRange(location: 0, length: modifiedText.length))
            
            uiView.attributedText = modifiedText
        } else {
            uiView.text = htmlText
            uiView.textColor = UIColor.label
            uiView.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}



extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return try? NSAttributedString(data: data, options: options, documentAttributes: nil)
    }
}


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        
        let txt = """
<p><span style="font-size: 12pt;"><span style="font-size: 12pt; color: #ff0000;">23) நபிமார்கள் மனைவியருடன் குடும்பம் நடத்தினர்</span></span></p>
<div id="s035" class="quran" style="text-align: right;">
<div class="QAyah" dir="rtl" style="text-align: right; font-size: 18pt; line-height: 170%; padding-right: 5px;"><span id="n035" class="ayaNum">2:35 </span><span id="k035">وَقُلْنَا يٰٓـاٰدَمُ اسْكُنْ اَنْتَ وَزَوْجُكَ الْجَـنَّةَ وَكُلَا مِنْهَا رَغَدًا حَيْثُ شِئْتُمَا وَلَا تَقْرَبَا هٰذِهِ الشَّجَرَةَ فَتَكُوْنَا مِنَ الظّٰلِمِيْنَ‏</span></div>
<p>&nbsp;</p>

"""
        
        //        let item = CatObject(topic: "நபிமார்கள் குடும்பம் நடத்தினர்", catId: 7549)
        let item = CatObject(category: "Title", topic: "நபிமார்கள் குடும்பம் நடத்தினர்", catId: 1681, fav: "YES", slug: "b00")
        
        let subItems: [CatObject] = [
            CatObject(category: "Title", topic: txt, catId: 7549, fav: "YES", slug: "b00")
        ]
        
        // DetailView(item: item, subItems: subItems)
        DetailView(item: item, subItems: subItems)
            .colorScheme(.dark)
    }
}
