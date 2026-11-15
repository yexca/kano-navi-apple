# Commit and Release

## Commit Convention

- Use Conventional Commits with the exact subject form
  `<type>(<scope>): <description>`.
- Use one of `feat`, `fix`, `docs`, `refactor`, `test`, `build`, `ci`, `chore`,
  `perf`, `style`, or `revert` as the type.
- Keep the scope short, lowercase, and tied to the primary subsystem, such as
  `app`, `ui`, `api`, `widgets`, `notifications`, `l10n`, `test`, `docs`,
  `tools`, or `ci`.
- Write the description in lowercase imperative language, keep the subject at 72
  characters or fewer, and do not end it with a period.
- Keep each commit focused on one coherent change. Use a body when the reason
  or upgrade behavior is not evident from the subject.
- Mark an incompatible change with `!` before the colon and a `BREAKING CHANGE:`
  footer.
- Create, amend, rebase, or otherwise rewrite a commit only when the user
  explicitly requests it.

## Before Committing

Run `make ci-fast` and the affected Xcode/Swift test targets (`make test-package`,
`make test-ios`, `make test-mac`), verify `make sensitive-check` passes, and
review `git diff --cached` manually. Stage only files within the requested
scope. Never stage `Config/Local.xcconfig`, `Tools/local-backend/.state/`,
signing material, `xcuserdata/`, `DerivedData/`, build output, `.DS_Store`, or
unrelated user changes.

Agents create commits and push only on an explicit user request. Keep the
configured Git commit signing path (`commit.gpgsign`) enabled when committing;
do not disable signing to work around a missing or locked signer. If signing is
blocked, stop and ask the user.

## Merging into Main

Before merging a branch into `main`, judge whether its commits are worth
keeping, and choose the merge method from that judgement. Agents merge only on
an explicit user request, and the validation checks above apply to the result on
`main`.

- **Squash merge** (`git merge --squash`, then one commit) when the history has
  no value of its own: a single commit, work-in-progress or fixup commits,
  review rounds, reverted attempts, or subjects that do not follow the commit
  convention. The squashed commit follows the convention and describes the
  branch's change as a whole.
- **Merge commit** (`git merge --no-ff`) only when every commit is a focused,
  conventional step that builds and passes the checks on its own, and a reader
  would want to read, bisect, or revert those steps separately. Its subject also
  follows the convention, such as `feat(ui): add native macos target`.

When unsure, squash. Do not rewrite a branch's commits to make them worth
keeping unless the user asks for it.

## Version Source

`KanoNavi.xcodeproj/project.pbxproj` owns `MARKETING_VERSION`,
`CURRENT_PROJECT_VERSION`, and `PRODUCT_BUNDLE_IDENTIFIER` (`com.yexca.kanonavi`
for the app, `com.yexca.kanonavi.widgets` for the widget extension). Do not
invent bundle IDs, version numbers, or build numbers; read them from the Xcode
project or obtain them from the user.

Release tags use `v<major>.<minor>.<patch>` matching `MARKETING_VERSION` and
point to a commit on `main`.

## Release Notes

A release note shows its area titles and folds the changes under them so a
reader sees what the release touches before expanding any detail. Its parts
appear in this order:

1. Important or warning alerts (`> [!IMPORTANT]` or `> [!WARNING]`) when a
   release changes compatibility, API requirements, or upgrade behavior.
2. A short summary paragraph.
3. One folded `<details>` block per user-facing area:

```markdown
<details>
<summary><strong>Now and Schedule</strong></summary>

- One change per bullet.

</details>
```

Keep the blank line after `</summary>` and before `</details>` so GitHub
renders the list properly. Typical areas are **Now and Schedule**, **Posts and
Videos**, **Archives**, **Widgets and Notifications**, and **Platform and
Build**.

`docs/history/unreleased.md` holds pending changes in the same area blocks under
its heading. Store each release note at `docs/history/<tag>.md` and add it to
the [history index](../history/index.md) without repeating the tag as a
level-one heading.

## Release Distribution

Releases ship as unsigned IPAs for iPhone and iPad (`xcodebuild archive` with
`CODE_SIGNING_ALLOWED=NO`, packaged into `Payload/`) and an ad-hoc-signed
`.app` for macOS (`CODE_SIGN_IDENTITY[sdk=macosx*] = -`). The project carries no
Apple Developer team, signing certificate, or provisioning profile. See
[Targets and platforms](../architecture/targets-and-platforms.md#signing-sandboxing-and-schemes).

## Related Docs

- [Testing and validation](testing.md)
- [Secure development](security.md)
- [Release history](../history/index.md)
