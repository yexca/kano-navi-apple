# Design and Interaction

Kano Navi for iOS and macOS uses native Apple platform idioms while preserving
the web board's scannable hierarchy, Japan-time clarity, and source
traceability.

## Visual Language

- **Typography and iconography:** System fonts (rounded system font in Home
  Screen widgets; Hiragino Sans for fixed Japanese copy, so it keeps Japanese
  glyphs in every interface language), SF Symbols, and semantic system colors
  across light and dark appearances.
- **Platform logos:** YouTube, X, and Bilibili use custom monochrome vector
  symbols in `PlatformLogos.xcassets` built from Simple Icons so they tint and
  scale like SF Symbols; other platforms and sites use SF Symbols. See
  [PlatformLogos README](../../Packages/KanoNaviKit/Sources/KanoNaviComponents/Resources/PlatformLogos.xcassets/README.md).
- **Accent and category colors:** Home Screen widgets use the Berry accent
  (`#DC4560` light, `#FF7088` dark). `ScheduleTag` and `JourneyColors.xcassets`
  keep text at ≥ 4.5:1 contrast across light/dark system backgrounds, Details
  tints, tag pills, and highlight cards (dark Berry adjusts to `#FF768E` on
  macOS `#1E1E1E` dark backgrounds).
- **Status cues:** Live state uses a red dot and the word "Live" (never color
  alone). Members-only items carry a members chip. Cancelled and suspected
  cancellations are struck through or badged with their state in words.
- **Branding and media:** No official logos or branding, and no custom artwork
  beyond the app icon (derived from the web board's avatar). The widget
  extension bundles a small copy for Large and Extra Large headers. API media is
  displayed as served without alteration.

## Concise UI Rules

- Prefer a label, an icon, or a short phrase over a full sentence.
- Format external platform links as logo + name (`YouTube`, `Bilibili`; X's
  logo alone since it is the name), not "Open on …" (the Now profile card's
  round YouTube and Bilibili buttons are the one exception documented in
  [Board and timelines](../architecture/board-and-timelines.md#now)).
- Omit or fold low-frequency explanations (data provenance details, curation
  notes, rights notices) behind an info button.
- Keep error, saved-copy, and empty states to one short line each with a
  **Try Again** control where recovery applies.

## Interaction and Responsive Review

Every screen must remain usable at the largest Dynamic Type accessibility size
(`AX5`): rows wrap rather than truncate important times or titles, and captions
or headers scroll or adapt so core content stays visible.

Check affected UI before finishing visual changes across:

- Small iPhone and large iPhone simulators, in light and dark appearance, across
  English, Japanese, and Simplified Chinese, and at the largest Dynamic Type
  size.
- iPad simulator (resizable window/split widths and orientations), in light and
  dark appearance.
- Native Mac window at minimum/small and large window sizes, in light and dark
  appearance.

## Related Docs

- [User guide](../user/index.md)
- [Board and timelines](../architecture/board-and-timelines.md)
- [Language](../architecture/language.md)
- [Testing](testing.md)
