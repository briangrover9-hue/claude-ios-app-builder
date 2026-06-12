---
name: ios-app-builder
description: Build a polished, native iOS app end-to-end with simulator self-verification and a frame-level aesthetics pass. Use when the user asks to build an iOS app, iPhone app, SwiftUI app, or invokes /ios-app-builder with an app idea. Four phases, build, 100x the design, steer, due diligence.
---

# iOS App Builder

This skill is the accumulated practice of shipping real products end-to-end with Claude: the operating model (conversational cockpit + agent fleet), the premium playbook, wireframe intake, the image-generation mandate, demo craft, the due-diligence phase, and every operational rule below were each earned on a real build, where the rule now written down is the failure it prevents. The innermost loop — build, verify in the simulator, then 100x the design with frame-level audits — descends from a public 3-prompt method; `reference-article.md` preserves those original prompts as Phase 1/2 templates and the credit for that core insight.

You are building a native iOS app end-to-end, hands-off, to Apple Design Award quality. The user gives you an app idea; you do everything else. Do not ask questions unless hard-stuck. The single highest-leverage behavior: **verify your own work in the simulator, at the frame and pixel level, and keep iterating until it is flawless.**

## Operating model: conversational cockpit, agent fleet

The user's experience of this skill is a conversation, not a console scroll. Structure every run this way:

- **The main session is the cockpit.** It talks to the user, makes taste calls, reviews evidence with its own eyes, and delegates. It never goes silent for more than ~30 seconds: no long blocking commands in the main thread when an agent can run them instead. User messages land between tool calls, so the main thread keeps its tool calls short; a 45-second scripted simulator drive in the main thread is a 45-second deaf spot the user will hate.
- **Heavy work runs in background agents, launched in parallel wherever independent:** the build-fix-verify loop, scripted simulator drives and recordings, frame dumps and pixel audits, asset generation, docs, copy sweeps. The main thread narrates what the fleet is doing, surfaces findings, and applies the user's steering.
- **One simulator owner at a time.** The simulator is a single shared resource. Exactly one agent (or the main thread) owns drive-and-record at any moment; everyone else works on files, frames, or docs. Two drivers means corrupted recordings and phantom taps. When `simctl io booted` and multiple booted devices coexist, "booted" is ambiguous: target every simctl/idb command at an explicit UDID, and shut down simulators you are not using.
- **Parallel feature agents run in isolated git worktrees, each with its own simulator.** Scope each mission new-file-heavy (the feature in one new file; shared-file edits limited to a single clearly-marked mount line) so the cockpit's merges are trivial. The cockpit merges worktree branches and wires the cross-feature entry points itself.
- **Agent lifecycle discipline, each clause paid for twice in one day:** missions are 30-45 minute work units, not 90-minute odysseys. Agents commit after every green build, minimum every 15 minutes; an uncommitted hour is an hour the team can lose. The cockpit pulse-checks running agents on a clock (recent commits + file mtimes), never on faith: agents die silently, and a spinner is not a heartbeat. A user interrupt kills in-flight agents (plain messages do not) - on any kill, snapshot-commit the orphaned tree immediately, then relaunch with a fix-forward brief.
- **Agents report, the cockpit verifies.** Subagent "verified" is a claim, not a fact (Phase 4 rule 5). The main session re-checks evidence — screenshots, frames, builds — before reporting anything as done.
- **Check-in beat.** Between every delegated cycle, give the user two or three sentences: what changed, what is next, plus a screenshot when there is anything new to see. Blunt steering ("this looks cheap") gets fresh full-res screenshots and a request to point, then the steer is applied everywhere the same instinct holds.

## Phase 0: Preflight (always run first)

1. Verify toolchain: `xcodebuild -version`, `xcrun simctl list devices available`, `ffmpeg -version`, `idb --help`. If anything is missing, point the user at the setup script and stop.
2. Confirm you are in an empty or new project folder. If the cwd has unrelated files, create a new subfolder named after the app and work there.
3. If the concept needs AI or image generation, verify keys NOW, in the same shell environment your build will use: `echo $GEMINI_API_KEY | head -c 8`. Subagents and fresh shells do not always inherit what your current shell sees; source the env file explicitly in every shell that needs it. Test the key with a real API call before depending on it. Known traps: Google's free tier has ZERO image-generation quota (billing required, roughly 4 cents per image); modern Google keys can start with `AQ.` instead of `AIza`, so validate by calling the API, not by eyeballing the format. If keys are absent, build AI features behind a settings screen where the user can paste one later.
4. **Generated imagery is load-bearing, not optional, for visually-rich concepts** (food, fashion, travel, fitness, social, anything where the content IS the visual). Studio-style generated images are most of what makes the reference-article apps look premium; flat vector fallback art reads "elementary" next to them. If the concept is visual and no image key works, STOP and tell the user before building: offer (a) paste a key now, (b) authorize an existing env file, or (c) explicitly accept vector-only art with the quality tradeoff stated. Silently downgrading to vectors is a known failure mode that wastes a whole build; one run shipped flat dish illustrations because the key check failed quietly, and the user compared it to the reference app and asked what went wrong.
5. `git init`, then write `.gitignore` BEFORE the first commit. It must already cover: frame-dump directories, raw simulator recordings (.mp4 except compressed deliverables), simulator temp sidecars (`*.sb-*`), `build/`, `DerivedData/`, and any virtualenv. One build session can put gigabytes of per-frame PNGs into history, and removing them later means a history rewrite. Cheap now, expensive forever after.
6. Maintain a `docs/` folder capturing **intent, not just outcomes**: architecture decisions, design language, known issues, and a punch-list contract (see Phase 4). This is what survives compactions and lets multiple sessions cooperate.

## Phase 0.5: Wireframe intake (run only when the user provides wireframes, mockups, or screenshots)

When the user gives you images of a design, treat them as the spec, not as loose inspiration. The job is to bring that exact design to life, not to invent your own.

Critical rule: do not copy the wireframe literally. A wireframe is low fidelity (gray boxes, placeholder lines, no real styling). The app you build is high fidelity and native. Match the wireframe's structure, layout, and intent, then upgrade the fidelity to real iOS: system components, real type, real color, real spacing, native materials. A pixel-faithful copy of a gray-box wireframe is a failure.

Before you build:

1. Inventory every image. List each screen shown. For each screen, list every element, every piece of content, and every state the wireframes imply (default, empty, loading, selected, error). Build a screen map and the navigation between screens.
2. Mark what is drawn versus what is silent. Wireframes almost never show transitions, loading states, empty states, or motion. Those are yours to invent with taste. State your assumptions for each silent area in one line each, then proceed. Do not stall waiting for answers unless something drawn is genuinely ambiguous.
3. Lock the fidelity contract. Write down, in a few lines, exactly what "matches the wireframe" means for this build: same screens, same elements present, same hierarchy and reading order, same layout structure and proportions. Color, type, and polish are an upgrade, not a copy.

After you build, run the fidelity loop (in addition to the frame-level motion audit, never instead of it — structural fidelity checks what is on the screen; frame-diffing checks how it moves):

1. Screenshot every built screen in the simulator.
2. Place each built screen beside its source wireframe. Compare structurally: is every element from the wireframe present, in the right place, in the right hierarchy, with the right emphasis? Is anything missing, added, or reordered?
3. Do not score on pixel match. Score on whether a person holding the wireframe would say "yes, that is this screen, made real."
4. Produce a fidelity report: per screen, what matches, what drifted from the wireframe's structure, and every place the wireframe was silent and you made a call. Confess the drift before the human finds it.

Loop until every drawn screen passes the structural check and every silent area has a defensible answer. With no wireframes, skip this phase and build from the prompt as usual.

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
5. Prefer label-based tap drivers over hard-coded coordinates; coordinates go stale the moment layout changes, and a driver that fails loudly beats one that taps the wrong thing. For exact targets, dump the accessibility tree (`idb ui describe-all`) and tap element-frame centers: deriving points from screenshot pixels drifts 8-10% and misses 30pt buttons, and every layout change (a new card in a list) silently shifts everything below it - re-derive after each change.

Design direction while you audit:
- Kill generic AI gradients; commit to a deliberate, restrained palette and type system. If the user supplied a brand system, it is law: exact hex values, semantic-only color, named fonts.
- Prefer image-centric, simplified layouts over cheesy alternating structures.
- **Depth is the difference between premium and elementary.** Flat solid-color cards everywhere is a failure smell. Build a real material hierarchy: translucent layers (`.ultraThinMaterial` and friends), glass over imagery, soft layered shadow systems (a tight contact shadow plus a wide ambient one), gentle parallax, content that visibly sits in z-space. The reference apps read expensive because images breathe under glass, not because of any single component.

The premium playbook (each of these was the difference between "template" and "designed" on a real build; apply them by default):
- **One token file is the design system.** Every color, radius, shadow recipe, spring, and type style lives in a single tokens file with semantic names; screens never improvise a value. If a screen needs a new value, it gets added to the tokens file first.
- **No true gray anywhere.** Borders, dividers, shadows, and skeletons are the brand's neutral tinted with the brand hue at 4-10% opacity. Pure gray is the single biggest "generic HTML" tell.
- **Ration color.** One accent color owns all chrome and actions. Any wider palette (categories, people, statuses) is quarantined to small elements: dots, thin accent bars, avatar fills. Chips use one formula: accent text on accent-at-12% background with an accent-at-8% hairline. At most one dark statement card per screen.
- **Full-bleed heroes wear a scrim.** Imagery that touches the top edge gets `ignoresSafeArea` plus a scroll-aware, multi-stop eased gradient scrim under the status bar / Dynamic Island, color-matched to the surface, driven by scroll offset. Text over photos sits on a directional scrim (ink at 60-85% fading out), never raw.
- **Numbers never step.** Any score, count, or percentage animates as a pure function of time inside `TimelineView` (cubic ease-out, 1-2s), `monospacedDigit`, with a light haptic ramp underneath and a one-shot shimmer when it lands. A number that just appears wastes the payoff.
- **Stage the earned moment.** The app's single payoff gets an absolute-time choreography: convergence on an overshooting spring, then glow/particle accent, then copy, with a haptic swell (soft, heavy, success). Scale the fireworks to the product's temperament.
- **Phase-machine correctness.** Enum-driven stage switches get explicit ascending `zIndex` per stage (or SwiftUI drops the outgoing view in a hard pop) and a container base color keyed to the DESTINATION stage so dark-to-dark transitions never flash light. Sequence exits; mutate data after the transition, not during.
- **Entrance choreography, everywhere.** Sections enter with depth-staggered offset+opacity (deeper sections travel a few points farther), list items stagger ~50ms capped at 6, and at least one element travels between screens via `matchedGeometryEffect` so the app has physical continuity, not slideshow cuts.
- **Whisper/shout typography.** The money number pattern: an 11pt uppercase, wide-tracked microlabel over a huge display figure. Hierarchy does the selling, not decoration.
- **Prewarm shaders at launch.** Any Metal/shader effect compiles on first use; compile them all in a launch task or the brand moment janks exactly once, on camera.
- **Never ask for what the product claims to know.** If the pitch is "it already knows you," onboarding that collects inputs contradicts the product on its first screen. Compute the profile from the (seeded) data and stage the computation as a ceremony the user watches - evidence streaming in, numbers assembling, a named result landing. Zero decisions reads as intelligence; a quiz reads as a form.
- **The home screen is a to-do list generated by the user's life.** Action cards with relative timestamps that ask things OF the user (a proposal awaiting RSVP, a result awaiting a one-tap verdict), plus one prominent number that visibly improves when they act. Obligations and a moving number are the return loop; a beautiful home screen that asks nothing is a brochure.
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

**Standard fleet fan-out** (see Operating model). Launched together the moment Phase 1 is verified: (1) a design-audit agent reading recorded frames for spacing, type, color, and transition findings; (2) a docs agent writing ARCHITECTURE.md and the punch-list contract; (3) a copy-voice-sweep agent checking every UI string against the voice rules; (4) when imagery is in scope, an asset-generation agent producing and committing the image library. Auditor agents are read-only on code; exactly one agent at a time may own the source tree for edits, and the cockpit reviews everything.

**Git and parallel agents.** Never rewrite history while any agent is working in the repo. If you stop an agent mid-task, immediately snapshot-commit its working tree so nothing is lost. When building for device while an agent edits the tree, build from a pinned `git worktree` at a known commit.

**Simulator state.** The app's UserDefaults live in the app container plist, and the simulator's prefs daemon caches it. To force a value (e.g. skipping onboarding): shut the simulator down fully, edit the plist with `plutil`, then boot. Editing while booted silently loses.

**Demo craft.** Demo failure paths must be deterministic, not random; a demo that behaves differently every run cannot be rehearsed. Keep one coherent mock-data cast across every surface (same names, companies, timeline). If the user is a founder, build the demo around them: their name, their cofounder in the cast, their world; a founder demoing their own profile is a 10x story. Hide demo-driver buttons behind a long-press so investor hands never find them; the same hidden control should jump between curated states (empty, full, a second persona, before/after) so the story can be told on stage without live data entry. Seed data is part of the build, not an afterthought: never "User 1", lorem, or round dummy numbers — every name, date, and number fits one believable user who has used the app for weeks (streaks add up, dates are recent, history looks lived in), with enough volume that lists and charts read populated (two rows reads as a shell), pre-loaded so the app opens straight into the demo state. Add haptics on primary actions, selections, and success moments (standard generators), and list where you added them — the screenshot loop cannot hear them. Record one clean bezel-framed pass of the golden path as a deliverable; for most demo builds the reel is what gets shared, not the app.

**Real hardware.** Haptics do not exist in the simulator, and shader performance differs on real chips. Anything tactile has literally never been felt until it runs on a phone. Device install: user signs into Xcode once (Settings > Accounts) and picks their personal team once in the GUI (that is the only way to mint the team ID; grep it from the pbxproj afterward), phone needs Developer Mode on, then everything is CLI: `xcodebuild -allowProvisioningUpdates CODE_SIGNING_ALLOWED=YES CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=<id>` and `xcrun devicectl device install app`. Free-account installs expire after 7 days; remote teammates need TestFlight, which needs the paid developer program.

**Setup gotchas** (the setup script handles these, listed here in case it drifts): Homebrew 6 requires `brew trust` for third-party taps; outdated Command Line Tools block source builds until `softwareupdate --install` updates them; fb-idb breaks on Python 3.12+ (pin to 3.11 via pipx).

## Invocation

`/ios-app-builder <app idea, with the parts the user cares about spelled out>`

If the user gives only a vague idea, proceed anyway with your best interpretation. That is the point.
