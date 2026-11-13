# Local HTTPS backend

This tool runs a local checkout of
[`kano-navi`](https://github.com/yexca/kano-navi) with an isolated SQLite snapshot and synthetic, time-relative records. The API
is served through a local HTTPS proxy so the iOS app can use the same transport
rules as production.

Prerequisites are Go (the version `kano-navi`'s `backend/go.mod` requires),
Python 3, OpenSSL, curl and Xcode's `xcrun simctl`. The tool finds the
`kano-navi` checkout through `KANO_CHECKOUT`, or in a `kano` folder next to
this repository, and never writes inside it. Set `GO` to use a Go binary that
is not on `PATH`.

Run these commands from the iOS repository:

```sh
Tools/local-backend/local-backend start
Tools/local-backend/local-backend restart
Tools/local-backend/local-backend status
Tools/local-backend/local-backend logs
Tools/local-backend/local-backend reseed
Tools/local-backend/local-backend stop
```

`start` builds the backend from the checkout only when none is running, so
after the checkout changes run `restart` to serve its current code.

The default HTTPS endpoint is `https://localhost:8443`. Set
`KANO_LOCAL_HTTPS_PORT` to use another HTTPS port, and
`KANO_LOCAL_BACKEND_PORT` to change the loopback HTTP port used internally.
State, the private CA and leaf certificate, logs, PIDs, the built binaries,
the isolated `.env`, database, empty static directory and cached PNGs live in
`Tools/local-backend/.state/`.

Point the app at the service by running
`Tools/local-backend/local-backend configure-app`; this writes the ignored
`Config/Local.xcconfig`. Remove it with `unconfigure-app`. The generated CA is
trusted only by iOS simulators, with:

```sh
Tools/local-backend/local-backend trust-simulators "iPhone 17e" "iPhone 17 Pro Max"
```

The command writes the CA into the trust store of each named simulator (name
or UDID), or of every booted iOS simulator when none is named, the same row `xcrun simctl keychain add-root-cert` writes
(that command hangs on this Xcode). It shuts a booted simulator down for the
write and boots it again. It never changes the macOS login or system keychain.
The database contains synthetic titles,
URLs, posts, events, videos, translations and PNG media. `reseed` rebuilds
those records relative to the current Japan time while preserving the server's
schema, so old snapshots intentionally become stale unless reseeded.

The Journey, Works and LINE BLOG reads (`/api/journey`, `/api/works`,
`/api/lineblog` and the reads below them) answer with the bodies the
checkout's build embeds, which are the real archive data. Their media are
runtime files of the checkout: `start` links `data/journey/`, `data/works/`
and `data/lineblog/` of the checkout into the isolated data directory, which
the server only reads, and copies the prebuilt smaller copies from
`data/cache/variants/`. A checkout without those folders serves the reads and
answers 404 `media_not_found` for their media.
