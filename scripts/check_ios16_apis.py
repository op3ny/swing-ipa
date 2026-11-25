#!/usr/bin/env python3
"""Static check for iOS 17+/18+/26 APIs that cannot compile with an iOS 16 target."""
import re
import sys
from pathlib import Path

ROOT = Path(sys.argv[1] if len(sys.argv) > 1 else '/media/thais/Meus Arquivos/SWING-IOS/build-ios16')
SRC = ROOT / 'SwingMusic'

# (pattern, min iOS, description)
RULES = [
    (r'@Observable\b', 17, 'Observation framework'),
    (r'@ObservationIgnored\b', 17, 'Observation ignore'),
    (r'@Bindable\b', 17, 'Bindable'),
    (r'@Previewable\b', 17, 'Previewable'),
    (r'\bContentUnavailableView\b', 17, 'ContentUnavailableView'),
    (r'\.onChange\(\s*of:[^\n]*\binitial\s*:', 17, 'onChange(initial:)'),
    (r'\.contentMargins\(', 17, 'contentMargins'),
    (r'\.scrollTargetLayout\(', 17, 'scrollTargetLayout'),
    (r'\.scrollTargetBehavior\(', 17, 'scrollTargetBehavior'),
    (r'\.scrollClipDisabled\(', 17, 'scrollClipDisabled'),
    (r'\.safeAreaPadding\(', 17, 'safeAreaPadding'),
    (r'\.listSectionSpacing\(', 17, 'listSectionSpacing'),
    (r'\.symbolEffect\(', 17, 'symbolEffect'),
    (r'\.sensoryFeedback\(', 17, 'sensoryFeedback'),
    (r'\.containerRelativeFrame\(', 17, 'containerRelativeFrame'),
    (r'\.frame\(in:\s*\.scrollView\)', 17, 'scrollView coordinate space'),
    (r'\.onScrollGeometryChange\(', 17, 'onScrollGeometryChange'),
    (r'\bText\.Layout\b', 17, 'Text.Layout'),
    (r'\bTab\("', 18, 'iOS 18 Tab'),
    (r'\.tabViewStyle\(\.sidebarAdaptable\)', 18, 'sidebarAdaptable'),
    (r'\.tabBarMinimizeBehavior\(', 26, 'tabBarMinimizeBehavior'),
    (r'\bMeshGradient\(', 18, 'MeshGradient'),
    (r'\.presentationSizing\(', 18, 'presentationSizing'),
    (r'\.matchedTransitionSource\(', 18, 'matchedTransitionSource'),
    (r'\.navigationTransition\(', 18, 'navigationTransition'),
    (r'\.glassEffect\(', 26, 'glassEffect'),
    (r'\bGlassEffectContainer\b', 26, 'GlassEffectContainer'),
    (r'\.buttonStyle\(\.glass\)', 26, 'glass button style'),
    (r'\bButton\([^)]*role:\s*\.confirm', 26, 'confirm button role'),
    (r'\.gesture\(\s*HorizontalPan', 18, 'HorizontalPan gesture'),
    (r'\.accessibilityDimFlashingLights\b', 17, 'accessibilityDimFlashingLights'),
]

# Files excluded from the iOS 16 Xcode target (iOS 17-only TextRenderer stack).
EXCLUDED = {
    'LyricGlowTextRenderer.swift', 'LyricLineFitting.swift', 'LyricRubyTextBuilder.swift',
}

problems = []
for p in list(SRC.rglob('*.swift')) + list((ROOT / 'SwingMusicWidgetExtension').rglob('*.swift')):
    if p.name in EXCLUDED:
        continue
    for lineno, line in enumerate(p.read_text().splitlines(), 1):
        if line.strip().startswith('//'):
            continue
        for pat, minios, desc in RULES:
            if re.search(pat, line):
                problems.append((str(p.relative_to(ROOT)), lineno, minios, desc, line.strip()[:100]))

if problems:
    print(f'FOUND {len(problems)} iOS 16 compatibility issues:')
    for f, l, ios, desc, src in problems:
        print(f'  iOS {ios}+ {f}:{l} [{desc}] {src}')
    sys.exit(1)
print(f'iOS 16 API CHECK OK ({len(list(SRC.rglob("*.swift")))} files scanned)')
