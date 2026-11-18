# Servers

The app reads one Kano Navi service at a time, the selected server. Every
service runs the same [`kano-navi`](https://github.com/yexca/kano-navi) Public
API, but each is its own instance with its own records and revisions, so the
app treats a switch as reading a different data source.

## Server List

`ServerList` (`KanoNaviCore`) holds the built-in servers, then the servers the
person added in the order they were added, and the selected server's ID.

- **Built-in servers** come from the build configuration, never from code:
  `API_BASE_URL` (`japan`, the default) and `MAINLAND_API_BASE_URL`
  (`mainlandChina`), exposed as `KanoNaviAPIBaseURL` and
  `KanoNaviMainlandAPIBaseURL` in `Info.plist` and `Widgets-Info.plist` and
  read by `AppConfiguration`. An empty `MAINLAND_API_BASE_URL` ships the build
  without that server. The app localizes built-in names (`serverJapan`,
  `serverMainlandChina`) and cannot remove them.
- **Added servers** (`ServiceServer.custom`) carry the name the person typed
  (the address when left empty) and an ID of `custom-` and a UUID. An address
  already listed is refused.
- `ServerListStore` saves the added servers (JSON under `customServers`) and
  the selection (`selectedServer`) in `UserDefaults`. An unknown saved
  selection, or removing the selected server, selects the default.

## Adding a Server

`ServerAddress.parse` reads a typed address: a bare host gets `https://`, the
host is lowercased, and a trailing slash is dropped. Another scheme, user info,
a query, or a fragment is refused, so every server is HTTPS and the app needs no
App Transport Security exception. A path is kept, for a service behind a path
prefix.

Before adding the address, `ServerCheck.verify` reads `/api/dashboard?days=1`
from it without caching. The address is added and selected only when the
dashboard decodes with `projection.version` `1`; no response is reported as
unreachable and any other response as incompatible.

## Switching

`AppSession` owns the server list and builds `AppServices` (the `APIClient`
and `CalendarReader`) and a `DashboardStore` with its revision stream for the
selected server. `SessionEnvironment` puts them in each scene's environment.
Selecting another server:

- stops the last dashboard store and builds new services and a new store, which
  `RootView` starts while the scene is active;
- restarts each screen that reads the services (`.id` on the client's base
  URL), so Now, Schedule, Posts, Videos, Journey, Works, and LINE BLOG open on
  the new server's saved copy;
- points notifications at the new server and drops the diff baseline (see
  [Notifications](notifications.md#server-switching)).

Responses and media are cached by URL, so each server keeps its own saved copy
and switching back shows it at once. About links the selected server's origin
as the web board.

## Widgets

Widgets cannot read the app's selection without an App Group. Each Upcoming
widget has its own **Server** parameter (`WidgetServer`) offering the built-in
servers, the default first; a built-in server the build leaves out reads the
default. Servers added in the app are not offered. See [Widgets](widgets.md).
