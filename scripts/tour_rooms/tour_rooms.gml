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
//                   Orientation-aware: naming either shape of a paired
//                   room matches both.
//   room_pairs()    THE ORIENTATION TABLE - one line per room that
//                   exists in both shapes. The only file to edit.
//   room_orient()   which shape is being played: 0 portrait, 1
//                   landscape. Reads g.orient (-1 auto / 0 / 1).
//   room_variant(rm)  that room in the live shape. goto_room runs
//                   every destination through it.
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

// ======================== ORIENTATION ===============================
// The money room exists TWICE: rm_clicker (144x296, DE's phone shape)
// and rm_clicker_landscape (480x270), same instances, same systems.
// His ask 2026-09-06: play in either, and be able to force which.
//
// THE PORTRAIT ROOM IS THE NAME YOU WRITE. Every call in the codebase
// says goto_room(rm_clicker) / in_room(rm_clicker) and the resolvers
// pick the shape - so adding a second shape to a room costs one line
// in room_pairs and NOTHING at the call sites. Never name a
// _landscape room outside room_pairs.
//
// WHERE IT IS DECIDED:
//   g.orient     the setting (settings > display "orientation"):
//                -1 auto (phone portrait, desktop landscape), 0 forced
//                portrait, 1 forced landscape. Rides settings.ini.
//   goto_room    resolves the destination. One seam - the menu, the
//                save menu, the titlescreen and back_room all inherit
//                it without knowing.
//   in_room      matches either shape, so "am I in the money room"
//                stays one question.
//
// WHAT IT DOES NOT DO: rooms with only ONE shape come straight back
// out of the resolver. Settings, statistics, saves, gamepad, services
// and the titlescreen are landscape-only, so "force portrait" leaves
// them landscape. Give one a portrait twin and it starts obeying the
// setting the moment its line lands in room_pairs.
//
// THE SYSTEMS FOLLOW THE ROOM, they are not written per shape:
// syst_dials seats its column off room_width/room_height (the
// portrait numbers are the same seats expressed as edge offsets), the
// header stretches to room_width, obj_bignum5 centres itself. Adding
// a shape should never mean a second copy of a system.

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
