/// tour_namegen - THE PROFILE NAME GENERATOR  (engine/namegen)
/// A TOUR SCRIPT: comments only, nothing runs.
/// Status: techdemo residue, KEPT (his call, 2026-09-02).

// ========================== WHAT IT DOES ============================
// setgame rolls a name for each of the four profiles at boot with
// gen_name_planet(); a profile's first save locks its name in, and
// obj_save_menu shows it on the profile cards. That is the only
// customer.

// ========================== THE FILES ===============================
//   gen_name_planet     picks a shape (start + end, or start + middle
//                       + end, with a 5% roman-numeral suffix) and
//                       assembles it.
//   letter_get_s_planet / letter_get_m_planet / letter_get_e_planet
//                       the START / MIDDLE / END syllable tables -
//                       long weighted choose() lists, which is why
//                       these three files are the biggest in the
//                       engine. They are data, not logic.
//   letter_get_roman    1..7 as roman numerals.

// ============================= NOTE =================================
// DE has its own letter_* name scripts (ten of them). If profile
// names should read like DE's, swapping this generator for DE's is a
// one-file change in setgame.
