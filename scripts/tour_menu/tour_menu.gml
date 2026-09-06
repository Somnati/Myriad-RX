/// tour_menu - THE BURGER AND THE DRAWER  (engine/menu)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE FILES ===============================
//   menu2_content    EDIT HERE. The whole menu is this list:
//                        menu2_section("game");
//                        menu2_button("clicker", rm_clicker, c_horange);
//                    Adding a destination is one line. COLOUR LAW: a
//                    mechanic that exists in DE wears DE's menu colour
//                    (DE's obj_button_suboptions block: tiles aqua,
//                    ability deck gold, statistics sgreen, quit red,
//                    gear orange, upgrades lavender).
//   menu2_section    starts a labelled group (pushes into `secs`).
//   menu2_button     one entry (pushes {name, rm, col, sec} into
//                    `btns`). Both run in syst_menu2's scope.
//   obj_ui_menu2     the TRIGGER: a drawn burger in the header's
//                    corner (no sprite) that morphs into an X. Owns
//                    the `open` flag everything keys off (syst_input's
//                    blocker line reads it, syst_menu2 mirrors it).
//                    Spawned by obj_ui_header. Hidden until
//                    g.game_started.
//   syst_menu2       the DRAWER: spawned when the trigger opens,
//                    replays menu2_content once, slides in from the
//                    right with a pinned profile header and a "time
//                    played" foot, drag-scrolls when the list
//                    overflows, taps land on RELEASE under a drag
//                    budget (mobile), escape closes. Builds a
//                    "menu_blur" fx layer at runtime in any room that
//                    lacks one, so every room blurs behind the menu.
//                    Folds and destroys itself when the trigger
//                    clears.
//   obj_menu2_bck    the dark backing BEHIND the blur layer, so the
//                    gaussian smooths it too. Plus THE EDGE GRADIENTS
//                    (ported 2026-09-06 from the techdemo's old
//                    obj_menu_bck, which menu v2 never inherited):
//                    spr_menu_back_3, a 144x1 strip opaque at column 0
//                    and fading out by 143, drawn twice - its one pixel
//                    row stretched to the room's height, mirrored
//                    inward from each side edge by a NEGATIVE x scale
//                    on the right-hand copy. Each fade spans half the
//                    room at any width.
//   spr_menu_back_3  that strip. It is a general edge-fade asset, not
//                    a menu one - the techdemo also ran it through a
//                    draw_edge_shade() helper to shade all four edges
//                    of the visualiser. That helper is NOT ported.
//   spr_ui_menubutton   art from the old menu, unused by the drawn
//                    burger; kept with the part.

// ============================= WHY ==================================
// The menu appears in every room and must know every destination.
// DE: obj_button_mainoptions + ten placed obj_button_suboptions, each
// deriving name / colour / target / active-state from an if-chain in
// its Step. Adding a room meant touching the count, the name array
// and the chain. RX: one line, and the drawer draws from the array.

// ============================ TRAPS =================================
//   - The drawer sits at depth -520, above the blur layer (-500), so
//     the panel stays sharp while the room blurs.
//   - Menu chrome declares ui_layer = ui_layer_menu so it keeps
//     working while its own blocker is up.
