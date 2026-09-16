/// @description exped_log_gist(line) -> true when the line belongs in THE GIST (the diary's highlights, his pick 2026-09-16)
/// The prefixes decide first: "# " a place header and "+ " a reward are
/// in; "~ " the crew's voice and "* " the sky are out. The rest by what
/// they say - fights, finds, the quest, notes, the shop, the inn, the
/// dice, the titles, the stance's turns. A reading aid, not a law.
function exped_log_gist(_l) {
	static _keys = ["the quest", "writes:", "bounty", "blocks the way", "on the road:", "wave ", "the way is clear", "bar fight", " sold ", " bought ", " drank ", " is down", "totem",
	                "night at the inn", "home", "acquired", "found at", "is done", "bane of", "scourge", "warden", " a look", "one more room", "cautious", "greedy", "the season", "remember",
	                "word gets round", "sat down to", "the camp", "into ", "out of ", "limp", "the tenth", "elixir", "the chest", "cleared", "delivered", "handed ", "collected ", "met "];
	var _pre = string_copy(_l, 1, 2);
	if (_pre == "# " || _pre == "+ ") return true;
	if (_pre == "~ " || _pre == "* ") return false;
	for (var _i = 0; _i < array_length(_keys); _i++) if (string_pos(_keys[_i], _l) > 0) return true;
	return false;
}
