/// tour_gamepad - CONTROLLERS  (engine/gamepad)
/// A TOUR SCRIPT: comments only, nothing runs.
/// Status: no RX game code reads a pad yet. Kept (his call,
/// 2026-09-02) for the PC build.

// ========================== THE FILES ===============================
//   pad_config      THE action map, edit here. Actions, not buttons:
//                   consumers ask pad_down("confirm") or pad_x("move")
//                   and never touch gp_* constants. Kinds: "d" digital
//                   (any of several binds fires it), "v" analog value
//                   (triggers), "s" stick (radial deadzone vector).
//                   dpad AND left stick both feed up/down/left/right.
//   pad_init        one-time boot: builds g.pad (12 device slots,
//                   per-action state, scannable tables), loads saved
//                   binds, lazy-spawns syst_gamepad. Idempotent -
//                   syst_input's Create calls it, so pads work from
//                   boot in every room.
//   syst_gamepad    persistent runner; Begin Step calls pad_tick.
//   pad_tick        the heartbeat: rumble countdown -> device scan
//                   (every 30 steps, or now on hotplug) -> rebind
//                   capture -> per-action state. Actions MERGE across
//                   every connected pad (couch rule); g.pad.active is
//                   the last pad that spoke (glyphs + rumble target).
//   pad_down / pad_pressed / pad_value / pad_x / pad_y   the reads.
//   pad_rebind, pad_glyph      rebinding + button labels per family
//                              (xbox / ps / switch / generic).
//   pad_binds_save / _load     settings.ini "pad" section.
//   syst_gamepad_bench + rm_gamepad   the debug bench (menu > misc):
//                   devices, deadzone sliders, live sticks, tap-to-
//                   rebind rows. Pure view - all logic stays in pad_*.

// ============================= WHY ==================================
// DE has no controller support at all. If the Steam build wants it,
// this is done: the only work is calling pad_* from the game's UI.
