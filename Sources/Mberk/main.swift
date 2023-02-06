import Foundation
import Plot
import Publish
import HighlightJSPublishPlugin

// This type acts as the configuration for your website.
struct Mberk: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case projects
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://mberk.com")!
    var name = "Michael Berk"
    var description = "Michael Berk's website"
    var language: Language { .english }
    var imagePath: Path? { "favicon.jpeg" }
}

// This will generate your website using the built-in Foundation theme:
try Mberk().publish(using: [
    .installPlugin(.highlightJS()),
    .copyResources(),
    .addMarkdownFiles(),
    .generateHTML(withTheme: .mberk),
    .generateRSSFeed(including: [.posts]),
    .generateSiteMap(),
    .deploy(using: .gitHub("MichaelJBerk/MberkWebsite"))
])
