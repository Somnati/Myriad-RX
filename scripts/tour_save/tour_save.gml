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
//                      `action` is set; tick g.playtime; every 60 s,
//                      if g.save_dirty and autosave is on, rotate.
//   handle(key, default)   the bidirectional read/write. `section`
//                      (an instance variable) picks the ini section.
//   read / write       the ini calls it wraps.
//   handle_save        EDIT HERE. Sections: system (datetime), player
//                      (name/colour/playtime/profit/difficulty), dials
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
//   save_slot_info     peek a file's name/colour/profit/playtime
//                      without loading it (the menu cards).
//   set_profile(i)     switch profile: repoint, recover, load; a
//                      fresh profile runs game_reset first.
//   game_reset         THE fresh-run reset, in memory, no
//                      game_restart. New systems add their reset here.
//   clipboard_get / _set   the extension wrappers.
//   obj_save_menu + obj_button_* + rm_saves   the KH-style menu:
//                      page 0 = four profiles, page 1 = that
//                      profile's slots (autosaves, main, rebirth).
//                      obj_button_save / _load / _delete / _export /
//                      _import act on the picked slot; obj_button_back
//                      returns to the profile page.
//                      Also the NEW GAME flow: pick slot -> overwrite
//                      confirm -> difficulty -> game_reset -> save.

// ============================ TRAPS =================================
//   - Packed arbs ride the ini as plain reals. Floor them on load.
//   - A new key needs no migration: handle() returns the default when
//     the key is missing. Old keys that stop being read are ignored.
//   - Wire save_mark_dirty() WHILE building a mutation path, never as
//     a follow-up.
