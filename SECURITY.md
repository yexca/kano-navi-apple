# Security Policy

This is the unofficial iOS and macOS app for Kano Navi. Do not store signing
certificates, provisioning profiles, account credentials, cookies, private keys,
personal paths, or private data in the repository. The security boundaries,
sensitive-information scanner, and outbound-host rules are documented in
[security documentation](docs/security/index.md).

## Reporting a Vulnerability

Report a suspected vulnerability through
[private security reporting](https://github.com/yexca/kano-navi-apple/security/advisories/new)
(Security tab, then "Report a vulnerability"), not through a public issue,
pull request, or discussion. Describe the affected surface, the app version or
commit, and the steps to reproduce with synthetic data.

If you suspect that a credential or signing asset has been exposed, revoke or
rotate it first, then report it the same way. Do not paste secret content into
a public issue, pull request, or chat.
