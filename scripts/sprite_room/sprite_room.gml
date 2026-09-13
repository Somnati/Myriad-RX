/// @description sprite_room(job) -> where a sprite with this job LIVES
/// (his ask, 2026-09-13: "i would like for them to actually be in the
/// tile room if that's where they are assigned"): "tiles" for the
/// fabricator and the merger - the body stands in the tile panel and
/// shows only while it is up - "money" for everything else (the room's
/// tapper, the dials, the autotapper).
function sprite_room(_job) {
	if (_job == "fab" || _job == "merge") return "tiles";
	return "money";
}
