/// @description exped_news(txt, [dest], [ri]) - a line of WORLD NEWS: kept on g.exped.news (the last EXPED_NEWS_MAX), and into the diary of any crew standing in that region (q260)
function exped_news(_txt, _d = undefined, _ri = -1, _hours = 96, _own = undefined) {   // (hours: the line's window on the expedition clock; own: the trip whose deed it is - not "word" to them; q285)
	exped_init();
	if (!is_array(g.exped[$ "news"])) g.exped.news = [];
	array_push(g.exped.news, { txt : _txt, seed : is_struct(_d) ? _d.seed : 0, ri : _ri, left : _hours * EXPED_HOUR });
	while (array_length(g.exped.news) > EXPED_NEWS_MAX) array_delete(g.exped.news, 0, 1);
	if (is_struct(_d)) for (var _i = 0; _i < array_length(g.exped.trips); _i++) {
		var _tr = g.exped.trips[_i];
		if (_tr == _own) continue;
		if (is_struct(_tr[$ "dest"]) && _tr.dest.seed == _d.seed && (_ri < 0 || (_tr[$ "rgi"] ?? 0) == _ri) && is_array(_tr[$ "log"])) array_push(_tr.log, "* word is " + _txt);
	}
}
