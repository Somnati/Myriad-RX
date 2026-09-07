/// @description stats_v2_bar(name, segments, [span]);
/// @param name
/// @param segments  array of { name, share, col } - share is SIGNED
/// @param [span]
/// THE CONTRIBUTION BAR - a stacked strip showing how a total is
/// shared out, one segment per contributor, width proportional to
/// share. Built for the dial pages (see dial_breakdown, which produces
/// exactly these segments from log10 shares) but it knows nothing
/// about dials: hand it anything that adds up.
///
/// Shares are SIGNED. Contributors that take away - a level ramp under
/// 1, a wind-up tax - draw on the same strip with a darkened face and
/// a hatch, so a penalty reads as weight rather than as absence. That
/// is the whole reason this beats a list of numbers: on a list a x0.8
/// ramp and a x2 milestone are two lines of similar size, and on the
/// bar you can see which one is deciding the dial.
///
/// Row kind 7. Like the spark it takes a span of rows for height, and
/// like every builder it runs in syst_statistics_v2' scope.
function stats_v2_bar(_name, _segs, _span = 2) {
	if (search != "" || _fhid > 0) return;
	_span = max(2, _span);
	array_push(rows, {
		kind : 7,
		name : _name,
		val  : "",
		c1   : c_white,
		c2   : rgb(195, 205, 235),
		fdep : _fdepth,
		path : "",
		key  : _fpath + "/" + _name,
		help : "",
		fav  : false,
		data : _segs,   // the segments, read at draw time
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
