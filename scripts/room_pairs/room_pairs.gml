/// @description room_pairs() - THE ORIENTATION TABLE. One entry per
/// room that exists in BOTH shapes; { p : the portrait room, l : the
/// landscape one }. This is the whole file to edit: adding a shape for
/// a room is one line here and nothing else, because goto_room and
/// in_room both resolve through it.
///
/// A room that is NOT in this table has one shape only, and both
/// resolvers hand it straight back - so the landscape-only screens
/// (settings, statistics, saves, gamepad, services, titlescreen, all
/// 480x270) keep working untouched, and "force portrait" simply has
/// nothing to swap them for. Give one a portrait twin some day and it
/// starts obeying the setting the moment its line lands here.
///
/// THE PORTRAIT ROOM IS THE CANONICAL ONE (room_variant's `p` field):
/// every reference in code names it - goto_room(rm_clicker),
/// in_room(rm_clicker), back_room's fallback - and the resolver picks
/// the shape. Nothing outside this file should ever name a _landscape
/// room directly.
function room_pairs() {
	return [
		{ p : rm_clicker, l : rm_clicker_landscape },
	];
}
