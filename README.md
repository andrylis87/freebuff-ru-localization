# Freebuff Russian Localization (Unofficial)

> **Disclaimer:** This is an unofficial localization. Not affiliated with
> Codebuff. Freebuff is a trademark of Codebuff.

Russian (`ru-RU`) interface localization for the **Freebuff CLI** — the free,
open-source coding agent built on the Codebuff agent framework.

- **Original project:** <https://github.com/CodebuffAI/freebuff>
- **License:** Apache License 2.0 (see [`LICENSE`](./LICENSE) and
  [`NOTICE`](./NOTICE))
- **Status:** usable, partial coverage — see [Coverage](#coverage)

---

## Contents

| File                                | What it is                                                                       |
| ----------------------------------- | -------------------------------------------------------------------------------- |
| `freebuff-ru-localization.patch`    | The full change set as a 5-commit mbox patch (`git format-patch`)                |
| `freebuff-ru-localization.zip`      | The same changed/added files laid out at their original paths, plus this README  |
| `README_RU.md`                      | Detailed Russian documentation: install, usage, design, verification, limitations |
| `GLOSSARY_RU.md`                    | Agreed Russian terminology for translators and future contributors               |
| `LICENSE`, `NOTICE`                 | Apache 2.0 files copied from the original project — **keep them when redistributing** |

---

## Installation

### Option A — apply the patch (recommended)

Clone the original repository and apply the patch on a clean working tree:

```bash
git clone https://github.com/CodebuffAI/freebuff.git
cd freebuff

git apply /path/to/freebuff-ru-localization.patch        # as one diff
# — or, to keep the five original commits with their messages:
git am /path/to/freebuff-ru-localization.patch
```

If the patch does not apply cleanly (it was authored against `main` as of
October 2026):

```bash
git apply --3way /path/to/freebuff-ru-localization.patch
```

### Option B — unzip the files

```bash
unzip freebuff-ru-localization.zip -d /path/to/freebuff   # files land at their own paths
```

### Build and run

```bash
bun install          # bun 1.3.14; the lockfile is not modified by this patch
bun run dev          # run the CLI in dev mode (TUI)
bun run ci           # build sdk + freebuff
cd cli && bun run typecheck
```

Run the localization tests from the **repository root**:

```bash
bun test cli/src/i18n/__tests__/
```

---

## Enabling Russian

Three ways, in priority order:

1. **In-CLI command** (persisted across restarts):

   ```
   /language          # show current language and available languages
   /language ru       # switch to Russian (aliases: /lang, /locale)
   /language en       # switch back to English
   ```

2. **Auto-detection** — only applies while the language has never been chosen
   manually: `LANG`, `LC_ALL` or `LC_MESSAGES` starting with `ru`
   (e.g. `ru_RU.UTF-8`). An explicit user choice always wins over the
   environment.

3. **Environment variable** — force it, handy for CI and bug reports:

   ```bash
   FREEBUFF_LOCALE=ru freebuff
   ```

The selection is stored as the `language` field in the CLI `settings.json`
(directory from `getConfigDir()`, overridable with `FREEBUFF_CONFIG_DIR`).

---

## Coverage

**Translated — 135 keys, 50 `t()` calls, 15 `tp()` calls across 17 files:**

- Slash-command menu (descriptions for `/help`, `/plan`, `/model`, …)
- Hotkey/help overlay (Compose, Chat, Conversation sections and all labels)
- Status bar: “thinking…”, “working…”, “reconnected”, retries, queue overflow,
  “cannot reach the servers…”
- Composer: placeholder text for every input mode and the mode badges
  (Plan, Review, Interview, Skill)
- Login screen: instructions, errors, copy button, timeout
- Toasts and system messages: send failure, `/copy`, `/usage`, attachment
  handling
- Message queue (header, pause) and the changed-files summary
- The new `/language` command itself

**Not translated yet (~700 lines of text exist in the CLI; the untouched parts
are deliberate):**

- Tool-call renderers (`components/tools/*`), agent-dialog blocks,
  `todo` / `queue` / `publish` panels
- Subscription and credit banners, sponsored blocks
- Model selector and reasoning picker
- Text output of `/byok`, `/deals`, `/ads:*`, `/diagnostics` — long technical
  instructions with commands and URLs where machine translation easily breaks
  copyable text
- `agents/` definitions and `SKILL.md` (content, not interface)
- `README*.md` files (documentation, not UI)

English remains the fallback everywhere: the source string lives at the call
site (`t('help.title', 'Keyboard shortcuts')`), so a missing key renders
English instead of an empty string or a raw key.

---

## Design at a glance

- **Zero new dependencies** — only `zustand`, already in the project.
- **Russian plural rules (CLDR)** via `Intl.PluralRules('ru')`:
  `one / few / many / other` — «1 сообщение», «2 сообщения», «5 сообщений».
- **Placeholders and markup are preserved:** `{name}` and `{{name}}` are
  interpolated; `${...}`, `%s`, `%d`, HTML and Markdown are left untouched.
- **English and the Chinese docs (`README.zh-CN.md`) are untouched**, and the
  existing fallback behaviour is unchanged.

See [`README_RU.md`](./README_RU.md) for the full technical write-up and
[`GLOSSARY_RU.md`](./GLOSSARY_RU.md) for the agreed terminology.

---

## Verification performed

```bash
bun install --frozen-lockfile        # OK, lockfile unchanged
cd cli && bun run typecheck          # byte-identical to the baseline (23 pre-existing errors)
bun test cli/src/i18n/__tests__/     # 44 pass, 0 fail
bun test <all 286 test files>        # 3453 pass / 66 fail / 56 errors — all pre-existing
bunx prettier --check <changed files># OK
```

The remaining failures reproduce on the base revision without this patch
(environment and cross-file state issues in this snapshot) and are unrelated
to the localization.

---

## License and trademark notice

Distributed under the **Apache License 2.0**, identical to the original
project. When you redistribute this patch or a build containing it you must:

- keep `LICENSE` and `NOTICE` intact,
- state that modifications were made,
- not remove the original author attributions.

`Freebuff`, `Codebuff` and `Freebucks` are trademarks of the project. Use
them only to describe compatibility (“Russian localization for Freebuff”) —
never in a way that suggests this localization was released by the project
authors.

This patch modifies only the CLI client source, the glossary and the docs. It
contains no secrets, API keys, tokens or local configuration.
