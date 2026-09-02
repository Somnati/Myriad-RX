/// tour_rooms - HOW ROOMS SWITCH  (engine/rooms)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE FILES ===============================
//   goto_room(rm)   THE way to change room. Arms syst_roomtrans (the
//                   wipe), pushes the room being left onto g.room_hist
//                   (the back stack), and FLUSHES a dirty save to disk
//                   silently - "buy, hop rooms, crash" can't lose the
//                   buy. Latches g.trans_kind per flight.
//   back_room()     the universal BACK: pops the stack and goes there
//                   WITHOUT pushing (so backing up unwinds instead of
//                   ping-ponging). Empty stack -> rm_clicker, or the
//                   title if no run has started.
//   in_room(rm)     is the current room this one (reads the room id
//                   syst_roomtrans tracks, so it is right mid-wipe).
//   syst_roomtrans  persistent. Two wipes: 0 = circle (grows from the
//                   click point), 1 = slice (six slats, DE-snappy).
//                   Covers, holds THREE black frames (heavy rooms used
//                   to freeze half-faded), switches, reveals.
//   syst_titlescreen  the title room's brain: new game / continue /
//                   load / settings / quit, the spring-bounce hover,
//                   the dithered backdrop (sh_fog_dither, spr_star_glow).
//                   g.game_started stays false until continue / new
//                   game flips it - the burger menu gates on that.
//   obj_background  a black plate at depth 10000 - the floor of any
//                   room that places it.
//   ui_fadein       the boot cover: starts opaque, fades out.
//   rm_titlescreen, rm_quit   the two non-game rooms.

// ========================== WHY A WRAPPER ===========================
// room_goto() is instant. Wrapping it buys three things in one place:
// the wipe, the back stack, and the save flush. Nothing else in the
// project should call room_goto() - the one exception is when you are
// ALREADY behind a black screen (a second wipe on top of a wipe
// flashes).

// ========================= HOW DE DID IT ============================
// goto_next_room / fade_in_persistant / fade_out_close objects, and
// each back button knew its own destination. RX's stack means a back
// button returns to wherever you actually came from.

// ============================ TRAPS =================================
//   - Lower depth draws ON TOP. A room's Background layer sits at 100;
//     anything deeper than that is invisible (the "statistics is
//     empty" bug, twice).
//   - Rooms are portrait 144x296 (DE's shape) or landscape 480x270,
//     views disabled: room coords == screen coords.
//   - Landscape rooms place obj_set_landscape (engine/display) so the
//     window swap re-arms with the player's size.
