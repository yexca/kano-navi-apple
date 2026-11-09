#!/usr/bin/env python3
"""Seed the local Kano Navi snapshot with synthetic, time-relative records."""

from __future__ import annotations

import datetime as dt
import hashlib
import json
import os
import pathlib
import sqlite3
import struct
import sys
import urllib.parse
import zlib

UTC = dt.timezone.utc
JST = dt.timezone(dt.timedelta(hours=9))


def iso(value: dt.datetime) -> str:
    return value.astimezone(UTC).isoformat(timespec="milliseconds").replace("+00:00", "Z")


def japan_date(value: dt.datetime) -> str:
    return value.astimezone(JST).date().isoformat()


def add_days(value: dt.datetime, days: int) -> dt.datetime:
    return value + dt.timedelta(days=days)


def png_bytes(width: int, height: int, seed: int) -> bytes:
    rows = []
    r = (seed * 53 + 47) % 256
    g = (seed * 97 + 83) % 256
    b = (seed * 151 + 29) % 256
    for y in range(height):
        row = bytearray([0])
        for x in range(width):
            row.extend(((r + x * 3 + y * 5) % 256, (g + x * 5 + y * 2) % 256, (b + x * 2 + y * 7) % 256, 255))
        rows.append(bytes(row))

    def chunk(kind: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)

    raw = b"".join(rows)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


def ensure_image(data_root: pathlib.Path, key: str, seed: int, namespace: str, width: int = 96, height: int = 64) -> tuple[str, str, int]:
    content = png_bytes(width, height, seed)
    content_hash = hashlib.sha256(content).hexdigest()
    relative = pathlib.PurePosixPath(namespace, "sha256", content_hash[:2], content_hash + ".png")
    path = data_root / pathlib.Path(*relative.parts)
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists():
        path.write_bytes(content)
    return relative.as_posix(), content_hash, len(content)


def media(conn: sqlite3.Connection, data_root: pathlib.Path, now: str, url: str, source: str, seed: int, owner: tuple[str, str, str, int] | None = None) -> str:
    media_id = hashlib.sha256(url.encode()).hexdigest()
    namespace = source if source in {"x", "youtube", "bilibili", "niconico"} else "x"
    cache_path, content_hash, size = ensure_image(data_root, media_id, seed, namespace)
    conn.execute(
        """INSERT INTO media_assets
        (id,source,source_url,cache_path,mime_type,extension,byte_size,sha256,width,height,status,fetched_at,last_checked_at,last_seen_at,created_at,updated_at)
        VALUES (?,?,?,?,?,?,?,?,?,?, 'ready',?,?,?,?,?)
        ON CONFLICT(id) DO UPDATE SET source=excluded.source,source_url=excluded.source_url,cache_path=excluded.cache_path,
        mime_type=excluded.mime_type,extension=excluded.extension,byte_size=excluded.byte_size,sha256=excluded.sha256,
        width=excluded.width,height=excluded.height,status='ready',fetched_at=excluded.fetched_at,last_checked_at=excluded.last_checked_at,
        last_seen_at=excluded.last_seen_at,updated_at=excluded.updated_at""",
        (media_id, source, url, cache_path, "image/png", "png", size, content_hash, 96, 64, now, now, now, now, now),
    )
    if owner:
        owner_type, owner_id, role, position = owner
        conn.execute(
            "INSERT OR IGNORE INTO media_links(media_id,owner_type,owner_id,role,position,created_at,updated_at) VALUES(?,?,?,?,?,?,?)",
            (media_id, owner_type, owner_id, role, position, now, now),
        )
    return media_id


def translation_hash(text: str) -> str:
    return hashlib.sha256(text.strip().encode()).hexdigest()


def stream_identity(value: str | None) -> str:
    """Match the backend's SQLite identity helper enough for indexed writes."""
    if not value:
        return ""
    parsed = urllib.parse.urlparse(value.strip())
    host = (parsed.hostname or "").lower()
    if host in ("youtube.com", "www.youtube.com", "m.youtube.com"):
        video_id = urllib.parse.parse_qs(parsed.query).get("v", [""])[0]
        return "youtube:" + video_id if video_id else value.strip()
    if host == "youtu.be":
        return "youtube:" + parsed.path.strip("/").split("/")[0]
    if "bilibili.com" in host:
        return "bilibili:" + parsed.path
    return value.strip()


def add_translations(conn: sqlite3.Connection, owner_type: str, owner_id: str, field: str, text: str, source_language: str, source: str, now: str) -> None:
    digest = translation_hash(text)
    conn.execute(
        """INSERT INTO translation_states(owner_type,owner_id,field,source_hash,source_language,status,updated_at)
        VALUES(?,?,?,?,?,'succeeded',?)
        ON CONFLICT(owner_type,owner_id,field) DO UPDATE SET source_hash=excluded.source_hash,source_language=excluded.source_language,status='succeeded',updated_at=excluded.updated_at""",
        (owner_type, owner_id, field, digest, source_language, now),
    )
    values = {"en": f"Synthetic English: {text}", "ja": f"合成日本語: {text}", "zh-CN": f"合成中文: {text}"}
    for locale, translated in values.items():
        for origin, platform in (("manual", ""), ("platform", source), ("machine", "")):
            conn.execute(
                """INSERT OR REPLACE INTO translations(owner_type,owner_id,field,locale,origin,platform,text,source_hash,created_at,updated_at)
                VALUES(?,?,?,?,?,?,?,?,?,?)""",
                (owner_type, owner_id, field, locale, origin, platform, translated, digest, now, now),
            )


def event_row(event_id: str, source: str, title: str, start: dt.datetime, now: str, *, event_type: str = "event", tag: str | None = None, platform: str = "other", platforms: list[str] | None = None, url: str | None = None, end: dt.datetime | None = None, status: str | None = "confirmed", provenance: str = "automatic", locked: int = 0, cancellation: str = "none", starts_at: bool = True, ends_on: str | None = None, source_item_id: str | None = None) -> tuple:
    platforms = platforms or [platform]
    return (event_id, source, source_item_id, "synthetic", title, "Synthetic schedule detail", japan_date(start), iso(start) if starts_at else None, iso(end) if end else None, ends_on, "Asia/Tokyo", "exact" if starts_at else "date", status, event_type, tag, "synthetic", url, provenance, locked, cancellation, None, None, "Synthetic evidence", None, None, None, None, now, now, platform, json.dumps(platforms))


def main() -> int:
    if len(sys.argv) not in (3, 4):
        print("usage: seed.py DATABASE DATA_ROOT [--repair-profile]", file=sys.stderr)
        return 2
    db_path = pathlib.Path(sys.argv[1]).resolve()
    data_root = pathlib.Path(sys.argv[2]).resolve()
    if len(sys.argv) == 4 and sys.argv[3] == "--repair-profile":
        conn = sqlite3.connect(db_path)
        for slot in ("avatar", "banner"):
            path = data_root / "avatar" / f"{slot}.png"
            if not path.exists():
                continue
            content = path.read_bytes()
            digest = hashlib.sha256(content).hexdigest()
            conn.execute("UPDATE profile_media SET active_sha256=?,active_mime_type='image/png',status='ready',is_active=1 WHERE slot=?", (digest, slot))
        conn.commit()
        conn.close()
        return 0
    now_dt = dt.datetime.now(UTC)
    now = iso(now_dt)
    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA busy_timeout=10000")
    conn.execute("PRAGMA foreign_keys=ON")
    conn.create_function("stream_identity", 1, stream_identity, deterministic=True)

    dynamic_tables = [
        "media_links", "media_versions", "media_assets", "profile_media", "posts", "x_statuses", "x_reposts",
        "bilibili_statuses", "events", "event_sources", "videos", "focus", "assets", "schedule_asset_reviews",
        "translations", "translation_states", "sync_state", "sync_runs",
    ]
    for table in dynamic_tables:
        conn.execute(f"DELETE FROM {table}")
    conn.execute("DELETE FROM app_settings WHERE key IN ('featured_video_id','dashboard_revision')")

    # Profile media is kept separate from source media so the profile projection
    # exercises /media/profile/avatar and /media/profile/banner.
    for slot, seed, width, height in (("avatar", 11, 128, 128), ("banner", 12, 320, 96)):
        content = png_bytes(width, height, seed)
        digest = hashlib.sha256(content).hexdigest()
        rel = pathlib.PurePosixPath("avatar", f"{slot}.png")
        path = data_root / pathlib.Path(*rel.parts)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)
        conn.execute(
            "INSERT INTO profile_media(id,slot,source,source_ref,source_url,active_cache_path,active_sha256,active_mime_type,download_status,mime_type,extension,byte_size,sha256,width,height,status,is_active,created_at,updated_at) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (f"synthetic-{slot}", slot, "upload", f"synthetic-{slot}", f"https://example.com/synthetic/{slot}.png", rel.as_posix(), digest, "image/png", "ready", "image/png", "png", len(content), digest, width, height, "ready", 1, now, now),
        )

    videos: list[dict] = []
    def add_video(vid: str, source: str, title: str, published: dt.datetime | None, scheduled: dt.datetime | None, kind: str, *, upcoming: int = 0, live_status: str | None = None, short: int = 0, tag: str | None = None, availability: str | None = "public", merged_into: str | None = None, kind_source: str | None = "synthetic", premiere: int = 0) -> None:
        url = f"https://www.youtube.com/watch?v={vid}" if source == "youtube" else f"https://www.bilibili.com/video/{vid}"
        thumb = f"https://example.com/synthetic/thumb-{vid}.png"
        videos.append(dict(id=vid, source=source, title=title, published=published, scheduled=scheduled, kind=kind, upcoming=upcoming, live_status=live_status, short=short, tag=tag, availability=availability, merged_into=merged_into, kind_source=kind_source, premiere=premiere, url=url, thumb=thumb))

    live_start = now_dt - dt.timedelta(minutes=30)
    next_start = now_dt + dt.timedelta(hours=3)
    add_video("SYNTHLIVE01", "youtube", "Synthetic stream: Morning talk", live_start, live_start, "stream", live_status="live")
    add_video("SYNTHNEXT01", "youtube", "Synthetic stream: Evening game", None, next_start, "stream", upcoming=1, live_status="upcoming")
    add_video("SYNTHARCH01", "youtube", "Synthetic archive: Night song", now_dt - dt.timedelta(days=1), now_dt - dt.timedelta(days=1, hours=1), "stream", live_status="ended")
    add_video("SYNTHPREM01", "youtube", "Synthetic premiere: New melody", None, now_dt + dt.timedelta(hours=6), "premiere", upcoming=1, live_status="upcoming", premiere=1)
    add_video("SYNTHSONG01", "youtube", "Synthetic upload: Song", now_dt - dt.timedelta(days=2), None, "upload", tag="song")
    add_video("SYNTHGAME01", "youtube", "Synthetic upload: Game", now_dt - dt.timedelta(days=3), None, "upload", tag="game")
    add_video("SYNTHTALK01", "youtube", "Synthetic upload: Talk", now_dt - dt.timedelta(days=4), None, "upload", tag="talk")
    add_video("SYNTHSHORT1", "youtube", "Synthetic Short: Hello", now_dt - dt.timedelta(days=1, hours=3), None, "upload", short=1)
    add_video("SYNTHMEMB01", "youtube", "Synthetic members stream", None, now_dt + dt.timedelta(days=1, hours=2), "stream", upcoming=1, live_status="upcoming", availability="members")
    add_video("SYNTHUPLD01", "youtube", "Synthetic upload: Video", now_dt - dt.timedelta(days=5), None, "upload", tag="video")
    add_video("SYNTHBILI01", "bilibili", "Synthetic upload: Song", now_dt - dt.timedelta(days=2, minutes=5), None, "upload", tag="song", merged_into="SYNTHSONG01")
    for i, video in enumerate(videos):
        conn.execute(
            """INSERT INTO videos(id,source,title,published_at,scheduled_at,url,thumbnail_url,kind,is_upcoming,live_status,live_checked_at,duration_seconds,is_short,is_premiere,tag,tag_source,availability,merged_into,merge_source,merge_reason,merged_at,kind_source,kind_review,kind_attempts,kind_attempted_at)
            VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
            (video["id"], video["source"], video["title"], iso(video["published"]) if video["published"] else None, iso(video["scheduled"]) if video["scheduled"] else None, video["url"], video["thumb"], video["kind"], video["upcoming"], video["live_status"], now if video["live_status"] else None, 3600 if video["kind"] == "stream" else 240, video["short"], video["premiere"], video["tag"], "synthetic" if video["tag"] else None, video["availability"], video["merged_into"], "manual" if video["merged_into"] else None, "synthetic merge" if video["merged_into"] else None, now if video["merged_into"] else None, video["kind_source"], "confirmed" if video["source"] == "bilibili" else None, 0, None),
        )
        media(conn, data_root, now, video["thumb"], video["source"], i + 20, ("video", video["id"], "thumbnail", 0))
        add_translations(conn, "video", video["id"], "title", video["title"], "zh" if video["source"] == "bilibili" else "ja", video["source"], now)

    # Events cover the complete public calendar vocabulary and several
    # provenance/cancellation states. The linked YouTube rows make liveStatus
    # a trusted projection rather than a guessed value.
    events: list[tuple] = []
    events.append(event_row("youtube-SYNTHLIVE01", "youtube", "Synthetic stream: Morning talk", live_start, now, event_type="stream", tag="live", platform="youtube", platforms=["youtube"], url="https://www.youtube.com/watch?v=SYNTHLIVE01", end=now_dt + dt.timedelta(hours=2), source_item_id="SYNTHLIVE01"))
    events.append(event_row("youtube-SYNTHNEXT01", "youtube", "Synthetic stream: Evening game", next_start, now, event_type="stream", tag="live", platform="youtube", platforms=["youtube"], url="https://www.youtube.com/watch?v=SYNTHNEXT01", end=next_start + dt.timedelta(hours=2), source_item_id="SYNTHNEXT01"))
    events.append(event_row("youtube-SYNTHMEMB01", "youtube", "Synthetic members stream", now_dt + dt.timedelta(days=1, hours=2), now, event_type="member", tag="talk", platform="youtube", platforms=["youtube"], url="https://www.youtube.com/watch?v=SYNTHMEMB01", end=now_dt + dt.timedelta(days=1, hours=4), source_item_id="SYNTHMEMB01"))
    events.append(event_row("synthetic-date-only", "x", "Synthetic date-only announcement", now_dt - dt.timedelta(days=2), now, event_type="event", tag="video", platform="other", platforms=["other"], url="https://x.com/kano_2525/status/900000000001", starts_at=False, source_item_id="900000000001"))
    events.append(event_row("synthetic-bilibili-talk", "bilibili", "Synthetic Bilibili talk", now_dt + dt.timedelta(days=2), now, event_type="event", tag="talk", platform="bilibili", platforms=["bilibili"], url="https://www.bilibili.com/video/BV1SYNTHTALK"))
    events.append(event_row("synthetic-other-song", "x", "Synthetic other song", now_dt + dt.timedelta(days=4), now, event_type="release", tag="song", platform="other", platforms=["other"], url="https://x.com/kano_2525/status/900000000002", source_item_id="900000000002"))
    events.append(event_row("synthetic-cancelled", "x", "Synthetic cancelled event", now_dt + dt.timedelta(days=5), now, event_type="event", tag="game", platform="other", platforms=["other"], url="https://x.com/kano_2525/status/900000000003", status="cancelled", source_item_id="900000000003"))
    events.append(event_row("synthetic-suspected", "x", "Synthetic suspected cancellation", now_dt + dt.timedelta(days=6), now, event_type="event", tag="talk", platform="other", platforms=["other"], url="https://x.com/kano_2525/status/900000000004", cancellation="llm_suspected", source_item_id="900000000004"))
    events.append(event_row("synthetic-locked", "x", "Synthetic manually confirmed event", now_dt + dt.timedelta(days=7), now, event_type="event", tag="video", platform="other", platforms=["other"], url="https://x.com/kano_2525/status/900000000005", provenance="manual", locked=1, source_item_id="900000000005"))
    sale_now_start = now_dt - dt.timedelta(hours=1)
    sale_now_end = now_dt + dt.timedelta(days=2, hours=12)
    events.append(event_row("synthetic-sale-now", "shop", "Synthetic sale: now open", sale_now_start, now, event_type="sale", platform="other", platforms=["other"], url="https://shop.example.com/synthetic-now", end=sale_now_end, ends_on=japan_date(sale_now_end)))
    sale_later_start = now_dt + dt.timedelta(days=3)
    sale_later_end = now_dt + dt.timedelta(days=5)
    events.append(event_row("synthetic-sale-later", "shop", "Synthetic sale: opens soon", sale_later_start, now, event_type="sale", platform="other", platforms=["other"], url="https://shop.example.com/synthetic-later", end=sale_later_end, ends_on=japan_date(sale_later_end)))
    cycle = [("live", "stream", "youtube"), ("game", "event", "other"), ("talk", "event", "bilibili"), ("song", "release", "other"), ("video", "video", "youtube")]
    for offset in (-14, -10, -7, -5, -4, -3, -1, 0, 0, 1, 3, 8, 10, 13):
        tag, kind, platform = cycle[len(events) % len(cycle)]
        start = now_dt + dt.timedelta(days=offset, hours=(len(events) % 4) + 1)
        event_id = f"synthetic-calendar-{offset:+03d}-{len(events):02d}"
        url = f"https://www.{platform}.example.com/synthetic/{len(events)}" if platform != "youtube" else f"https://www.youtube.com/watch?v=SYNTHUPLD01"
        events.append(event_row(event_id, platform if platform in ("youtube", "bilibili") else "x", f"Synthetic calendar {offset:+d} {tag}", start, now, event_type=kind, tag=tag, platform=platform, platforms=[platform], url=url, source_item_id=f"calendar-{len(events):04d}"))

    event_columns = "id,source,source_item_id,source_key,title,detail,starts_on,starts_at,ends_at,ends_on,timezone,time_precision,status,event_type,tag,tag_source,url,provenance,manual_locked,cancellation_status,cancellation_source,cancellation_reason,cancellation_evidence,cancellation_source_item_id,cancellation_confidence,cancellation_at,deleted_at,created_at,updated_at,platform,platforms"
    placeholders = ",".join("?" for _ in range(31))
    for row in events:
        conn.execute(f"INSERT INTO events({event_columns}) VALUES({placeholders})", row)
        source_item = row[2]
        if source_item:
            src = row[1] if row[1] in ("x", "youtube", "bilibili", "shop") else "x"
            conn.execute("INSERT INTO event_sources(event_id,source,source_item_id,source_key,url,raw_json,created_at,updated_at) VALUES(?,?,?,?,?,?,?,?)", (row[0], src, source_item, row[3], row[16], "{}", now, now))

    # Synthetic posts from both configured X accounts, one Bilibili dynamic,
    # a promoted related account, and an X quote with its own cached image.
    quote_id = "999999000001"
    quote_time = now_dt - dt.timedelta(hours=5)
    quote_json = json.dumps({"id": quote_id, "authorHandle": "quoted_synthetic", "authorName": "Synthetic Quoted", "text": "Synthetic quoted status", "publishedAt": iso(quote_time), "url": f"https://x.com/quoted_synthetic/status/{quote_id}"})
    posts = [
        ("900000000001", "x", "kano_2525", "daily", "Synthetic main", "Synthetic post: morning update", now_dt - dt.timedelta(hours=1), "https://x.com/kano_2525/status/900000000001", 24, 3, 2, "https://example.com/synthetic/post-main.png", "Synthetic post image", None, None),
        ("900000000002", "x", "_Kanotic", "daily", "Synthetic sub", "Synthetic post: evening note", now_dt - dt.timedelta(hours=2), "https://x.com/_Kanotic/status/900000000002", 18, 2, 1, "https://example.com/synthetic/post-sub.png", "Synthetic post image", None, None),
        ("900000000003", "x", "kano_2525", "announcement", "Synthetic quote", "Synthetic post with a quote", now_dt - dt.timedelta(hours=3), "https://x.com/kano_2525/status/900000000003", 9, 1, 0, "https://example.com/synthetic/post-quote.png", "Synthetic quote image", quote_json, None),
        ("bilibili-900000000004", "bilibili", "316381099", "dynamic", None, "Synthetic Bilibili dynamic", now_dt - dt.timedelta(hours=4), "https://www.bilibili.com/opus/900000000004", 0, 0, 0, "https://example.com/synthetic/post-bili.png", "Synthetic Bilibili image", None, None),
        ("900000000005", "x", "synthetic_agency", "promoted", "Synthetic related", "Synthetic promoted related-account post", now_dt - dt.timedelta(hours=6), "https://x.com/synthetic_agency/status/900000000005", 1, 0, 0, "https://example.com/synthetic/post-promo.png", "Synthetic promoted image", None, now),
    ]
    post_columns = "id,source,account_handle,type,label,text,published_at,url,likes,reposts,replies,media_url,media_alt,raw_json,quote_json,promoted_at"
    for i, row in enumerate(posts):
        values = (row[0], row[1], row[2], row[3], row[4], row[5], iso(row[6]), row[7], row[8], row[9], row[10], row[11], row[12], "{}", row[13], row[14])
        conn.execute(f"INSERT INTO posts({post_columns}) VALUES({','.join('?' for _ in values)})", values)
        media(conn, data_root, now, row[11], row[1], 80 + i, ("post", row[0], "post-image", 0))
        add_translations(conn, "post", row[0], "text", row[5], "zh" if row[1] == "bilibili" else "ja", row[1], now)
    conn.execute("INSERT INTO x_statuses(id,author_handle,author_name,text,published_at,url,raw_json,quoted_at,first_seen_at,updated_at) VALUES(?,?,?,?,?,?,?,?,?,?)", (quote_id, "quoted_synthetic", "Synthetic Quoted", "Synthetic quoted status", iso(quote_time), f"https://x.com/quoted_synthetic/status/{quote_id}", "{}", iso(now_dt - dt.timedelta(hours=3)), now, now))
    media(conn, data_root, now, "https://example.com/synthetic/quote-image.png", "x", 99, ("post", "900000000003", "quote-image", 0))
    add_translations(conn, "x_status", quote_id, "text", "Synthetic quoted status", "ja", "x", now)

    # A rich focus card and a schedule image exercise the remaining dashboard
    # media paths.
    focus_url = "https://example.com/synthetic/focus.png"
    media(conn, data_root, now, focus_url, "synthetic", 121)
    conn.execute("INSERT INTO focus(id,video_id,date_label,title,description,image_url,url,source_url,updated_at,raw_json) VALUES(?,?,?,?,?,?,?,?,?,?)", (1, "SYNTHSONG01", japan_date(now_dt - dt.timedelta(days=2)), "Synthetic featured focus", "Synthetic focus description", focus_url, "https://www.youtube.com/watch?v=SYNTHSONG01", "https://x.com/kano_2525/status/900000000010", now, "{}"))
    schedule_url = "https://example.com/synthetic/schedule.png"
    media(conn, data_root, now, schedule_url, "x", 122)
    conn.execute("INSERT INTO assets(id,kind,url,source_url,alt,week_start,source_account,updated_at,period_start,period_end,period_basis) VALUES(?,?,?,?,?,?,?,?,?,?,?)", ("synthetic-schedule", "schedule", schedule_url, "https://x.com/kano_2525/status/900000000010", "Synthetic schedule image", japan_date(now_dt - dt.timedelta(days=now_dt.astimezone(JST).weekday())), "kano_2525", now, japan_date(now_dt - dt.timedelta(days=7)), japan_date(now_dt + dt.timedelta(days=7)), "manual"))
    conn.execute("INSERT INTO schedule_asset_reviews(asset_id,llm_status,manual_status,updated_at) VALUES(?,?,?,?)", ("synthetic-schedule", "schedule", "schedule", now))

    conn.execute("INSERT INTO app_settings(key,value,updated_at) VALUES('featured_video_id','SYNTHSONG01',?)", (now,))
    old_revision = conn.execute("SELECT COALESCE(value,'0') FROM app_settings WHERE key='dashboard_revision'").fetchone()
    revision = int(old_revision[0]) + 1 if old_revision and str(old_revision[0]).isdigit() else 1
    conn.execute("INSERT INTO app_settings(key,value,updated_at) VALUES('dashboard_revision',?,?)", (str(revision), now))
    conn.execute("INSERT INTO sync_runs(source,started_at,finished_at,status,message,counts_json,triggered_by) VALUES(?,?,?,?,?,?,?)", ("synthetic", iso(now_dt - dt.timedelta(seconds=2)), now, "success", "Synthetic data seeded", json.dumps({"events": len(events), "videos": len(videos), "posts": len(posts)}), "local-backend"))
    for source, account in (("x", "kano_2525"), ("x", "_Kanotic"), ("youtube", "main"), ("bilibili", "316381099"), ("shop", "synthetic")):
        conn.execute("INSERT INTO sync_state(source,account_id,last_success_at,metadata_json) VALUES(?,?,?,?)", (source, account, now, "{}"))

    conn.commit()
    conn.close()
    print(json.dumps({"seededAt": now, "revision": revision, "events": len(events), "videos": len(videos), "posts": len(posts)}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
