# Local Development

## Prerequisites

- Xcode 27 or later with iOS 26.5 (or newer) Simulator runtimes and macOS 26 SDK
- Swift 6 toolchain (bundled with Xcode)
- Python 3 (for repository validation scripts and the local backend seeder)
- Optional for local API integration ([Tools/local-backend/README.md](../../Tools/local-backend/README.md)):
  Go (matching `kano-navi`'s `backend/go.mod`), OpenSSL, and `curl`

## Configuration

`Config/Base.xcconfig` sets `API_BASE_URL` to the production Kano Navi HTTPS
origin (`https://kano.yexca.net`, written as `https:/$()/kano.yexca.net`
because `//` starts a comment in `.xcconfig` files).

An optional, git-ignored `Config/Local.xcconfig` overrides `API_BASE_URL` for a
single machine (such as a local backend endpoint). Both `Info.plist` and
`Widgets-Info.plist` expose `API_BASE_URL` via `KanoNaviAPIBaseURL`.

## Local HTTPS Backend

`Tools/local-backend/` runs a local checkout of
[`kano-navi`](https://github.com/yexca/kano-navi) with an isolated SQLite
snapshot, synthetic time-relative data, and a local HTTPS TLS proxy so the app
uses the same HTTPS transport rules as production. See
[Tools/local-backend/README.md](../../Tools/local-backend/README.md) for
`start`, `restart`, `reseed`, `trust-simulators`, `configure-app`, and
`unconfigure-app`.

## Formatting

Format Swift code with `swift format` using `.swift-format` (4-space
indentation, 110-column line limit):

```bash
make format
make format-check
```

Fix compiler and strict-concurrency warnings at their source. Do not silence
warnings with `@unchecked Sendable`, `nonisolated(unsafe)`, or `@preconcurrency`
unless a comment explains why the annotation is invariant-safe.

## Change Workflow

1. Read [AGENTS.md](../../AGENTS.md) and the docs for the area you are changing,
   then inspect `git status --short`.
2. Preserve existing user changes and work within existing target/package
   boundaries.
3. Run proportional validation from [Testing](testing.md) and `make ci-fast`.
4. Review `git diff --cached` before any requested commit; keep configured
   commit signing enabled.

## Related Docs

- [Testing and validation](testing.md)
- [Design and interaction](design.md)
- [Secure development](security.md)
- [Commit and release](commit-and-release.md)
