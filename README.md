# Build a native iOS app with Claude Code. No coding required.

I don't write code. The day Claude Fable 5 launched, I read a post by a 12-year Apple UI/UX veteran who built a calorie tracker with three prompts, and decided to teach myself to do the same thing from scratch. Two one-day builds later, I can run an iOS build the way a designer runs a studio: agents do the engineering, I do the taste.

What that actually produces, built in one day by someone who has never written Swift:

https://github.com/briangrover9-hue/claude-ios-app-builder/raw/main/demo/placemat-demo.mp4

A complete dining product: data-computed onboarding that names your taste archetype, a recommendation engine with per-person reasoning, a scored map, a hosting mode that builds menus around allergies and orders the groceries, and a bill that splits itself with the tax and tip math exact to the cent. Five surfaces, generated photography, a code-drawn brand and logo, every animation frame-audited. ([The video](demo/placemat-demo.mp4) is in this repo; demo data throughout, integrations simulated.)

My total hands-on time across the build was steering: a few prompts and blunt taste notes.

This repo is the reusable process, packaged as a [Claude Code](https://claude.com/claude-code) skill. It is not a template or a starter app. It teaches the agent a working method:

1. **Build** the whole app from one prompt, and verify every screen and interaction itself by driving the iOS simulator (tapping, swiping, screenshotting).
2. **100x the design** in a second pass: record video of every flow, dump frames with ffmpeg, write pixel-diff scripts, and loop until every transition is flawless frame to frame.
3. **Steer** with your taste notes. You look at real screens and say what feels off. That part stays human.
4. **Due diligence**, unprompted: audit the build against every document you provided, confess known problems before you find them, test that the demo closes the product's loop, sweep the copy for AI voice, and verify everything with its own eyes.

The core method is distilled from [this post by @anshuc](https://x.com/anshuc/status/2064573467182412103), a 12-year Apple UI/UX veteran who built a calorie tracker this way on Claude Fable 5's launch day. The build prompts in `skill/ios-app-builder/reference-article.md` are his, shared with attribution.

What's new here came from actually shipping products with this skill as a non-coder, across two full one-day builds. From the first: the setup automation, and Phase 4 of the skill, a due-diligence layer the original method doesn't have. Audit the build against every source document you gave the agent. Make the agent confess what it knows is wrong before you find it. Test whether the demo closes the product's loop. Sweep the copy for AI voice.

The second build added the layers that separate a pretty demo from something that reads like a funded product:

- **An operating model.** The main session stays conversational while background agents do the heavy work in parallel, each in its own git worktree with its own simulator. One tree owner at a time, commits after every green build, and liveness checks on a clock, because agents sometimes die silently and an uncommitted hour is an hour you lose.
- **A premium design playbook.** Ten concrete recipes (no true gray, color rationing, scroll-aware scrims, count-up numbers, ceremony choreography, phase-machine correctness, staggered entrances, shared elements, whisper/shout typography, shader prewarming) that turn "make it look like an Apple Design Award app" from a wish into a checklist.
- **Wireframe intake.** When you provide mockups or reference designs, the agent treats them as spec: match the structure, upgrade the fidelity, and confess every place it drifted before you find it.
- **Generated imagery as a requirement, not a nice-to-have.** For visual concepts the skill now stops and asks for an image key instead of silently shipping flat vector art that reads like a template.
- **Demo craft that holds up on camera.** Lived-in seed data with story arcs hidden in it, deterministic choreography you can rehearse, real brand context, and a bezel-framed golden-path reel as the deliverable.

Every one of those exists because its absence cost real time on a real build.

## What you need

- A Mac (Apple Silicon or Intel) with macOS 15+
- Xcode (free, from the App Store; the setup script walks you through it)
- A Claude subscription that includes Claude Code (a full build used roughly 1 to 1.5M tokens, about 5% of a 20x plan's weekly quota)
- No Apple Developer account needed until you want the app on a physical phone

## Setup (once, ~15 minutes plus the Xcode download)

```bash
cp setup/ios-dev-setup.sh ~/ios-dev-setup.sh
bash ~/ios-dev-setup.sh
```

The script is safe to re-run. First run sends you to the App Store for Xcode; second run installs everything else (Homebrew, ffmpeg, idb for simulator control, Pillow for pixel analysis) and creates an optional `~/.agent-env` for API keys if your app idea needs AI features or image generation.

Then install the skill:

```bash
mkdir -p ~/.claude/skills
cp -R skill/ios-app-builder ~/.claude/skills/
```

## Use

Open Claude Code in a fresh empty folder and describe the app you want:

```
/ios-app-builder a personal workout logger. minimalist, image-heavy, delightful
```

Spell out the parts you care about and leave the rest open on purpose. Then walk away. Expect a few hours of agent time for the build, another couple for the design pass. Your job is the last mile: open the app, react honestly, and give blunt notes ("the grid layout is cheesy, go more image-centric"). Specific steering is the fastest path to something you're proud of.

## What makes this work (the short version)

The single highest-leverage idea, straight from the original post: **give the agent a way to check its own work, and demand that it does.** The skill makes the agent drive the simulator itself, record its own animations, and audit them at the frame level. Without that loop you get a plausible-looking app full of glitches. With it, the agent finds and fixes bugs you'd never have the vocabulary to report.

## Credit

The core method and the verbatim prompts belong to [@anshuc](https://x.com/anshuc/status/2064573467182412103). Go read the original post; it's excellent. This repo exists so people who can't code can run the same play.

## License

MIT for everything in this repo except `reference-article.md`, which quotes the original author's publicly shared prompts and learnings with attribution.
