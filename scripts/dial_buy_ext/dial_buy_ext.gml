/// @description dial_buy_ext(i, mode, [commit]) - quote or commit a
/// buy in a BUY MODE (1 / 10 / 100 / 1000 / "next" / "max"). Returns
/// the quote { ok, n, to, cost }: ok = affordable AND at least one
/// level; n = levels it would add; to = the target level; cost = the
/// price. commit = true (default) also pays and levels through
/// dial_buy, the ONE place a dial gains levels; commit = false is a
/// dry run for the drawer's button labels and its "+N".
/// Myriad DE split this across obj_button_dialbuy (the press) and the
/// per-mode cost tables update_auto_cost filled every update; RX
/// quotes on demand through buy_resolve + dial_cost, both closed form.
/// A DORMANT dial (level 0) ignores the mode: its first level is its
/// purchase, always exactly one (DE's rule).
function dial_buy_ext(_i, _mode, _commit = true) {
	var _dead = { ok : false, n : 0, to : 0, cost : 0 };
	if (!variable_global_exists("dial")) return _dead;
	if (_i < 0 || _i >= g.dial_total) return _dead;

	var _d    = g.dial[_i];
	var _from = _d.level;
	var _to   = (_from <= 0) ? 1 : buy_resolve(_i, _from, _mode);
	var _cost = dial_cost(_i, _from, _to);
	var _ok   = (_to > _from) && (g.profit >= _cost);

	if (_ok && _commit) _ok = dial_buy(_i, _to - _from);

	return { ok : _ok, n : _to - _from, to : _to, cost : _cost };
}
