/// tour_statistics - THE STATISTICS SCREEN  (engine/statistics)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE IDEA ================================
// A line browser. Lines are DECLARED in stats_v2_content as calls
// inside nested folders; syst_statistics_v2 walks the whole tree
// every rebuild, keeps only the visible window, and draws/hit-tests
// through the SAME geometry function (so click boxes can't drift
// from pixels). Values are LIVE - a line reads the global when it is
// built, nothing is cached.

// ========================== THE FILES ===============================
//   stats_v2_content    EDIT HERE. stats_v2_folder("name", col) opens
//                       a folder (returns whether it is open),
//                       stats_v2_folder_end() closes it, stats_v2_line
//                       (name, value, colours, help) is a row. Bodies
//                       run even when the folder is CLOSED (favourites,
//                       search and the clipboard dump need the whole
//                       tree) - keep per-line work trivial.
//   stats_v2_line / _folder / _folder_end   the builders.
//   stats_v2_toggle / _cycle   rows that FLIP or ADVANCE a global by
//                       name (the "values: total / session" row).
//   stats_v2_widget     a row that carries a live instance (rarity
//                       bars, sliders) - the framework chaperones its
//                       position and parks it off screen when hidden.
//   stats_v2_spark      an AREA CHART row over a value's history
//                       (g.stats_hist), hover-scrub with seconds-ago.
//   stats_session_base  the boot/load snapshot that "session" deltas
//                       subtract from.
//   syst_statistics_v2  the controller. REBUILT 2026-09-06 to the
//                       SETTINGS ROOM's shape, his ask: an 80px
//                       category RAIL on the left, rows in the band
//                       beside it, one tab per TOP-LEVEL folder.
//                       `rows` is still the whole build (favourites
//                       capture needs to see everything); `view` is the
//                       active tab's slice and is what draws, scrolls
//                       and hit-tests. sections[] is found by scanning
//                       the build for depth-0 folders, so a new
//                       top-level folder in stats_v2_content becomes a
//                       tab with no other edit. Depth-0 folders are
//                       forced OPEN in stats_v2_folder - the rail is
//                       their label - so only NESTED folders fold.
//                       folders open by full path
//                       (g.stats_open, remembered), favourites pin
//                       into a synthetic folder on top (g.stats_fav,
//                       SAVED) with the [favs] button in the title
//                       strip showing or hiding the star gutter that
//                       pins them (g.stats_fav_show, saved beside
//                       them); change
//                       pulses, +/- folder chips, rows as raised
//                       panels, the unfurl animation on toggle,
//                       rebuilds throttled to 1/s except structure
//                       taps.
//   obj_draw_proxy      (engine/ui) the extra draw depth slot the
//                       title strip uses.
//   rm_statistics_v2    the room.

// ========================= HOW DE DID IT ============================
// obj_stattab + par_stats objects per tab, values drawn by
// obj_statistics_infodraw. RX: the tree is data.

// ============================ TRAPS =================================
//   - arb session deltas must guard the subtract: the library can't
//     say negative.
//   - Same draw-depth recipe as settings (see tour_settings).
