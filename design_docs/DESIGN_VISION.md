# cityBoy2d - Design Vision

## The Core Idea

A short-form experimental vignette game (10-15 minutes) - the video game equivalent of a short film. Inspired by Gravity Bone and Thirty Flights of Loving's approach to using platformer mechanics as cinematic language.

## The Emotional Core

**"Even if they are living the future they once hoped, they're stuck."**

The melancholy of achievement without fulfillment. The quiet disappointment of getting what you wanted and finding it hollow. The banality of adulthood versus the limitless hope of youth.

**Key phrase:** "No one, not the city or those who surround them, knows what happened. It's just a moment lost in time. But also maybe nothing happened - that's the tragedy."

## Influences & References

### Films
- **Waking Life** (Richard Linklater) - Metaphorical exploration, liminal dreaming
- **Jim Jarmusch films** - Banality + epiphany, poetic mundanity, deadpan poetry
- **Pi** (Darren Aronofsky) - Obsession, patterns, paranoia, urban decay

### Games
- **Gravity Bone** (Brendon Chung) - Spy thriller vignette, cinematography through game mechanics
- **Thirty Flights of Loving** (Brendon Chung) - Abrupt cuts, memory fragments, non-linear storytelling
- **True Detective S1** - "Time is a flat circle"

## Setting & Tone

**The City:** Dense urban walkable streets and alleyways. Cyberpunk/urban aesthetic but crucially - **the city represents HOPE, not despair**. The city is what keeps them going. The prison is internal.

**Time of Day:** Not just aesthetic - it's a narrative tool. Time passing, light changing, the city transforming. This is the Jarmusch influence - the urban loneliness, the routine.

**The Character:** Someone walking through their routine. Training in their past (harvest fields, mentor, limitless possibility). Present in the city (achievement, emptiness, stuck).

## Core Design Concept: The Anti-Platformer

### The Subversion

Use platformer grammar to create *absence* instead of achievement:
- Platforms that look jumpable but lead nowhere
- Doors that don't open
- NPCs who don't respond
- The *shape* of a game without the *reward* of a game

**This mirrors the emotional core:** The character has all the trappings of a life but it doesn't *go* anywhere. The gameplay mirrors this by having all the trappings of a platformer but no destination.

### Making Absence Meaningful (Not Frustrating)

**First 60 seconds must teach the language:**
1. Player starts walking
2. Sees platformer elements (platforms, doors, items)
3. Tries to interact/jump/collect
4. Realizes: the verb is walking and witnessing, not achieving
5. Settles into contemplative experience

**Platformer elements become environmental storytelling:**
- Background platforms NPCs jump between (life happening around you)
- Unreachable ledges (opportunities that passed)
- Doors that don't open (closed possibilities)
- Items that do nothing when touched (meaningless rewards)

## The Loop Structure

**"Time (and space) is a flat circle"**

### Three-Scene Structure

**Scene 1: THE WALK (Present)**
- Horizontal walk through the city (left to right)
- Time progresses: morning → midday → evening → night
- NPCs exist but don't interact (strangers, routine, isolation)
- Platformer elements visible but unreachable/pointless
- Maybe: something in the distance that recedes as you approach
- Destination is just... the other side of the screen

**Scene 2: THE FLASHBACK (Past)**
- Abrupt cut (Thirty Flights style) triggered mid-walk
- Harvest field scene - warm colors, waving wheat/rice
- Walking toward mentor figure
- Maybe dialogue, maybe silence, dream-like
- Could be a teaching moment, could be banal
- Abrupt cut BACK to present

**Scene 3: THE LOOP (Revelation)**
- Walk reaches the end
- Transition back to the start
- But time doesn't reset - or does but NOW you know
- Same walk, same unreachable things
- Realization: "Oh. Again."
- Player experiences the beginning of the cycle
- The epiphany IS the continuation

### Time Progression Options

**Option A: One continuous day**
- Night → morning → midday → evening → night → morning
- Time keeps progressing through the loop
- Communicates: this is forever, nothing changes

**Option B: Multiple day cycles**
- Each loop is a full day
- Subtle changes each time
- Player slowly realizes they're repeating

(Needs playtesting to see which communicates better)

### The Subtle Change

Something small shifts each loop to prevent pure repetition:
- NPC positions different
- The distant thing gets closer/farther
- A previously unreachable platform becomes reachable (but still leads nowhere)
- Flashback triggers at different point
- Time moves faster/slower

Just enough to make player notice: "Wait, is this the same? Or different?"

## What Makes This Shippable

### Already Built ✓
- Player walking mechanics
- Time-of-day progression system
- Level transition system (for flashback cuts)
- Sky color manager (for mood shifts)
- Spawn point system (for loop restart)
- Urban background parallax
- NPC systems

### Need to Build
1. Trigger system for flashback (Area2D or time-based)
2. Flashback scene (harvest field background, mentor sprite)
3. Loop transition back to start
4. Optional: Simple dialogue system for mentor
5. Optional: Ambient audio (city sounds, field sounds)

### Can Cut (Not Needed for This Vision)
- Combat system
- Health/coins/XP tracking
- Multiple save slots
- Enemy systems
- Traditional platformer challenges

## The One Thing That Changes

**From Gravity Bone:** The change was "you were playing a spy game, now you're dying." Simple. Devastating.

**For cityBoy2d:** What's the ONE THING that's different between start and end?

Possibilities:
- The city looks the same but feels different
- The walk is the same but player awareness has changed
- Time shifts in a meaningful way
- A flashback repeats with different meaning
- The hunt for the distant thing resolves (or doesn't)

**To be determined through prototyping.**

## The Prototype (Build This First)

### Week 1: Three Scenes

**Day 1:** City walk level with time progression
**Day 2:** Flashback scene with abrupt transitions
**Day 3:** Loop-back mechanic with subtle change

### Testing Questions

After playing the prototype for 15 minutes:
- Does this feel contemplative or just empty?
- Does the loop land as tragic or just repetitive?
- Is the absence meaningful or just missing content?
- Does time progression communicate without explanation?
- Does the abrupt flashback feel disorienting in the right way?

**Success metric:** Does this feel like experiencing a mood rather than waiting for gameplay?

## Design Principles

1. **Confidence over compromise** - Commit fully to "walking sim with platformer language" rather than hedging with "real gameplay"

2. **Absence is content** - If gameplay is empty, visuals/audio must be rich. Time-of-day transitions carry weight. The city feels alive even if the player is stuck.

3. **First minute teaches the language** - Player must understand quickly that emptiness is intentional, not broken.

4. **Beauty in banality** - Jarmusch influence. The ordinary must feel poetic.

5. **No time estimates** - Focus on emotional pacing, not clock time.

## Open Questions (To Resolve Through Making)

- Does time progression work better as continuous or cyclical?
- How many loops before it ends? (3 times? 5 times? Until player stops?)
- What specifically triggers the flashback?
- Does the mentor speak? What do they say?
- What is the distant thing the player walks toward?
- What exactly was the "thing that happened" (or didn't happen)?
- Is ambiguity the point, or does there need to be a clearer narrative?

## The Vision in One Sentence

**A character walks through a city that represents their hopes, trapped in a loop of days that all feel the same, interrupted by fragments of a past when anything felt possible.**

---

*"Maybe nothing happened. That's the tragedy."*
