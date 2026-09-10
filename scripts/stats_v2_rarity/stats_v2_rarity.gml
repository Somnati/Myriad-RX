/// @description stats_v2_rarity(name, entries, [head], [span]);
/// @param name
/// @param entries  array of { name, p, col, [seen] } - p is 0..1
/// @param [head]   the OVERALL rate, as a ready string. Drawn above the
///                 rung list, DE's way - see below.
/// @param [span]
/// THE RARITY SPREAD - Techdemo II's rarity bar, rebuilt in this
/// screen's row language. A stacked strip of the odds, the same strip
/// again underneath in what has actually been ROLLED, and an aligned
/// list: chance, "1 in N", and the count seen so far.
///
/// WHY NOT stats_v2_bar. The contribution bar rounds every share to a
/// whole percent, which is right when the shares sit near each other
/// and useless here - a ladder's whole interest is its tail, the tail
/// is fractions of a percent, and "0%  0%  0%" is the one thing a
/// rarity table must never say. So percentages carry decimals scaled by
/// magnitude (Techdemo II's own rule) and "1 in N" sits beside them,
/// because a long tail is something a player thinks about in odds, not
/// in percentages.
///
/// THE TWO STRIPS ARE THE REASON THIS EARNS A SCREEN: expected above,
/// observed below, so you can watch a sample converge on its own curve
/// - or fail to.
///
/// Row kind 8. It knows nothing about upgrades: hand it anything that
/// carries probabilities.
/// ⚖️ THE OVERALL RATE BELONGS AT THE TOP (his ask, 2026-09-09: like
/// DE's and the tech demo's). par_raritybar draws
///     "rarity rate  +" + crunch_arb_ext(arb(rarity_rate), 12) + "%"
/// directly under its strip and above the per-rung list, and it is the
/// first thing worth knowing: every rung below is a CONSEQUENCE of that
/// one number, and a table that shifts without showing its cause is a
/// table you cannot reason about. The CALLER formats it, because only
/// the caller knows what its own rate is measured in.
function stats_v2_rarity(_name, _ent, _head = "", _span = -1) {
	if (search != "" || _fhid > 0) return;
	// the height it actually needs: top pad + strip + gap + the rate
	// line + the column header + one 8px line an entry, in whole rows
	if (_span == -1)
		_span = ceil((26 + ((_head != "") ? 8 : 0)
			+ array_length(_ent) * 8) / row_h);
	_span = max(2, _span);
	array_push(rows, {
		kind : 8,
		name : _name,
		val  : _head,   // the overall rate line - see the header
		c1   : c_white,
		c2   : rgb(195, 205, 235),
		fdep : _fdepth,
		path : "",
		key  : _fpath + "/" + _name,
		help : "",
		fav  : false,
		data : _ent,   // the entries, read LIVE at draw time
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
