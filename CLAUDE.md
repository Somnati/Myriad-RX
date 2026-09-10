# Myriad RX (Remix Edition)

GameMaker Studio 2024.14. **A ground-up remake of Myriad DE** — his live
idle game (readable reference at
`C:\Users\sora0\Desktop\GM Projects\Myriad DE.yyp`, READ-ONLY: never
edit it) — faithful to DE's look and feel, with every script and
system rebuilt clean. Targets follow DE (mobile portrait first; PC
alongside). The user (Somnati) pushes via GitHub Desktop; single-chat
mode: Claude edits the working tree and commits locally, he publishes.

## Origin + the prime directive (his call, 2026-08-14)

- A FRESH BUILD (his call — the initial copy-the-techdemo-whole
  scaffold was discarded the same day): only the techdemo's ENGINE
  layer was ported — ~214 assets (save system, settings framework,
  menu v2, statistics v2, UI kit, input arbitration, arb bignum,
  roomtrans, banner/dialogue/gamepad/services, sprite fonts) — with
  the shared files (setgame boot, handle_save, handle_settings,
  settings_content, stats_v2_content, menu2_content, scr_escape,
  obj_scrollbar lanes, syst_input families) stripped to
  engine-only, each carrying a "rebuilt DE systems add their block
  HERE" comment at the seam. The port was dependency-closure
  verified (every referenced asset exists; no orphan globals) —
  scratchpad tooling, rebuildable. NO techdemo game code came
  along: no dials/cores/batteries/materials/offline — those return
  only as DE-faithful rebuilds. Techdemo II stays on disk as the
  parts bin (`...\Techdemo II\techdemo.yyp`, its CLAUDE.md
  documents everything; feat/materials r6+r7 sits unmerged on its
  worktree there).
- Rooms: rm_gameload (boot) → rm_titlescreen ("myriad rx") →
  rm_clicker (NEW: empty 144x296 portrait shell, DE's money-room
  shape — the first rebuild target) + rm_saves / rm_settings /
  rm_statistics_v2 / rm_gamepad / rm_services / rm_quit.
- **HIS LAW: complexity does not equal fun.** DE's simple established
  loop comes FIRST — full parity, faithful feel — and only then does
  RX expand, one addition at a time, each judged by whether it "feels
  nice" and draws him in. Techdemo systems return only through that
  gate. Some DE mechanics get reworked during the remake — HE flags
  which; never rework silently in a "faithful" pass.
- Roadmap: (1) strip the techdemo surface (menu/rooms/boot flow) to a
  bare shell, (2) rebuild DE's game room by room — portrait, DE's
  rm_clicker is the money room (144x296) — (3) his flagged reworks,
  (4) expansion from the parts bin.

## Working rules

- Claude cannot compile GML. He tests in the GM IDE and reports (often
  with screenshots); one change-set per test pass, verbose comments.
  After disk changes he must close/reopen the project in GM — a stale
  IDE save deletes new resources.
- Myriad DE is the DESIGN AUTHORITY for the remake: before rebuilding
  any system, read DE's implementation first and port its LAWS (curve
  shapes, timings, feel details), rebuilding the code clean. The
  techdemo already rebuilt several DE systems (rebirth r11-14, goals,
  tap multiplier, autobuy evo law) — check its dormant layer before
  rebuilding from DE raw.
- FEEL IS THE DELIVERABLE on anything player-facing (his standing
  bar). No text rounding on high-res-window UI; framework reuse is
  law (obj_set_slider for sliders, draw_ui_button for buttons, house
  popup rules).

## House conventions (inherited from Techdemo II — still binding)

- One function per Script asset: `scripts/<name>/<name>.gml` + `.yy`.
- `#macro g global`; `pair` = event_inherited(); `kill` =
  instance_destroy() (PARENFUL — bare `kill;`, never `kill();`);
  `rgb()` macro; custom colors (c_gold, c_sblue, c_horange, c_hred...).
  `fnt` = g.font, a sprite font — integer scale only. Outline
  variants: g.font_outline / g.font_large_outline (sep -1).
- Draw via `spr_pixel_1x1` stretches + `draw_px_rect`/`draw_px_line`;
  soft glows spr_vis_glow_soft. UI kit: draw_ui_button /
  draw_status_pill / draw_row_collapsed — draw-only, hit regions stay
  with owners (region pattern), geometry must match the owner's rect.
- Rooms with views disabled: room coords == screen coords. Portrait
  rooms park g.screen_size at 144 (scr_display1 handles it).
- **Timing:** the game runs at MONITOR refresh. `delta` = smoothed
  frame multiplier (1.0 == 60fps); multiply per-frame motion by it,
  or run fixed 60hz ticks off an accumulator — one per system, never
  both.
- `goto_room()` is a wrapper (wipe via persistent syst_roomtrans);
  raw `room_goto()` only behind a black fade. Never goto_room +
  `exit` early in a Create.
- .yy/.yyp are hand-authored JSON: trailing commas, resources
  alphabetical (sort quirk: suffixed-longer names sort BEFORE their
  prefix), rooms also in RoomOrderNodes. Event .yy: eventType
  0=Create, 3=Step, 8=Draw (eventNum 64 = Draw GUI), 12=CleanUp.
  Regenerated sprite PNGs need NEW frame GUIDs.
- NO BOM on any file GM parses (PS 5.1 Set-Content utf8 writes one —
  use bash writes or explicit no-BOM). No scientific literals in GML
  (1e9 = parse error; power(10,n) or digits). No chained
  un-parenthesized ternaries. `[$ "k"]` is STRUCT-only.
- GML closures don't capture locals: bake per-option values with
  method({v:...}, fn). random_get_seed returns the SET seed, not
  evolved state.

## Input arbitration (inherited)

syst_input (Begin Step) computes `g.click_owner` topmost-wins over a
families array; `mouse_over()` is arbitrated. Region UI:
`if (input_free()) if (g.click_owner == noone) ...`. Blocks via
g.input_block (menu 500, modal 1000).

## Save system (inherited)

syst_handle_save (persistent), `handle(key, default)` bidirectional
via `action` + `section`. Trigger: `syst_handle_save.action =
sv_save;` — rotating autosave via `save_mark_dirty()`.
**Save-on-mutation law:** every player-driven state change calls
save_mark_dirty() at the mutation site, no exceptions; wiring it is
part of building the path. arb bignum: packed reals (floor = exp,
frac x 10 = coefficient); do_add/do_subtract/do_multi/do_ceil/
do_floor; direct >= compare valid. THE LIBRARY DOES NOT DO SUB-1
VALUES (arb(0.15) is malformed; negatives spin normalize loops
forever — a boot freeze). arb x real-factor = do_scale (log-space);
series math stays in log10, packs once via log_to_arb. Avoid
do_power's tier-1 path in hot loops.

## Deterministic rolls (inherited, corrected 2026-09-10)

Always `random_get_seed()` / `random_set_seed(seed ^ salt)` / then
**`rng_release(saved)`** — NEVER `random_set_seed(saved)` to "restore":
random_get_seed returns the SET seed, so that rewinds the ambient
stream to the boot seed's first number every call (per-frame callers
made every mote fly the same curve). Hot seeded lookups (tier colours)
cache their result. Changing a generator's roll count shifts
everything downstream in that stream.
