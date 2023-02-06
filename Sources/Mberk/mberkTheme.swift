import Foundation
import Plot
import Publish

extension Theme where Site == Mberk {
    static var mberk: Self {
        print(FileManager.default.currentDirectoryPath)
        return Theme(htmlFactory: MberkHTMLFactory(),
                     resourcePaths: ["styles.css", "hl.css",])
    }
}

private struct Projrow: Component {
    var title: String
    var info: Component
    var imageURL: URLRepresentable
    var imageDescription: String
    var projectLink: URLRepresentable
    var body: Component {
        Div {
            Div {
                titleComp
            }
            .class("smallWidth-proj-title")
            Div {
               Link(url: projectLink) {
                Image(url: imageURL, description: imageDescription)
               }
            }
            .class("projrow-image")
            Div {
                titleComp
                    .class("fullWidth-proj-title")
                info
            }
            .class("projrow-text")
        }
        .class("projrow")
    }

    private var titleComp: Component {
        Link(url: projectLink) {
            Paragraph(title)
                .class("project-title")
        }
    }
}

private struct Homepage: Component {
    var body: Component {
        Div {
            Projrow(title: "Splitter", info: Paragraph("The Speedrunning Timer for macOS"), imageURL: "images/Splitter-icon.png", imageDescription: "Splitter Icon", projectLink: "http://splitter.mberk.com")

            Projrow(title: "Siddur + Tehillim Anywhere", info: Text("The Jewish prayer book, on your iPhone or iPad.").addLineBreak() + Text("Includes Nusach Ashkenaz, Sefard, and Edot HaMizrach"), imageURL: "images/Siddur-icon.jpg", imageDescription: "Siddur Icon", projectLink: "https://apps.apple.com/us/app/siddur-tehilim-anywhere/id1455032858")

            Projrow(title: "Zmanim", info: Paragraph("Keep track of Zmanim on iPhone and iPad"), imageURL: "images/Zmanim-icon.png", imageDescription: "Zmanim Icon", projectLink: "https://apps.apple.com/us/app/zmanim/id1534265457")
        }
        .class("projlist")
    }
}

struct MBerkPage: Component {
    var context: Publish.PublishingContext<Mberk>
    var selectedSectionID: Mberk.SectionID?
    @ComponentBuilder var pageContents: () -> Component

    var body: Component {
        Div {
            SiteHeader(context: context, selectedSelectionID: selectedSectionID)
            pageContents()
            SiteFooter()
        }.class("page")
    }
}

private struct MberkHTMLFactory: HTMLFactory {
    func makeProjectsHTML(context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML {
        HTML(
            .lang(context.site.language),
            .head(for: context.sections[.projects], on: context.site),
            .body {
                MBerkPage(context: context, selectedSectionID: .projects) {
                    Div {
                        H2("Projects")
                        Homepage()
                    }
                    .class("main-card")
                }
            }
        )
    }
    func makeIndexHTML(for index: Publish.Index, context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML {
        HTML(
            .head(.meta(.attribute(named: "http-equiv", value: "Refresh"),
                            .attribute(named: "content", value: "0; url='\(context.sections[.posts].path.absoluteString)'")))
            // .lang(context.site.language),
            // .head(for: index, on: context.site),
            // .body {
            //     MBerkPage(context: context, selectedSectionID: .projects) {
            //         Div {
            //             H2("Projects")
            //             Homepage()
            //         }
            //         .class("main-card")
            //     }
            // }
        )
    }

    func makeSectionHTML(for section: Publish.Section<Mberk>, context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML {
        if section.id == .projects {
           return try makeProjectsHTML(context: context)
            // if projects, return index
            // return HTML(
            //     .head(.meta(.attribute(named: "http-equiv", value: "Refresh"),
            //                 .attribute(named: "content", value: "0; url='\(context.index.path.absoluteString)'")))
            // )
        }

        return HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body {
                MBerkPage(context: context, selectedSectionID: section.id) {
                    Wrapper {
                        ItemList(items: section.items, site: context.site)
                    }
                }
            }
        )
    }

    func makeItemHTML(for item: Publish.Item<Mberk>, context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site, stylesheetPaths: ["styles.css", "hl.css"]),
            .body {
                MBerkPage(context: context, selectedSectionID: .posts) {
                    Div {
                        Article { item.content.body }
                            .class("content")
                        ItemTagList(tags: item.tags, site: context.site)
                    }
                    .class("main-card")
                }
            }
        )
    }

    func makePageHTML(for page: Publish.Page, context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                MBerkPage(context: context) {
                    Div {
                        page.content.body
                    }
                    .class("main-card")
                }
            }
        )
    }

    func makeTagListHTML(for page: Publish.TagListPage, context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                MBerkPage(context: context, selectedSectionID: .posts) {
                    Div {
                        // H1("Browse all tags")
                        ItemTagList(tags: page.tags.sorted(), site: context.site)
                            .class("all-tags")
                    }
                    .class("main-card")
                }
            }
        )
    }

    func makeTagDetailsHTML(for page: Publish.TagDetailsPage, context: Publish.PublishingContext<Mberk>) throws -> Plot.HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                MBerkPage(context: context, selectedSectionID: .posts) {
                    Wrapper {
                        H3 {
                            Text("Tagged with ")
                            Span(page.tag.string).class("tag")
                        }

                        Link("Browse all tags",
                             url: context.site.tagListPath.absoluteString)
                            .class("browse-all")

                        ItemList(
                            items: context.items(
                                taggedWith: page.tag,
                                sortedBy: \.date,
                                order: .descending
                            ),
                            site: context.site
                        )
                    }
                }
            }
        )
    }
}

private struct ItemList: Component {
    var items: [Item<Mberk>]
    var site: Mberk

    var body: Component {
        List(items) { item in
            Div {
                H3(Link(item.title, url: item.path.absoluteString))
                ItemTagList(tags: item.tags, site: site)
                Paragraph(item.description)
            }
            .class("main-card")
        }
        .class("item-list")
    }
}

private struct ItemTagList: Component {
    var tags: [Tag]
    var site: Mberk

    var body: Component {
        Div {
            Div {
                Text("Tags:")
            }
            for tag in tags {
                Div {
                    Link(tag.string, url: site.path(for: tag).absoluteString)
                }
                .class("tag")
            }
        }.class("tag-list-container")
    }
}

private struct Wrapper: ComponentContainer {
    @ComponentBuilder var content: ContentProvider

    var body: Component {
        Div(content: content).class("wrapper")
    }
}

private struct SiteHeader: Component {
    var context: PublishingContext<Mberk>
    var selectedSelectionID: Mberk.SectionID?

    var body: Component {
        Header {
            Div {
                Div {
                    Link(context.site.name, url: "/")
                }
                .class("head-title")

                Div {
                    navigation
                }
                .class("head-nav")
            }
            .class("head")
        }
    }

    func navLink(title: String, url: URLRepresentable, sectionID: Mberk.SectionID?, linkTarget: HTMLAnchorTarget? = nil) -> Component {
        Link(title, url: url)
            .linkTarget(linkTarget)
            .class("nav-item")
            .class(sectionID != nil && sectionID == selectedSelectionID ? "selected" : "")
    }

    private var navigation: Component {
        Navigation {
            List {
                navLink(title: "Posts", url: context.sections[.posts].path.absoluteString, sectionID: .posts)
                navLink(title: "Projects", url: context.sections[.projects].path.absoluteString, sectionID: .projects)
                navLink(title: "Tip Jar", url: "https://donate.stripe.com/4gw3dT31RgDf4la9AA", sectionID: nil, linkTarget: .blank)
                    .class("tipJar")
            }
        }
    }
}

private struct SiteFooter: Component {
    var body: Component {
        Footer {
            Paragraph {
                Text("Generated using ")
                Link("Publish", url: "https://github.com/johnsundell/publish")
            }
            Paragraph {
                Link("RSS feed", url: "/feed.rss")
            }
        }
    }
}
