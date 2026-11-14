import SwiftUI

/// What the article list folds behind its info button: what the archive is
/// and how it was recovered, whose its contents are, and the blog's
/// original address.
struct LineBlogInfoSheet: View {
    let originalBlogURL: URL

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(.LineBlog.introBody)
                    Text(.LineBlog.commentsNote)
                    if let url = LineBlogLinkTarget.outsideURL(originalBlogURL) {
                        LineBlogProvenanceLink(title: .LineBlog.originalBlogAddress, url: url)
                    }
                } footer: {
                    Text(.LineBlog.rightsNotice)
                }
            }
            .navigationTitle(.LineBlog.info)
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            LineBlogInfoSheet(originalBlogURL: URL(string: "https://lineblog.me/example/")!)
        }
}
