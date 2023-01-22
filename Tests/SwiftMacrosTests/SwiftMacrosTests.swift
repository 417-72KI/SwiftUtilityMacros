import XCTest
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftMacros
@_spi(Testing) import _SwiftSyntaxMacros
// import _SwiftSyntaxTestSupport

final class SwiftMacrosTests: XCTestCase {
    func testUrl() throws {
        let sf: SourceFileSyntax = ##"""
        let a = #url("https://apple.com")
        let b = #url("""
        https://google.com
        """)
        let c = #url(#"https://github.com"#)
        let d = #url(#"""
            https://amazon.com
            """#)
        let e = #url("")
        let f = #url("""
        """)
        let g = #url("""

        """)
        """##

        var context = MacroExpansionContext(
            moduleName: "MyModule", fileName: "test.swift"
        )
        let transformedSF = sf.expand(
            macros: ["url": URLMacro.self],
            in: &context
        )
        XCTAssertEqual(
            transformedSF.description,
            ##"""
            let a = URL(string: "https://apple.com")!
            let b = #url("""
            https://google.com
            """)
            let c = URL(string: #"https://github.com"#)!
            let d = #url(#"""
                https://amazon.com
                """#)
            let e = #url("")
            let f = #url("""
            """)
            let g = #url("""

            """)
            """##
        )
        print(context.diagnostics)
        XCTAssertEqual(context.diagnostics.count, 5)
    }
}
