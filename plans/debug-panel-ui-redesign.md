# Debug Panel UI Redesign - Implementation Plan

**Created:** 2026-01-04  
**Status:** Planning  
**Estimated Complexity:** High

## Overview

Redesign the in-game debug panel UI with a dark theme, high-contrast typography, collapsible sections, a resizable panel, and minimize-to-bar capability. The panel should remain freely draggable (no snapping) and only draggable from the title bar area.

## Context

- The debug UI is instantiated by `res://developer_mode.gd` (F12 toggle) using `res://ui/debug/debug_panel.tscn`.
- Theme configuration exists in `res://debug_system/debug_config.gd` (`UI_COLORS`, `UI_FONTS`, etc) and reusable styling exists in `res://ui/debug/debug_theme_utils.gd`, but is not fully wired into the UI.
- UI settings persistence is handled in `res://debug_system/debug_draw_manager_singleton.gd` via `user://debug_ui_config.json` (currently font size + position).

## Step-by-Step Implementation

### Phase 1: Theme Foundation

#### Step 1.1: Ensure config is globally accessible

**What:** Make `DebugConfig` available as a script class so `DebugThemeUtils` can reference `DebugConfig.*` constants safely.  
**Where:** `res://debug_system/debug_config.gd`  
**Why:** `DebugThemeUtils` expects `DebugConfig.UI_COLORS`/`UI_FONTS`/etc; without a global class, references will fail at parse time.

#### Step 1.2: Keep theme utilities centralized

**What:** Use `DebugThemeUtils` to style the panel/tabs programmatically via StyleBoxFlat and theme overrides (no `.tres` theme files).  
**Where:** `res://ui/debug/debug_theme_utils.gd`, `res://ui/debug/debug_panel.gd`  
**Why:** Enables rapid iteration and consistent styling across all debug UI components.

### Phase 2: Core Panel Features

#### Step 2.1: Add minimize + resize + title-bar-only drag

**What:** Replace the panel scene structure to support:
- Minimized bar view (32px high) with title + expand button
- Expanded panel view with title bar + minimize button
- Resize zones (right, bottom, corner) with cursor feedback
- Drag only from title bar areas (expanded + minimized)

**Where:** `res://ui/debug/debug_panel.tscn`, `res://ui/debug/debug_panel.gd`  
**Why:** Meets interaction requirements (minimize, resizable, free drag).

#### Step 2.2: Persist minimize + size state

**What:** Add `ui_minimized` and `ui_size` to `DebugDrawManager` state and persist to `user://debug_ui_config.json`.  
**Where:** `res://debug_system/debug_draw_manager_singleton.gd`  
**Why:** Panel should restore size and minimized state across sessions.

### Phase 3: Collapsible Sections

#### Step 3.1: Create a reusable `CollapsibleSection`

**What:** Implement a `VBoxContainer`-based component with a clickable header and content container that can show/hide.  
**Where:** `res://ui/debug/collapsible_section.gd`  
**Why:** Reusable sections across tabs and consistent styling/behavior.

#### Step 3.2: Refactor debug tabs into sections

**What:** Wrap tab controls into collapsible sections:
- Time: Time Control, Progression, Quick Jump, Info
- Physics: Visualization, Player Info
- Level: Visualization, Level Info

Also wrap tab content in a `ScrollContainer` to handle overflow.  
**Where:** `res://ui/debug/*_debug_tab.gd`, `res://ui/debug/*_debug_tab.tscn`

### Phase 4: Polish

#### Step 4.1: Theme the controls section

**What:** Apply dark styling to buttons/labels in the debug controls section (font size controls, reset position).  
**Where:** `res://ui/debug/debug_controls_section.gd`

#### Step 4.2: Typography + value emphasis

**What:** Use semantic text colors:
- Headers/title: `text_header` (larger size)
- Secondary labels: `text_secondary`
- Dynamic values: `text_value` (cyan-green), use monospace where helpful

**Where:** Tabs and theme utils.

## Dependencies

- `DebugDrawManager` autoload must remain available at `/root/DebugDrawManager`.

## Testing Strategy

Manual testing in-editor:
- Toggle debug panel with F12.
- Verify minimize/expand preserves previous expanded size.
- Verify resize from right/bottom/corner with correct cursors.
- Verify drag works only from title bars (expanded and minimized).
- Verify size is clamped to min/max and state persists across restarts.
- Verify collapsible sections expand/collapse without breaking existing button/slider/toggle behavior.

## Success Criteria

- [ ] Dark theme renders across panel and all tabs
- [ ] High contrast text remains readable
- [ ] Resizes from right, bottom, corner with cursor feedback
- [ ] Drag restricted to title bar; no snapping
- [ ] Minimize to bar and expand restores previous size
- [ ] Minimize + size persist across sessions
- [ ] Collapsible sections function correctly
- [ ] Existing functionality preserved (sliders, toggles, buttons)

