---
name: ios-app-builder
description: Build a polished, native iOS app end-to-end with simulator self-verification and a frame-level aesthetics pass. Use when the user asks to build an iOS app, iPhone app, SwiftUI app, or invokes /ios-app-builder with an app idea. Replicates the proven 3-prompt process - build, 100x the design, steer.
---

# iOS App Builder

Before starting, read `reference-article.md` in this skill's directory — the source article with the author's verbatim prompts and learnings. Phase 1 mirrors his Prompt 1 structure, Phase 2 mirrors his Prompt 2, Phase 3 mirrors his steering prompts. When in doubt about tone or emphasis, match the article.

You are building a native iOS app end-to-end, hands-off, to Apple Design Award quality. The user gives you an app idea; you do everything else. Do not ask questions unless hard-stuck. The process has three phases run in order. The single highest-leverage behavior: **verify your own work in the simulator, at the frame and pixel level, and keep iterating until it is flawless.**

## Phase 0 — Preflight (always run first)

1. Verify toolchain: `xcodebuild -version`, `xcrun simctl list devices available`, `ffmpeg -version`, `idb --help`. If anything is missing, tell the user to run `bash ~/ios-dev-setup.sh` and stop.
2. Confirm you are in an empty (or new) project folder. If the cwd has unrelated files, create a new subfolder named after the app and work there.
3. Check for API keys (`ANTHROPIC_API_KEY`, `GEMINI_API_KEY` in env) if the app concept needs AI/image-gen features. If absent, build those features behind a settings screen where the user can paste a key.
4. `git init`. Commit as you go with meaningful messages. Maintain a `docs/` folder capturing **intent, not just outcomes** — architecture decisions, design language, known issues — so work survives compactions and multiple sessions.

## Phase 1 — Build the whole app

Interpret the user's idea with your best judgment. Their prompt tells you what they care about; everything unspecified is yours to design. Standards:

- Native SwiftUI (drop to UIKit/Metal where it buys fluidity). No web views, no cross-platform shims.
- Super clean, minimalist, design-forward. Sweat every tiny detail; make every interaction delightful. Custom components, custom transitions, custom Metal shaders are all on the table — do not resort to boring iOS defaults because they're easy.
- Real data sources over mocks (e.g., USDA for nutrition, real APIs where free ones exist). Use the web to find docs and resources.
- If the concept involves an in-app AI agent: engineer its personality, give it persistent memory, tool calling, token streaming, and Anthropic prompt-caching headers.
- Clean, maintainable, modular code.

Drive everything from CLI — `xcodebuild` to build, `xcrun simctl` to boot/install/launch, `idb` to tap/swipe/type inside the simulator. **Verify every screen, interaction, and transition actually works in the simulator before declaring Phase 1 done.** Fix every crash, broken flow, and layout bug you find.

## Phase 2 — 100x the design (run with full attention on aesthetics only)

The first pass always looks like AI slop: generic gradients, awkward layout structure, pops and hitches. Now re-attack with zero functional work competing for attention. Target: top 1% of human designers, instantly eligible for an Apple Design Award. Make NO mistakes.

Mandatory verification loop — get every pixel perfect, every transition flawless frame-to-frame:

1. Record simulator video of every flow: `xcrun simctl io booted recordVideo` (or screen capture + `idb` driving the interactions).
2. Dump frames with `ffmpeg`/`ffprobe` and examine transitions frame by frame.
3. Write Python/Pillow scripts to diff pixels between frames, crop and zoom into details, and detect pops, hitches, misalignments, and inconsistent spacing.
4. Fix what you find, re-record, re-verify. Loop until transitions are genuinely fluid and hitch-free — do not stop at "looks fine."

Design direction while you audit:
- Kill generic AI gradients; commit to a deliberate, restrained palette and type system.
- Prefer image-centric, simplified layouts over cheesy alternating/cluttered structures.
- Build gorgeous custom view transitions (matched-geometry, shared-element tile flows) — never stock view-controller transitions.
- Apple-y feel: fluid gestures, bounciness, liquid-glass material, purposeful shader moments.

## Phase 3 — Report and steer

Show the user what you built: how to run it, screenshots/recording paths, and what you verified. Invite specific steering ("the grid view is cheesy, go more image-centric" level of feedback) and apply it with the same frame-level verification loop. Specific steering is the fastest way to kill the worst remaining visual issues — incorporate it aggressively.

## Invocation

`/ios-app-builder <app idea, with the parts the user cares about spelled out>`

If the user gives only a vague idea, proceed anyway with your best interpretation — that's the point.
