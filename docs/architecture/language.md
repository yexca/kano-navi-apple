# Language

Kano Navi separates interface localization from content translation, matching
the `kano-navi` web board.

## Interface Language

- English (`en`) is the base and fallback locale; Japanese (`ja`) and Simplified
  Chinese (`zh-Hans`) are supported via Xcode String Catalogs (`.xcstrings`)
  with generated Swift symbols (feature tables are namespaced, such as
  `Text(.Schedule.today)`).
- The app follows the system's per-app language setting. **More → Settings → App
  Language** opens the system per-app language screen on iOS/iPadOS and Language
  & Region on macOS.

## Content Language

- **More → Settings → Content Language** (`ContentLanguageOption`) lets users
  pick **Same as app** (default), English, 日本語, or 简体中文 independently of
  the interface language. Widgets expose the same choice through
  `UpcomingConfigurationIntent`.
- The API's `zh-CN` locale key maps to the app's `zh-Hans`.
- `ContentLanguageResolver` resolves post text, video titles, and schedule
  titles for target locale `L`:
  1. Use `translations[L]` when present, except that Japanese keeps wording
     whose `sourceLanguage` is `ja` as written.
  2. Otherwise display the original source wording.
- Translated entries show a small translation mark naming the translation origin
  (`manual`, `platform`, or `machine`) and can toggle back to the original in
  place.
- Archive reads (`Journey`, `Works`, `LINE BLOG`) use `LocalizedText`
  (`{"ja", "zh-CN", "en"}`), preferring the chosen content language if
  non-empty and falling back in `defaultFallback` order (`en`, `ja`, `zh-CN`)
  or `japaneseOriginalFallback` (`ja`, `en`, `zh-CN`) for LINE BLOG.

## Display Codes

API display codes (states, types, tags, platforms, forms, milestone kinds,
credits, recovery notes) are never sent back as localized strings and never rely
on the content language setting. They translate exclusively in the app's
interface language through `DisplayCodeLabels` in `KanoNaviCore` and feature
String Catalogs (`Journey.xcstrings`, `Works.xcstrings`, `LineBlog.xcstrings`),
each providing a neutral fallback for unknown codes.

## Related Docs

- [API and caching](api-and-caching.md)
- [Design and interaction](../development/design.md)
