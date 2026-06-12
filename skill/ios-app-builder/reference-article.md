# Source article: "Building a beautiful iOS app with 3 Claude Fable prompts"

Author: 12-year Apple UI/UX veteran. Original post: https://x.com/anshuc/status/2064573467182412103
This is the proven approach this skill replicates. The verbatim prompts below are the templates — adapt the app concept, keep the structure and instructions.

## The author's learnings (verbatim distillation)

- **The highest-leverage instruction**: tell Claude to directly manipulate the simulator and test its work, verifying every interaction and transition. In the design pass, tell it to verify every frame and pixel. Don't specify how — it figures it out (brew installs idb for simulated touch, ffmpeg/ffprobe to record and dump frames, custom Python/PIL scripts for pixel diffs, crops, zoom analysis to fix pops and hitches).
- "The most important thing is setting the intent and expectation that you want a flawless, smooth, hitch-free interface, and that it needs to actually verify this. The model is smart enough to figure out the details, but you have to actually tell it to verify animations at the frame level."
- Have a clear idea of the app and explain the parts you actually care about, while leaving the rest open-ended on purpose.
- Instruct extreme meticulousness about details, transitions, and "delight."
- Give a rough workflow including documenting work (intent, not just outcomes) so it doesn't lose track across compactions and multiple agent threads.
- The second design pass works because the model runs with full attention on aesthetics — no functional architecture competing for focus.
- Hyperbole about Apple design quality ("Apple Design Award", "something Alan Dye would use") helps a little.
- Specific steering ("the alternating layout is a bit cheesy. Simplify, go more image-centric") is the fastest way to kill the worst visual issues.
- "Pixel-perfect, every transition flawless frame-to-frame" is the single most important Phase 2 instruction — it's what makes the model actually record and dump frames and work until transitions are fluid.
- Setup: empty folder, Claude Code in terminal, no Xcode GUI needed (just xcodebuild/xcrun), agent-scoped API keys in a .env sourced by .zshrc. ~1-1.5M tokens, ~4 hours, <5 min human involvement.
- "The model goes very far with very little, but you sadly do still have to do the thinking. Give it ways to check its own work and you will be surprised by what it can do with a single prompt."

## Prompt 1 — the one-shot build (verbatim)

> I want you to build an iOS calorie tracker app. Should have a super clean, minimalist design, very design-forward and aesthetic. Sweat all the tiny details and make everything feel super premium. Make every interaction extremely delightful - you can go so far as to write custom Metal shaders, custom UI components, etc, to make everything fluid, unique, delightful.
>
> The idea I have here is to make it one unified conversational experience. I should be able to page through different days, each of which is a conversation thread with an agent. The agent should have whatever tools it needs to be able to query a nutrition DB or my past history and update the tracked food. It should feel personal and friendly.
>
> I want food entries to be beautiful - it should understand the foods and generate nice, consistent visuals for them, like studio photo looking images with consistent styling. You can use modern small/fast image generation models like Gemini or OpenAI; look it up. I want to be able to somehow zoom out of the thread view and be able to see all my meals in a scrollable timeline where each meal is represented using these images - should feel like a really premium magazine catalog kind of view. Make every transition fluid and delightful, fun gestures, bouncy, Apple-y liquid glass kind of feel to it. Use shader effects to make transitions look special and memorable, to make image generation look good, even to make the chat and token streaming experience unique and fun. Think through the flows to make it usable and show me the information I need without cluttering the screen or making it too technical.
>
> For the most part you should just use your best judgment, not ask me questions, unless you get hard stuck - I want you to interpret this however you want and show me what you are capable of. Build it end to end and verify all the interactions and transitions and functionality in the simulator if you can. Feel free to use the web to download any resources and documentation needed to make this feel great; don't just resort to the boring iOS standards for everything because that's easy. Dig deep and sweat every detail. Have fun!
>
> Start by initializing git, make commits as you go, keep yourself organized with docs so you don't lose track. Write clean, maintainable, modular code.

## Prompt 2 — the 100x design pass (verbatim)

> This is a great start but people on X are complaining it looks like AI slop because of the generic gradients, visual glitches, and awkward layout structure. So you need to cook hard and prove them wrong. I want you to 100x the design - get every pixel perfect, every transition flawless frame to frame.
>
> Find a way to carefully audit every frame/pixel and make it look absolutely stellar, like top 1% of human designers, instantly eligible for an Apple Design Award.
>
> Everything is on the table. Want to write your own components from scratch? Do it. Build a game engine for all I care. Write the most god forsaken Metal shaders the world has ever seen. Just make it look absurdly good. Don't stop until it looks like something Alan Dye would use. Make NO mistakes

## Prompt 3 — specific steering (verbatim examples)

> Consider a model that can do transparency properly. Make the high level grid view look nicer too; the alternating layout is a bit cheesy. Simplify, go more image-centric
>
> I want tiles to flow smoothly between the card and grid views. Build some gorgeous custom views/transitions, don't just use boring iOS view controller transitions.
