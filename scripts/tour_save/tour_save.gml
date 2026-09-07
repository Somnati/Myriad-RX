/// tour_save - THE SAVE SYSTEM  (engine/save)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE IDEA ================================
// One ini file per profile, one BIDIRECTIONAL block of code. In
// handle_save every line reads
//     g.profit = handle("profit", g.profit);
// and `handle` either WRITES the second argument or READS the key
// back (default = the current value), depending on `action`
// (sv_save / sv_load). Save and load can never disagree about a key
// because they are the same line. DE had the same idea (one ini,
// grab_deck_* per system); RX folds it into one script with sections.

// ========================== THE FILES ===============================
//   syst_handle_save   persistent, the clock. Create: repair the
//                      active profile (save_recover), PROMOTE the
//                      newest autosave over the main save if it is
//                      newer (continue = the run you were actually on).
//                      Step: run handle_save + handle_settings when
//                      `action` is set; tick g.time_played_active; every 60 s,
//                      if g.save_dirty and autosave is on, rotate.
//   handle(key, default)   the bidirectional read/write. `section`
//                      (an instance variable) picks the ini section.
//   read / write       the ini calls it wraps.
//   handle_save        EDIT HERE. Sections: system (datetime), player
//                      (name/colour/playtime/profit/difficulty), dials
//                      NOTE the two clocks: ini key "playtime" is the
//                      ACTIVE one (the name predates the split, kept so
//                      old saves still load) and "playtime_off" is the
//                      time away. Their SUM is DE's single
//                      total_seconds_played figure.
//                      (level + cycle + auto per dial, then
//                      update_dials = THE resync), statistics (pins).
//                      A rebuilt DE system adds its section here.
//   handle_settings    the OTHER ini (settings.ini): display, audio,
//                      gameplay knobs, pad binds. Split so an exported
//                      save never drags device settings along.
//   save_slot_path(slot)   THE file-name authority: 0 main, 1-3
//                      autosaves, 4 rebirth backup, per profile p1-p4.
//   save_mark_dirty()  THE LAW: every player-driven change calls it at
//                      the mutation site. The autosave clock only
//                      writes when it is up; goto_room flushes it.
//   save_autosave_rotate   main -> autosave_1 -> 2 -> 3. Three
//                      separate files so a death mid-write can only
//                      corrupt one.
//   save_validate / save_recover   a usable file has save_datetime;
//                      boot walks the autosaves newest-first for a
//                      survivor.
//   save_export / save_import (+ _saf on android, + _apply)   the
//                      player-reachable export/import: a system file
//                      dialog on desktop (plain readable ini), the
//                      clipboard on mobile until the SAF picker lands.
//                      save_export takes an OPTIONAL file, so the menu
//                      can export a profile that is not the one being
//                      played - and it skips its freshness flush in
//                      that case, or the flush would write the live run
//                      over the very save being backed up.
//   save_slot_info     peek a file WITHOUT loading it - name, colour,
//                      profit, playtime (+ playtime_off; a pre-split
//                      save reads 0 there, so its total simply equals
//                      its active time), and since 2026-09-07 the four
//                      that were on disk unread: DATETIME (the stamp
//                      the menu now shows on every row), difficulty,
//                      credits, rebirth total.
//   set_profile(i)     switch profile: repoint, recover, load; a
//                      fresh profile runs game_reset first.
//   game_reset         THE fresh-run reset, in memory, no
//                      game_restart. New systems add their reset here.
//   clipboard_get / _set   the extension wrappers.
//   obj_save_menu + rm_saves   the menu, REBUILT 2026-09-07 in the
//                      settings room's shape: a LEFT RAIL of the four
//                      profiles (colour-coded from their own files),
//                      the selected profile's five slots as the
//                      content band, and an action band under them
//                      (export / import / delete profile) bound to the
//                      profile on screen. Rows are the FILES, the band
//                      is the PROFILE. Every row carries a stamp
//                      (crunch_time_ago) - without one the three
//                      rotating autosaves are indistinguishable.
//                      Tapping a row opens a dialogue tree; the
//                      REBIRTH row is a real restore point (it used to
//                      say "reserved" while rebirth_do quietly wrote
//                      it every time).
//                      Also the NEW GAME flow: pick profile ->
//                      overwrite confirm -> difficulty -> game_reset
//                      -> save. Nothing is deleted until the
//                      difficulty tap, so backing out is always safe.
//                      RETIRED, kept dormant: obj_button_save / _load
//                      / _delete / _export / _import / _export_saf /
//                      _import_saf / _back. The first seven were
//                      hard-placed in the room's bottom-right corner
//                      and acted on syst_handle_save.file_to_handle -
//                      the ACTIVE file, never the profile on screen -
//                      and _delete wiped a save with no confirm at
//                      all. They were also why rm_saves could not take
//                      a portrait twin.

// ============================ TRAPS =================================
//   - Packed arbs ride the ini as plain reals. Floor them on load.
//   - A new key needs no migration: handle() returns the default when
//     the key is missing. Old keys that stop being read are ignored.
//   - Wire save_mark_dirty() WHILE building a mutation path, never as
//     a follow-up.
