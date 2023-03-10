import SwiftSyntax
import SwiftSyntaxParser
import SwiftDiagnostics
import _SwiftSyntaxMacros

#if canImport(Darwin)
import struct Foundation.URL
#elseif canImport(FoundationNetworking)
import struct FoundationNetworking.URL
#endif

public enum URLMacro: ExpressionMacro {
    public static func expansion(
        of node: MacroExpansionExprSyntax,
        in context: inout MacroExpansionContext
    ) throws -> ExprSyntax {
        // print(#line, node)
        guard let (arguments, argument) = validate(node.argumentList) else {
            // TODO: compile error
            context.diagnose(
                SwiftDiagnostics.Diagnostic(
                    node: Syntax(node.argumentList),
                    message: ErrorDiagnostic(
                        message: "Invalid URL: `\(node.argumentList.first?.expression.description ?? "")`"
                    )
                )
            )
            return ExprSyntax(node)
        }
        let argumentList = arguments.replacing(
            childAt: 0,
            with: argument
                .withLabel(.identifier("string"))
                .withColon(.identifier(":").withTrailingTrivia(.space))
        )
        return ExprSyntax(
            ForcedValueExprSyntax(
                expression: FunctionCallExprSyntax(
                    calledExpression: IdentifierExprSyntax(identifier: TokenSyntax(.stringSegment("URL"), presence: .present)),
                    leftParen: TokenSyntax(.leftParen, presence: .present),
                    argumentList: argumentList,
                    rightParen: TokenSyntax(.rightParen, presence: .present)
                )
            )
        )
    }
}

extension URLMacro {
    static func validate(_ elementList: TupleExprElementListSyntax?) -> (TupleExprElementListSyntax, TupleExprElementSyntax)? {
        guard let elementList,
              let element = elementList.first,
              let expression = element.expression
            .as(StringLiteralExprSyntax.self) else { return nil }
        let segments = expression.segments
        guard case let .stringSegment(segment) = segments.first,
              segment.contentLength.utf8Length > 0 else { return nil }
        #if canImport(Darwin) || canImport(FoundationNetworking)
        guard let _ = URL(string: segment.content.text) else { return nil }
        #else
        let content = segment.content.text
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return nil }
        #endif
        return (elementList, element)
    }
}

extension URLMacro {
    struct ErrorDiagnostic {
        let message: String
    }
}

extension URLMacro.ErrorDiagnostic: DiagnosticMessage {
    var diagnosticID: MessageID {
        .init(domain: "SwiftMacros", id: "URLMacro.ErrorDiagnostic")
    }
    var severity: DiagnosticSeverity { .error }
}
