//
//  AdjustFontSizeView.swift
//  Qrn
//
//  Created by Hamza on 04/06/23.
//

import SwiftUI

struct SettingsView: View {
    @Binding var fontSize: CGFloat
    @Binding var isPresented: Bool

    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            
            List {
                
                // Font Size
                VStack {
                    Text("Adjust Font Size")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Slider
                    HStack {
                        Image(systemName: "textformat.size.smaller")
                            .font(.system(size: 17))
                        Slider(value: $fontSize, in: 10...30, step: 1)
                        Image(systemName: "textformat.size.larger")
                            .font(.system(size: 20))
                    }
                    //.padding(.horizontal)
                    
//                    Text("Font Size: \(Int(fontSize))")
//                        .font(.subheadline)
                }
            }
            
            // Done Button
//            Button(action: {
//                // Save the updated font size value and dismiss the popup
//                // You can implement the logic here to apply the new font size globally or as required
//
//                dismiss()
//            }) {
//                Text("Done")
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .cornerRadius(8)
//                    .padding(.horizontal)
//            }
            
        }
        
    }
    
    private func dismiss() {
        isPresented = false
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        @State var fontSize: CGFloat = 15
        @State var isPresented: Bool = true
        @State var isBasicMode: Bool = false
        
        SettingsView(fontSize: $fontSize, isPresented: $isPresented)
    }
}

