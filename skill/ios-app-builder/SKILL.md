---
name: ios-app-builder
description: Build a polished, native iOS app end-to-end with simulator self-verification and a frame-level aesthetics pass. Use when the user asks to build an iOS app, iPhone app, SwiftUI app, or invokes /ios-app-builder with an app idea. Four phases, build, 100x the design, steer, due diligence.
---

# iOS App Builder

Before starting, read `reference-article.md` in this skill's directory. It holds the source method and verbatim prompts from the original author. Phase 1 mirrors his Prompt 1, Phase 2 his Prompt 2, Phase 3 his steering prompts. Phase 4 and the operational rules were learned by shipping a real startup demo with this skill; they exist because each one caught a real problem.

You are building a native iOS app end-to-end, hands-off, to Apple Design Award quality. The user gives you an app idea; you do everything else. Do not ask questions unless hard-stuck. The single highest-leverage behavior: **verify your own work in the simulator, at the frame and pixel level, and keep iterating until it is flawless.**

## Phase 0: Preflight (always run first)

1. Verify toolchain: `xcodebuild -version`, `xcrun simctl list devices available`, `ffmpeg -version`, `idb --help`. If anything is missing, point the user at the setup script and stop.
2. Confirm you are in an empty or new project folder. If the cwd has unrelated files, create a new subfolder named after the app and work there.
3. If the concept needs AI or image generation, verify keys NOW, in the same shell environment your build will use: `echo $GEMINI_API_KEY | head -c 8`. Subagents and fresh shells do not always inherit what your current shell sees; source the env file explicitly in every shell that needs it. Test the key with a real API call before depending on it. Known traps: Google's free tier has ZERO image-generation quota (billing required, roughly 4 cents per image); modern Google keys can start with `AQ.` instead of `AIza`, so validate by calling the API, not by eyeballing the format. If keys are absent, build AI features behind a settings screen where the user can paste one later.
4. `git init`, then write `.gitignore` BEFORE the first commit. It must already cover: frame-dump directories, raw simulator recordings (.mp4 except compressed deliverables), simulator temp sidecars (`*.sb-*`), `build/`, `DerivedData/`, and any virtualenv. One build session can put gigabytes of per-frame PNGs into history, and removing them later means a history rewrite. Cheap now, expensive forever after.
5. Maintain a `docs/` folder capturing **intent, not just outcomes**: architecture decisions, design language, known issues, and a punch-list contract (see Phase 4). This is what survives compactions and lets multiple sessions cooperate.

## Phase 1: Build the whole app

Interpret the user's idea with your best judgment. Their prompt tells you what they care about; everything unspecified is yours to design. Standards:

- Native SwiftUI (drop to UIKit or Metal where it buys fluidity). No web views, no cross-platform shims.
- Super clean, minimalist, design-forward. Sweat every tiny detail; make every interaction delightful. Custom components, custom transitions, custom Metal shaders are all on the table. Do not resort to boring iOS defaults because they are easy.
- Real data sources over mocks where free APIs exist. Use the web for docs and resources.
- If the concept involves an in-app AI agent: engineer its personality, give it persistent memory, tool calling, token streaming, and Anthropic prompt-caching headers.
- Clean, maintainable, modular code. Commit as you go. Commit generated assets (images, icons) IMMEDIATELY after creating them; an uncommitted asset folder is one cleanup command away from gone, and a parallel agent once deleted a finished image library it could not recognize.

Drive everything from CLI: `xcodebuild` to build, `xcrun simctl` to boot/install/launch, `idb` to tap, swipe, and type inside the simulator. **Verify every screen, interaction, and transition actually works in the simulator before declaring Phase 1 done.** Fix every crash, broken flow, and layout bug you find.

## Phase 2: 100x the design (full attention on aesthetics only)

The first pass always looks like AI slop: generic gradients, awkward structure, pops and hitches. Re-attack with zero functional work competing for attention. Target: top 1% of human designers, instantly eligible for an Apple Design Award. Make NO mistakes.

Mandatory verification loop, every pixel perfect, every transition flawless frame to frame:

1. Record simulator video of every flow (`xcrun simctl io booted recordVideo`, drive with idb).
2. Dump frames with `ffmpeg`/`ffprobe` and examine transitions frame by frame.
3. Write Python/Pillow scripts to diff pixels between frames and detect pops, hitches, misalignments, inconsistent spacing.
4. Fix, re-record, re-verify. Loop until transitions are genuinely fluid. Do not stop at "looks fine."
5. Prefer label-based tap drivers over hard-coded coordinates; coordinates go stale the moment layout changes, and a driver that fails loudly beats one that taps the wrong thing.

Design direction while you audit:
- Kill generic AI gradients; commit to a deliberate, restrained palette and type system. If the user supplied a brand system, it is law: exact hex values, semantic-only color, named fonts.
- Prefer image-centric, simplified layouts over cheesy alternating structures.
- Build gorgeous custom view transitions (matched geometry, shared-element tile flows). Never stock view-controller transitions.
- Compile every Metal shader at app launch. Lazy first-compile causes a visible stall the frame audit will catch anyway.
- Reachability beats minimalism: time-sensitive surfaces (messages, notifications) must be reachable from every tab, not just home. Pin or float utility clusters so they survive scrolling.

## Phase 3: Report and steer

Show the user what you built. Always include:
- A **status board** in three buckets: done and visible now, in flight, waiting on the user. Users lose track across long builds; never make them ask what is done versus not.
- A **compressed walkthrough video** (under 15MB, 2 to 4 minutes, ffmpeg-compressed) covering every surface in a narrative order that sells the product. This becomes the thing they send to cofounders and investors, so watch your own footage frame by frame and confirm it shows the current build before delivering it.
- The shortlist of taste calls that belong to a human.

Invite blunt, specific steering ("the grid view is cheesy, go more image-centric") and apply it with the same frame-level verification loop. The user noticing what feels off IS the process working; incorporate it aggressively and check whether the same instinct applies anywhere else in the app.

## Phase 4: Due diligence (run without being asked)

1. **Audit against the sources.** If the user gave you documents (a business plan, a brand system, a prototype), re-read them after building and verify every stated promise against the code: BUILT / PARTIAL / MISSING, with file evidence. Your synthesis compresses with a point of view, and a point of view always cuts something. Find what you cut. Separate discovery from scope: report what you deferred and why, and let the user move the ambition dial.
2. **The confession check.** Before any "done" report, answer honestly: what do you already know is wrong, unverified, or quietly parked that the user has not caught? Unreviewed generated images, never-felt haptics, visible demo buttons, incoherent mock-data casts. List them unprompted. If the user has to ask "what did you miss?" this check failed.
3. **The closed-loop test.** An app that builds value but never pays it off is not a product. Does the demo close the loop the product exists for? If the materials describe a marketplace, both sides of the exchange must be felt, even mocked.
4. **Copy voice sweep, last, after all copy exists.** No em dashes in UI strings (rewrite the sentence; plain hyphens fine in numeric ranges). No AI-tell vocabulary: seamless, delve, elevate, empower, journey, "isn't just X, it's Y". Voice target: how a confident founder texts, not how a landing page sells.
5. **Verify subagent work yourself.** If you delegated, rebuild and look with your own eyes before reporting. Agents report optimistically; two real bugs in one build survived an agent's "verified" and died in the main session's re-check.
6. **Image QA by contact sheet.** Render every generated image plus the app icon onto one contact sheet and actually look at it. Generated art ships sight-unseen by default, and that is how one broken composition ends up in an investor demo.
7. **Keep a punch-list contract.** Scope lives in a committed doc with an explicit "consciously deferred, because" section. Deferral is fine; silent deferral is not.

## Operational rules (each one paid for in real debugging time)

**Git and parallel agents.** Never rewrite history while any agent is working in the repo. If you stop an agent mid-task, immediately snapshot-commit its working tree so nothing is lost. When building for device while an agent edits the tree, build from a pinned `git worktree` at a known commit.

**Simulator state.** The app's UserDefaults live in the app container plist, and the simulator's prefs daemon caches it. To force a value (e.g. skipping onboarding): shut the simulator down fully, edit the plist with `plutil`, then boot. Editing while booted silently loses.

**Demo craft.** Demo failure paths must be deterministic, not random; a demo that behaves differently every run cannot be rehearsed. Keep one coherent mock-data cast across every surface (same names, companies, timeline). If the user is a founder, build the demo around them: their name, their cofounder vouching, their world; a founder demoing their own profile is a 10x story. Hide demo-driver buttons behind a long-press so investor hands never find them.

**Real hardware.** Haptics do not exist in the simulator, and shader performance differs on real chips. Anything tactile has literally never been felt until it runs on a phone. Device install: user signs into Xcode once (Settings > Accounts) and picks their personal team once in the GUI (that is the only way to mint the team ID; grep it from the pbxproj afterward), phone needs Developer Mode on, then everything is CLI: `xcodebuild -allowProvisioningUpdates CODE_SIGNING_ALLOWED=YES CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=<id>` and `xcrun devicectl device install app`. Free-account installs expire after 7 days; remote teammates need TestFlight, which needs the paid developer program.

**Setup gotchas** (the setup script handles these, listed here in case it drifts): Homebrew 6 requires `brew trust` for third-party taps; outdated Command Line Tools block source builds until `softwareupdate --install` updates them; fb-idb breaks on Python 3.12+ (pin to 3.11 via pipx).

## Invocation

`/ios-app-builder <app idea, with the parts the user cares about spelled out>`

If the user gives only a vague idea, proceed anyway with your best interpretation. That is the point.
