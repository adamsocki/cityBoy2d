# cityBoy2d - Implementation Plan

*Living document - update as development progresses and vision clarifies*

---

## Philosophy

**Build to discover, not to complete.** Each phase is about learning what the game wants to be. Expect to throw things away. Expect to discover the real game buried in the prototype.

**Critical path over completeness.** Focus on what makes the core experience work. Everything else is secondary.

---

## Phase 1: The Feeling Prototype (Week 1-2)

**Goal:** Build the minimum to test if the core feeling works. Can you create "contemplative walking interrupted by memory"?

### Programming
- [ ] **Horizontal city walk level**
  - Single long scene, left-to-right movement
  - Player spawns at left edge
  - Right edge is the "end"

- [ ] **Time progression system integration**
  - Time advances as player walks (distance-based or duration-based)
  - Hook TimeManager to player position or timer
  - Test: Does gradual time change communicate without UI?

- [ ] **Flashback trigger**
  - Area2D trigger at midpoint of walk
  - Abrupt scene transition (no fade, just cut)
  - Return trigger in flashback scene

- [ ] **Loop-back mechanic**
  - When reaching right edge, transition back to start
  - Spawn player at left edge again
  - Preserve or shift time-of-day state

- [ ] **Anti-platformer elements (basic)**
  - Place platforms player can see but can't reach
  - Doors/objects that don't respond to interaction
  - Test: Does futility feel intentional or broken?

### Art
- [ ] **City walk background**
  - Reuse existing parallax urban backgrounds
  - Ensure they work across all times of day
  - Mood > detail at this stage

- [ ] **Harvest field background (flashback)**
  - Can be simple placeholder (warm colors, horizontal lines)
  - Contrast is more important than fidelity
  - Just needs to feel different from city

- [ ] **Mentor sprite (flashback)**
  - Can be existing NPC sprite with different color palette
  - Just needs to read as "different person, different time"

- [ ] **Platformer elements as scenery**
  - Background platforms (visual only)
  - Doors/archways that frame but don't function
  - Items that exist but don't collect

### Audio
- [ ] **Ambient city sounds**
  - Soft urban ambience (traffic distant, footsteps, wind)
  - Should feel alive but not distracting
  - Can be simple loops

- [ ] **Flashback soundscape**
  - Contrast: nature sounds, wind through grass, silence
  - Abrupt audio cut when transitioning (no crossfade)

- [ ] **Footstep sounds (optional)**
  - Only if silence feels wrong
  - Should match walking pace

### Narrative/Story
- [ ] **No text yet**
  - Let the visuals/structure tell the story
  - Resist urge to explain

- [ ] **Test without dialogue**
  - See if flashback works with just presence
  - Only add words if silence doesn't work

### Playtest Questions
- Does walking feel contemplative or boring?
- Does time progression communicate?
- Does the flashback cut feel meaningful or jarring?
- Does the loop-back create "oh, again" feeling?
- Do unreachable platforms feel intentional?

**SUCCESS CRITERIA:** 5 minutes of play that makes you *feel something*, even if rough.

---

## Phase 2: The Core Experience (Week 3-4)

**Goal:** Refine the loop structure. Add the layers that make it resonate. This is where you discover the real rhythm.

### Programming
- [ ] **Refine loop structure**
  - Decide: continuous time or reset time?
  - Implement subtle changes per loop (NPC positions, time speed, etc.)
  - Add loop counter (hidden or visible?)

- [ ] **Multiple flashback triggers**
  - Different memories at different points?
  - Or same memory that evolves?
  - Test which feels right

- [ ] **The distant thing**
  - Object/light/figure always ahead of player
  - Recedes as player approaches, or stays fixed distance
  - Test: Does this add longing or frustration?

- [ ] **Interaction points (maybe)**
  - Can player stop and observe?
  - Does stillness change anything?
  - E key to "acknowledge" but not change things?

- [ ] **End condition**
  - After X loops, does it end?
  - Does time reach a specific state?
  - Does player choose to stop walking?

### Art
- [ ] **Refine city scene**
  - Add more visual detail to platforms/doors
  - Make unreachable things clearly visible
  - Ensure time-of-day transitions feel smooth

- [ ] **Background NPCs (city)**
  - Walking in background on unreachable platforms
  - Life happening around player
  - Not interactive, just present

- [ ] **Flashback scene polish**
  - Actual harvest field art (wheat/rice waving)
  - Warm color palette (golden hour feeling)
  - Mentor figure with distinct silhouette

- [ ] **Visual cues for loop**
  - What changes subtly each time?
  - NPC positions, lighting, small details
  - Should be noticeable but not obvious

### Audio
- [ ] **Music vs. ambience decision**
  - Test both: pure ambience vs. minimal music
  - Music should be ambient/drone if used
  - Avoid anything melodic that implies progress

- [ ] **Time-of-day audio shifts**
  - Morning: birds, quiet city waking
  - Midday: traffic, urban hum
  - Evening: wind, distant sounds
  - Night: sparse, isolated

- [ ] **Flashback audio design**
  - Wind through grass
  - Distant mentor voice (if dialogue added)
  - Contrast with city density

### Narrative/Story
- [ ] **Decide on dialogue**
  - Does mentor speak?
  - If yes: one line? A conversation?
  - Dream-like vs. realistic speech?

- [ ] **Clarify "what happened"**
  - You don't need to tell the player
  - But YOU need to know
  - Informs every other choice

- [ ] **Environmental storytelling**
  - What do the unreachable platforms represent?
  - What does the city at different times tell us?
  - Subtext > text

### Playtest Questions
- How many loops before it feels repetitive vs. meaningful?
- Does the subtle change per loop register?
- If dialogue exists, does it help or hurt?
- What's the right length for the full experience?
- Does the ending land?

**SUCCESS CRITERIA:** 10-15 minute experience that feels complete, even if rough.

---

## Phase 3: Polish & Cohesion (Week 5-6)

**Goal:** Make everything feel intentional. Visual/audio quality catches up to design vision. This becomes "shippable."

### Programming
- [ ] **Performance optimization**
  - Ensure smooth frame rate
  - Optimize parallax if needed

- [ ] **Bug fixes**
  - Spawning issues
  - Transition glitches
  - Edge cases in loop logic

- [ ] **Final end condition**
  - Credits? Fade to black? Loop indefinitely?
  - Test what feels right

- [ ] **Accessibility considerations**
  - Colorblind-friendly palette shifts?
  - Subtle UI hints for those who need them?

### Art
- [ ] **Final art pass on city**
  - Consistent art style across all times of day
  - Platform/door designs feel cohesive
  - Background layering depth

- [ ] **Final art pass on flashback**
  - Harvest field animation (wind through grass)
  - Mentor character detail
  - Lighting/mood finesse

- [ ] **Visual effects**
  - Transition cuts (glitch effect? Clean cut?)
  - Time-of-day transitions (if visible)
  - Particle effects (rain at night? Dust in flashback?)

- [ ] **Title screen / end screen**
  - Minimal but present
  - Consistent with tone

### Audio
- [ ] **Final audio mix**
  - Balance ambience/music/SFX
  - Ensure cuts between scenes feel right
  - Silence as intentional choice

- [ ] **Audio polish**
  - Footsteps sync to animation
  - Ambient loops are seamless
  - Flashback transition audio (whoosh? Silence?)

- [ ] **Final music decision**
  - If using music: one track that evolves? Different per time?
  - If pure ambience: ensure richness

### Narrative/Story
- [ ] **Final dialogue pass**
  - Every word earns its place
  - Cut anything explanatory
  - Ambiguity is okay

- [ ] **Credits**
  - Minimal, in tone with game
  - Acknowledge influences if desired

- [ ] **External context (itch.io description)**
  - How do you frame this without over-explaining?
  - Short paragraph that sets expectations

### Playtest Questions
- Does the full experience feel cohesive?
- Is the pacing right?
- Does it stick with you after playing?
- Would you show this to someone?

**SUCCESS CRITERIA:** You can release this and feel proud.

---

## Phase 4: Release Prep (Week 7)

### Technical
- [ ] **Build for target platforms** (Windows/Mac/Linux)
- [ ] **Test builds on different machines**
- [ ] **File size optimization**
- [ ] **Controller support** (if desired)

### Marketing/Release
- [ ] **Itch.io page setup**
  - Screenshots from each time of day
  - One GIF of walking → flashback transition
  - Description that doesn't spoil

- [ ] **Press kit** (simple)
  - Game description
  - Developer statement
  - Screenshots
  - Influences

- [ ] **Trailer** (optional, 30-60 seconds)
  - Show the walking
  - Show one flashback cut
  - Show the loop
  - Don't explain, just evoke

### Community
- [ ] **Playtest with 3-5 people**
  - Watch them play (don't explain)
  - Note where they get confused
  - Note what they feel

- [ ] **Decide on pricing**
  - Free? Pay-what-you-want? $3-5?
  - Experimental short games can be any of these

---

## Ongoing Throughout All Phases

### Reference/Inspiration
- [ ] **Replay Gravity Bone** (study the cuts, pacing, subversion)
- [ ] **Replay Thirty Flights of Loving** (study memory structure)
- [ ] **Watch a Jarmusch film** (steal the banality + beauty)
- [ ] **Watch Pi opening sequence** (study urban isolation)

### Documentation
- [ ] **Update DESIGN_VISION.md** when vision clarifies
- [ ] **Screenshot interesting bugs** (might inspire something)
- [ ] **Journal what you're feeling** as you build (this informs the work)

### Self-Check Questions
- Am I building what I want, or what I think I "should"?
- Is this complexity serving the feeling, or just complexity?
- What would I cut if I had to ship tomorrow?
- Am I being precious about something that doesn't matter?

---

## Critical Path Summary

If you only focus on these, you'll have a shippable game:

1. **Week 1:** City walk + time progression + one flashback + loop-back
2. **Week 2:** Refine the feeling, add subtle loop variations
3. **Week 3:** Lock the structure, decide on dialogue/no dialogue
4. **Week 4:** Polish art/audio to match vision
5. **Week 5:** Playtest, fix, refine pacing
6. **Week 6:** Build and release

Everything else is bonus.

---

## Decision Log

*Use this section to track major decisions as you make them*

| Date | Decision | Reasoning |
|------|----------|-----------|
| | | |

---

## Notes to Self

*Capture thoughts, ideas, cuts, pivots here*

---

## Where to Start RIGHT NOW

1. **Open Godot**
2. **Create new scene:** `city_walk.tscn`
3. **Add Player node** to the scene
4. **Add existing parallax background**
5. **Test walk from left to right**
6. **Hook TimeManager to advance time as you walk**

That's it. Build from there.

The game will tell you what it needs as you make it.
