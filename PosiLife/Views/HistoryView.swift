//
//  HistoryView.swift
//  PosiLife
//
//  Created by Anshuman Bhatt on 17/09/25.
//

import SwiftUI

struct HistoryView: View  {
    var body: some View {
        
        VStack {
            Text("Watch previous progress")
                .font(.title)
                .fontWeight(.bold)
        }
        .navigationTitle(Text("My History"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
        
    }
}

#Preview {
    HistoryView()
}
