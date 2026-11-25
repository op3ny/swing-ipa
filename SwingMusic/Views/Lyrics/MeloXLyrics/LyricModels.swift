import SwiftUI
import Foundation

struct LyricSyllable: Identifiable, Hashable {
    let text: String
    let startTime: TimeInterval
    let endTime: TimeInterval

    var id: String {
        "\(startTime)-\(endTime)-\(text)"
    }
}

struct MXLyricLine: Identifiable, Hashable {
    let time: TimeInterval
    let duration: TimeInterval?
    let text: String
    let syllables: [LyricSyllable]
    let romanization: String?
    let romanizationSyllables: [LyricSyllable]
    let translation: String?

    init(
        time: TimeInterval,
        duration: TimeInterval? = nil,
        text: String,
        syllables: [LyricSyllable] = [],
        romanization: String? = nil,
        romanizationSyllables: [LyricSyllable] = [],
        translation: String? = nil
    ) {
        self.time = time
        self.duration = duration
        self.text = text
        self.syllables = syllables
        self.romanization = romanization
        self.romanizationSyllables = romanizationSyllables
        self.translation = translation
    }

    var id: String {
        "\(time)-\(text)"
    }

    var isSyllableSynced: Bool {
        !syllables.isEmpty
    }

    var hasTranslation: Bool {
        guard let translation else { return false }
        return !translation
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    var hasRomanization: Bool {
        guard let romanization else { return false }
        return !romanization
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    func makePseudoSyllables() -> [LyricSyllable] {
        guard syllables.isEmpty,
              let duration,
              duration > 0 else { return [] }

        let characters = Array(text)
        guard !characters.isEmpty else { return [] }

        let characterDuration = duration / Double(characters.count)
        return characters.enumerated().map { index, character in
            let startTime = time + Double(index) * characterDuration
            return LyricSyllable(
                text: String(character),
                startTime: startTime,
                endTime: startTime + characterDuration
            )
        }
    }

    func attachingTranslation(_ translation: String?) -> MXLyricLine {
        MXLyricLine(
            time: time,
            duration: duration,
            text: text,
            syllables: syllables,
            romanization: romanization,
            romanizationSyllables: romanizationSyllables,
            translation: translation
        )
    }

    func attachingRomanization(
        _ romanization: String?,
        romanizationSyllables: [LyricSyllable] = []
    ) -> MXLyricLine {
        MXLyricLine(
            time: time,
            duration: duration,
            text: text,
            syllables: syllables,
            romanization: romanization,
            romanizationSyllables: romanizationSyllables,
            translation: translation
        )
    }

    func accessibilityText(
        includingTranslation: Bool,
        includingRomanization: Bool = false
    ) -> String {
        var components = [text]
        if includingRomanization, hasRomanization,
           let romanization {
            components.append("Pronunciation: \(romanization)")
        }
        if includingTranslation, hasTranslation,
           let translation {
            components.append("Translation: \(translation)")
        }
        return components.joined(separator: "，")
    }
}


// MARK: - iOS 16 compatibility stubs
// The original MeloX lyrics renderer relies on Text.Layout / customAttribute
// (iOS 17+). Those three source files are excluded from the iOS 16 target;
// these minimal stand-ins keep the remaining lyrics code compiling.

struct LyricTimingTextAttribute: Hashable, Sendable {
    let startTime: TimeInterval
    let endTime: TimeInterval
    let syllableStartTime: TimeInterval
    let syllableEndTime: TimeInterval
    let characterIndex: Int
    let characterCount: Int
    let wordStartTime: TimeInterval
    let wordEndTime: TimeInterval
    let wordCharacterIndex: Int
    let wordCharacterCount: Int
    let usesWordTimingForLongTone: Bool
    let isWhitespace: Bool
    var isLastWordInLine: Bool = false
}

enum LyricRubyTextBuilder {
    static func originalText(from units: [LyricRubyPlacementUnit]) -> Text {
        Text(verbatim: units.map(\.lyric.originalText).joined())
    }

    static func romanizationText(from units: [LyricRubyPlacementUnit]) -> Text {
        Text(verbatim: units.compactMap(\.lyric.romanizationText).joined())
    }
}

struct CompatUnavailableView: View {
    let title: String
    let systemImage: String
    let description: Text?

    init(_ title: String, systemImage: String, description: Text? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
    }

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 38, weight: .light))
            Text(title)
                .font(.title3.weight(.semibold))
            if let description {
                description
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    static func search(text: String) -> CompatUnavailableView {
        CompatUnavailableView(
            "No results for \(text)",
            systemImage: "magnifyingglass"
        )
    }
}

extension View {
    @ViewBuilder
    func compatOnChange<Value: Equatable>(
        of value: Value,
        initial: Bool = false,
        _ action: @escaping (Value, Value) -> Void
    ) -> some View {
        onChange(of: value) { action($0, $0) }
    }

    @ViewBuilder
    func compatOnChange<Value: Equatable>(
        of value: Value,
        initial: Bool = false,
        _ action: @escaping () -> Void
    ) -> some View {
        onChange(of: value) { _ in action() }
    }
}
