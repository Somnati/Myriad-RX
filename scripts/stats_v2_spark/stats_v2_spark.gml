/// @description stats_v2_spark(name, "hist_key", [color], [span]) -
/// a tiny history graph row. reads its samples LIVE at draw time from
/// g.stats_hist[$ hist_key] (fed by stats_hist_push, from wherever
/// the stat lives - the tile engine samples gps, for instance), so
/// the row itself carries only the key. arb-packed numbers graph
/// beautifully raw: the packing is log-scale by construction, which
/// is exactly the right scale for idle curves.
function stats_v2_spark(_name, _hkey, _col = -1, _span = 3) {
	if (_col == -1) _col = c_seagreen;
	if (search != "" || _fhid > 0) return;
	_span = max(2, _span);
	array_push(rows, {
		kind : 6, // sparkline
		name : _name,
		val  : _hkey, // the history buffer's key
		c1   : _col,
		c2   : rgb(195, 205, 235),
		fdep : _fdepth,
		path : "",
		key  : _fpath + "/" + _name,
		help : "",
		fav  : false,
		data : -1,
		open : false,
		inst : noone,
		span : _span,
	});
	repeat (_span - 1) array_push(rows, {
		kind : 3, name : "", val : "", c1 : c_white, c2 : c_white,
		fdep : _fdepth, path : "", key : "", help : "", fav : false,
		data : -1, open : false, inst : noone, span : 1,
	});
	span_max = max(span_max, _span);
}
