//
//  ShowCaseRoot.swift
//  Exgram
//
//  Created by Artem Listopadov on 11.06.23.
//

import SwiftUI

/// Custom Show Case View Extensions

extension View {
    @ViewBuilder
    func showCase(order: Int, title: String, cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous, scale: CGFloat = 1) -> some View {
        self
        /// Storing it in Anchor Preference
            .anchorPreference(key: HighlightAnchorKey.self, value: .bounds) { anchor in
                let highlite = Highlight(anchor: anchor, title: title, cornerRadius: cornerRadius, style: style, scale: scale)
                return [order: highlite]
            }
    }
}

/// ShowCase Root View Modifier
struct ShowCaseRoot: ViewModifier {
    var showHighlights: Bool
    var onFinished: () -> ()
    
    /// View Properties
    @State private var highlightOrder: [Int] = []
    @State private var currentHighlight: Int = 0
    @State private var showView: Bool = true
    // Popover
    @State private var showTitle: Bool = false
    // Namespace ID, for smooth Shape Transitions
    @Namespace private var animation
    
    /*
     Логика заключается в том что мы собираем все клавиши выделения и сохраняем их в массиве, и каждый раз, когда пользователь нажимает на экран, мы переходим к следующему выделению в соответствии с заданными параметрами сортировки. В конечном итоге, подойдя к винальному выделению, закрывается весь View.
     */
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(HighlightAnchorKey.self) { value in
                highlightOrder = Array(value.keys).sorted()
            }
            .overlayPreferenceValue(HighlightAnchorKey.self){ preferences in
                if highlightOrder.indices.contains(currentHighlight), showHighlights, showView {
                    if let highlight = preferences[highlightOrder[currentHighlight]] {
                        HighlighView(highlight)
                    }
                }
            }
    }
    
    // Highlight View
    @ViewBuilder
    func HighlighView(_ highlight: Highlight) -> some View {
        /// Geometry Reader for Extracting Highlight Frame Rects
        
        GeometryReader { proxy in
            let highlightRect = proxy[highlight.anchor]
            let safeArea = proxy.safeAreaInsets
            
            Rectangle()
                .fill(.black.opacity(0.5))
                .reverseMask {
                    Rectangle()
                        .matchedGeometryEffect(id: "HIGHLIGHTSHAPE", in: animation)
                    // Assing Border
                    // Simply Extend Extend it's Size
                        .frame(width: highlightRect.width + 5, height: highlightRect.height + 5)
                        .clipShape(RoundedRectangle(cornerRadius: highlight.cornerRadius, style: highlight.style))
                        .scaleEffect(highlight.scale)
                        .offset(x: highlightRect.minX - 2.5, y: highlightRect.minY + safeArea.top - 2.5)
                }
                .ignoresSafeArea()
                .onTapGesture {
                    if currentHighlight >= highlightOrder.count - 1 {
                        // Hiding the Highlight View, because it's the Last Highlight
                        withAnimation(.easeOut(duration: 0.25)) {
                            showView = false
                        }
                        onFinished()
                    } else {
                        // Moving to next Highlight
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.7)){
                            showTitle = false
                            currentHighlight += 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            showTitle = true
                        }
                    }
                }
                .onAppear {
                    // Использование здесь промежуточной задачи,
                    // позволяет избежать использования очереди отправки
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showTitle = true
                    }
                }
            Rectangle()
                .foregroundColor(.clear)
            // Assing Border
            // Simply Extend Extend it's Size
                .frame(width: highlightRect.width + 5, height: highlightRect.height + 5)
                .clipShape(RoundedRectangle(cornerRadius: highlight.cornerRadius, style: highlight.style))
                .popover(isPresented: $showTitle) {
                    Text(highlight.title)
                        .padding(10)
                    // iOS 16.4+ Modifier
                        .presentationCompactAdaptation(.popover)
                        .interactiveDismissDisabled()
                }
                .scaleEffect(highlight.scale)
                .offset(x: highlightRect.minX - 2.5, y: highlightRect.minY - 2.5)
        }
    }
}

// Custom View Modifier for Inner/Reverse Mask
extension View {
    @ViewBuilder
    func reverseMask<Content: View>(alignment: Alignment = .topLeading, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .mask {
                Rectangle()
                    .overlay(alignment: .topLeading) {
                        content()
                            .blendMode(.destinationOut)
                    }
            }
    }
}

// Anchor Key
fileprivate struct HighlightAnchorKey: PreferenceKey {
    
    static var defaultValue: [Int: Highlight] = [:]
    
    static func reduce(value: inout [Int : Highlight], nextValue: () -> [Int : Highlight]) {
        value.merge(nextValue()) { $1 }
    }
}


struct ShowCaseHelper_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
