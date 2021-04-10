//
//  FilterList.swift
//  FilterList-Master
//
//  Created by Nigel Gee on 08/04/2021.
//

import SwiftUI

/// A List that filter the data on a give key(s)
public struct FilterList<Element: Identifiable, RowContent: View>: View {
    @State private var filteredItems = [Element]()
    @State private var filterString = ""

    let listItems: [Element]
    let filterKeyPaths: [KeyPath<Element, String>]
    let text: LocalizedStringKey
    let image: String?
    let color: Color
    let content: (Element) -> RowContent

    /// Only data, filterKeys and RowContent is required. Rest have defaults
    /// - Parameters:
    ///   - data: A collection of identifiable data for computing the list.
    ///   - filterKeys: Variadic String for filtering.
    ///   - placeholder: String that in the box. Default is "Search".
    ///   - systemImage: Optional String for SF Symbol. Default is "magnifyingglass". insert nil for text only.
    ///   - imageColor: Color for the image. Default is .secondary. Note opacity is still 0.4
    ///   - rowContent: A view builder that creates the view for a single row of the list.
    public init(_ data: [Element],
         filterKeys: KeyPath<Element, String>...,
         placeholder: LocalizedStringKey = "Search",
         systemImage: String? = "magnifyingglass",
         imageColor: Color = Color.secondary.opacity(0.4), /// Match the standard text color
         @ViewBuilder rowContent: @escaping (Element) -> RowContent
    ) {
        listItems = data
        filterKeyPaths = filterKeys
        text = placeholder
        image = systemImage
        color = imageColor
        content = rowContent
    }

    public var body: some View {
        VStack {
            HStack {
                /// If nil is set for systemImage then text only will appear
                if let image = image {
                    Image(systemName: image)
                        .foregroundColor(color)
                }
                TextField(text, text: $filterString.ifChange(applyFilter))
            }
            .padding(5)
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal)

            List(filteredItems, rowContent: content)
                .onAppear(perform: applyFilter)
        }
    }

    /// Private function to apply the string filter to list
    private func applyFilter() {
        let cleanedFilter = filterString.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanedFilter.isEmpty {
            filteredItems = listItems
        } else {
            filteredItems = listItems.filter { element in
                filterKeyPaths.contains {
                    element[keyPath: $0]
                        .localizedCaseInsensitiveContains(cleanedFilter)
                }
            }
        }
    }
}

/// Extension on Binding to update the filter to applyFilter
fileprivate extension Binding {
    func ifChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue},
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            })
    }
}
