/// tour_debug - THE DEBUG TOOLS  (engine/debug)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE FILES ===============================
//   obj_debug_pro    the F1 overlay (system's Step_1 toggles `debug`
//                    and spawns it): a header bar with fps / room,
//                    pages for the log, watched globals (editable in
//                    place - Enter commits, Escape cancels), and
//                    objects (expand one, step through its
//                    instances). Self-contained: every helper is a
//                    method on the object.
//   debug_pro_watch("g.name", "label")   register a global to show
//                    on the watch page. system's Create watches
//                    playtime as the example.
//   obj_deb_menu     an older room-shortcut button (lights up when
//                    its rm_id is the current room). NOTHING SPAWNS
//                    IT in RX - it survives only because syst_input's
//                    family list and input_free name it. A delete
//                    candidate.
//   obj_dialogue + scr_ds_say   a DIALOGUE BOX system: ds_say /
//                    ds_choice / ds_event push onto a queue, the
//                    object plays it with a typewriter, tags
//                    ([color], [shake], [wave], [pause]), portraits
//                    and choice menus. NOTHING IN RX USES IT YET - it
//                    rode along because syst_input's blocker list
//                    and scr_escape know it. It sits in debug until a
//                    game feature wants a talking box (a tutorial
//                    would).
