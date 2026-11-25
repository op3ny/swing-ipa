import Foundation
import Observation

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    static let lyricsFocusPositionRange = 0.05 ... 0.8
    static let lyricsCurrentLineScaleRange = 1.0 ... 1.5
    static let lyricsFocusCascadeChaseSpeedGradientRange = 0.0 ... 1.0
    static let lyricsFocusCascadeBounceRange = 0.0 ... 0.8
    static let lyricsFocusCascadeBounceGradientRange = 0.0 ... 1.0
    static let lyricsFocusScaleBounceRange = 0.0 ... 0.5
    static let lyricsFocusScaleBounceDurationRange = 0.15 ... 0.8
    static let lyricsFocusColorLeadTimeRange = -0.3 ... 0.3

    @Published var lyricsFontSize: Double = 32.0
    @Published var lyricsFontWeight: LyricsFontWeight = .heavy
    @Published var lyricsCurrentLineScale: Double = 1.02
    @Published var lyricsLineSpacing: Double = 28.0
    @Published var lyricsBlurIntensity: Double = 0.8
    @Published var lyricsUsesUniformDimmingWhileBrowsing: Bool = true
    @Published var lyricsDistanceBlurScale: Double = 1.05
    @Published var lyricsHiddenInterfaceBlurScale: Double = 0.85
    @Published var lyricsDimAmount: Double = 1.0

    @Published var lyricsTapToSeek: Bool = true
    @Published var lyricsLongPressToShare: Bool = true
    @Published var lyricsAutoFollow: Bool = true
    @Published var lyricsFollowDelay: Double = 3
    @Published var appleMusicLyricsScrollHideThreshold: Double = 200.0

    @Published var lyricsWordByWord: Bool = true
    @Published var lyricsPseudoWordByWord: Bool = false
    @Published var lyricsLiftMode: LyricsLiftMode = .character
    @Published var lyricsHighlightGradientWidth: Double = 0.7
    @Published var lyricsHighlightGradientReduction: Double = 0.65
    @Published var lyricsEmphasisStyle: LyricsEmphasisStyle = .amll

    @Published var lyricsGlowEnabled: Bool = true
    @Published var lyricsGlowIntensity: Double = 1
    @Published var lyricsGlowLongSyllablesOnly: Bool = true
    @Published var lyricsLongSyllableDetectionMode: LyricsLongSyllableDetectionMode = .character
    @Published var lyricsLongSyllableDurationThreshold: Double = 0.95
    @Published var lyricsLongToneExpansionAmount: Double = 0.05

    @Published var lyricsFocusPosition: Double = 0.25
    @Published var lyricsFocusCascadeDelay: Double = 0.021
    @Published var lyricsFocusCascadeDelayIncrease: Double = 0.005
    @Published var lyricsFocusCascadeFollowingDelay: Double = 0.048
    @Published var lyricsFocusCascadeCatchUpRatio: Double = 0.97
    @Published var lyricsFocusCascadeChaseSpeedGradient: Double = 0.70
    @Published var lyricsFocusCascadeDuration: Double = 0.74
    @Published var lyricsFocusSnapThreshold: Double = 0.26
    @Published var lyricsFocusCascadeBounceEnabled: Bool = true
    @Published var lyricsFocusCascadeBounce: Double = 0.26
    @Published var lyricsFocusCascadeBounceGradient: Double = 0.85
    @Published var lyricsFocusScaleBounceEnabled: Bool = true
    @Published var lyricsFocusScaleBounce: Double = 0.32
    @Published var lyricsFocusScaleBounceDuration: Double = 0.58
    @Published var lyricsFocusColorLeadTime: Double = 0.0

    @Published var lyricsInterludeCountdownEnabled: Bool = true

    @Published var lyricsTranslationEnabled: Bool = true
    @Published var lyricsTranslationDisplayMode: LyricsTranslationDisplayMode = .focusedLine
    @Published var lyricsTranslationFontScale: Double = 0.65
    @Published var lyricsTranslationOpacity: Double = 0.9
    @Published var lyricsRomanizationEnabled: Bool = true
    @Published var lyricsRomanizationDisplayMode: LyricsTranslationDisplayMode = .focusedLine
    @Published var lyricsRomanizationFontScale: Double = 0.65
    @Published var lyricsRomanizationOpacity: Double = 0.9

    @Published var lyricsAdvanceTime: Double = 0.15
    @Published var lyricsAdvanceTimeAppliesToWordByWord: Bool = true

    var wordByWordLyricsAdvanceTime: TimeInterval {
        lyricsAdvanceTimeAppliesToWordByWord ? lyricsAdvanceTime : 0
    }

    func effectiveLyricsAdvanceTime(hasSyllableSyncedLyrics: Bool) -> TimeInterval {
        hasSyllableSyncedLyrics ? wordByWordLyricsAdvanceTime : lyricsAdvanceTime
    }

    func effectiveLyricsAdvanceTime(for lyrics: [MXLyricLine]) -> TimeInterval {
        effectiveLyricsAdvanceTime(
            hasSyllableSyncedLyrics: lyrics.contains(where: \.isSyllableSynced)
        )
    }
}
