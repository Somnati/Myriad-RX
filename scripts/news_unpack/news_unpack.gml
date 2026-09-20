/// @description news_unpack(s) - the world's news back from the save (q285); a pre-q285 save had none worth keeping
function news_unpack(_s) {
	exped_init();
	g.exped.news = [];
	if (!is_string(_s) || _s == "") return;
	var _recs = string_split(_s, "|");
	for (var _i = 0; _i < array_length(_recs); _i++) {
		var _eq = string_pos("=", _recs[_i]);
		if (_eq < 2) continue;
		var _kv = string_split(string_copy(_recs[_i], 1, _eq - 1), ":");
		if (array_length(_kv) < 3) continue;
		array_push(g.exped.news, { txt : string_delete(_recs[_i], 1, _eq), seed : real(_kv[0]), ri : real(_kv[1]), left : max(1, real(_kv[2])) });
	}
}
