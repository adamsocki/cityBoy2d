# Making an Anti-Platformer: When Getting What You Want Feels Hollow

**Introduction**
I'm making a 10-minute experimental platformer that subverts everything platformers are supposed to do—platforms lead nowhere, NPCs don't respond, items do nothing. It's about someone who got what they wanted and found it empty. Here's how I'm using game mechanics as cinematic language.

---

## The Emotional Core: "Even if they are living the future they once hoped, they're stuck."

- The central feeling: melancholy of achievement without fulfillment
- Inspired by the quiet disappointment of adulthood versus the limitless hope of youth
- Key phrase from my design notes: "Maybe nothing happened. That's the tragedy."
- Not a game about depression or despair—it's about banality, routine, the slow fade
- The city represents HOPE (crucially, not dystopia)—but the character is internally trapped

---

## The Influences That Shaped This

**Films:**
- **Gravity Bone / Thirty Flights of Loving** - Using platformer mechanics as cinematography, abrupt cuts, memory fragments
- **Jim Jarmusch** - Poetic mundanity, beauty in banality, urban loneliness as aesthetic
- **Waking Life** - Metaphorical exploration, liminal dream logic
- **Pi** / **True Detective S1** - "Time is a flat circle," patterns, cycles, obsession

**The synthesis:** Can I make a platformer that feels like a Jarmusch film? Can emptiness be content?

---

## The Core Design Concept: The Anti-Platformer

**The Subversion:**
- Use platformer *grammar* to create *absence* instead of achievement
- Platforms that look jumpable but lead nowhere
- Doors that don't open
- NPCs in the background living their lives, but you can't reach them
- The shape of a game without the reward of a game

**Why This Mirrors the Theme:**
- Character has all the trappings of a life but it doesn't *go* anywhere
- Gameplay has all the trappings of a platformer but no destination
- The medium IS the message

**The Critical First 60 Seconds:**
- Must teach the player: "the verb is walking and witnessing, not achieving"
- Player tries to jump to platforms, interact with NPCs, collect items
- Realizes: this is intentional emptiness, not broken gameplay
- Settles into contemplative mode or bounces off entirely (that's okay)

---

## The Three-Scene Loop Structure

**Scene 1: THE WALK (Present)**
- Horizontal walk through city (left to right)
- Time progresses: morning → midday → evening → night
- Platformer elements visible but unreachable/meaningless
- Maybe something in the distance that recedes as you approach

**Scene 2: THE FLASHBACK (Past)**
- Abrupt cut (Thirty Flights style) mid-walk
- Harvest field scene—warm colors, waving wheat, mentor figure
- Could be teaching, could be banal, dream-like
- Abrupt cut BACK to present

**Scene 3: THE LOOP (Revelation)**
- Walk reaches the end
- Transition back to the start
- Time doesn't reset—or it does, but NOW you know
- Player experiences: "Oh. Again."
- The epiphany IS the continuation

**Subtle changes each loop:**
- NPC positions shift
- Flashback triggers at different points
- Time moves faster/slower
- Just enough to make player ask: "Is this the same? Or different?"

---

## How the Technical Architecture Supports the Vision

**Already Built (The Lucky Parts):**
- **TimeManager singleton** - Controls day/night cycle with 6 time periods (MORNING, MIDMORNING, NOON, AFTERNOON, EVENING, NIGHT)
- **SkyColorManager** - Smooth color transitions tied to time of day (crucial for mood)
- **LevelManager** - Scene transitions with fade effects (perfect for abrupt flashback cuts)
- **Spawn point system** - Can loop player back to start with different spawn IDs
- **BaseLevel pattern** - Common level architecture makes building consistent scenes easy

**What This Means:**
- I accidentally built the perfect architecture for a looping vignette game while thinking I was making a platformer
- The singleton signal-based system means time/color/transitions all coordinate cleanly
- Can trigger flashback via Area2D collision or time-based event
- Loop transitions just use the same LevelManager system as normal level changes

**What I Still Need to Build:**
1. Harvest field scene (new parallax background, mentor sprite)
2. Flashback trigger system (probably Area2D mid-walk)
3. Loop variation logic (subtle NPC position changes, etc.)
4. Optional: Simple dialogue for mentor
5. Optional: Ambient audio layers (city sounds vs field sounds)

---

## Making Absence Meaningful (Not Just Empty)

**The Design Challenge:**
- How do you make "nothing happens" feel intentional, not broken?
- How do you make emptiness *beautiful* instead of boring?

**My Strategies:**
- **Rich visuals** - If gameplay is empty, atmosphere must be full. Time-of-day transitions carry weight
- **Environmental storytelling** - Background NPCs jumping between platforms (life happening around you)
- **Audio layers** - City ambience, footsteps, distant sounds
- **Confidence over compromise** - Commit fully to "this is a walking experience" rather than hedging with "real gameplay"

**Reference points:**
- Dear Esther / Gone Home showed walking sims can work
- Gravity Bone showed you can subvert expectations in 5 minutes
- I'm betting I can do both: subvert platformer expectations in a walking experience

---

## Open Questions I'm Prototyping to Answer

**Does time progression work better as continuous or cyclical?**
- Option A: One continuous day (night → morning → night → morning across loops)
- Option B: Each loop is a full day cycle
- Need to playtest to see which communicates "stuck forever" better

**How many loops before it ends?**
- Three times? Five times? Until player closes the window?
- What's the "One Thing That Changes" at the end? (à la Gravity Bone)

**What triggers the flashback?**
- Specific location (Area2D trigger)?
- Time-based (always at NOON)?
- Random timing each loop?

**Does the mentor speak?**
- Silent and dream-like?
- Dialogue that changes meaning on subsequent loops?
- Ambiguous enough to let players project their own meaning?

**What exactly happened (or didn't happen)?**
- Is ambiguity the point?
- Or does there need to be a clearer narrative anchor?

---

## The Prototype Plan

**Week 1 Goal: Build the Three-Scene Prototype**
- Day 1: City walk level with time progression working
- Day 2: Harvest flashback scene with abrupt transition triggers
- Day 3: Loop-back mechanic with at least one subtle change

**Success Metric:**
- Does this feel like experiencing a *mood* rather than waiting for gameplay?
- Does the loop land as tragic or just repetitive?
- Do playtesters understand the absence is intentional within 60 seconds?

**If it works:** Expand variations, add audio layers, polish transitions
**If it doesn't:** Might need to add *something* interactive to anchor the experience

---

## Why This Might Actually Ship

**The Form Factor:**
- 10-15 minutes = no filler, pure artistic vision
- Short-form experimental vignette (like a short film) sets different expectations than a full game
- Can afford to be polarizing when it's not asking for 40 hours

**The Tech:**
- Most of the hard stuff is already built (singleton architecture, time system, transitions)
- New content needed is small (one new scene, some sprites, audio)
- Godot makes scene composition fast

**The Risk:**
- Some players will think it's broken and quit in 30 seconds (that's fine)
- Some will find it pretentious or empty (also fine)
- But some might feel exactly what I'm trying to communicate—and that's worth it

---

## Reflections: Making Weird Stuff Is Easier Than I Thought

- Started building a "normal platformer" with health, coins, enemies, XP tracking
- Realized halfway through: I don't care about any of that
- The DESIGN_VISION.md document clarified everything—the tech serves the vision, not the other way around
- Turns out the singleton architecture I built for a "real game" works perfectly for an experimental vignette
- Sometimes you accidentally build the right foundation while aiming for the wrong destination

**Meta note:** This blog post itself is part of the process—writing this helped me realize what I'm actually making.

---

## What's Next

- Build the three-scene prototype this week
- Playtest with a few people who *get* experimental games
- Document what works/what doesn't
- Decide: commit to this vision or pivot back to traditional platformer?
- Either way, shipping *something* small and weird feels better than building a mediocre traditional game

---

## Outline Metadata

**Template Used:** Learning & Experimentation (adapted for design vision)

**Suggested Visual Assets:**
- Screenshot of city walk with time-of-day color transition
- Diagram of the three-scene loop structure
- Side-by-side comparison: "normal platformer" vs "anti-platformer" visual language
- Screenshot of DESIGN_VISION.md (shows the thinking process)
- GIF of subtle sky color transition during walk

**Tone:** Conversational, introspective, honest about experimental risk, excited about the concept

**Missing Info to Add When Writing:**
- Specific example of what the flashback scene will look like visually
- Concrete example of a "subtle change" between loops
- Link to Gravity Bone/Thirty Flights if writing for audience unfamiliar with them
- Maybe a short video of the time progression system in action
