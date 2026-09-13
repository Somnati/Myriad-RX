/// @description ticket_pay(ticket, roll, x, y) -> the ticket is done:
/// pays its prize (if it won) with the wallet's own ceremony from x, y,
/// counts it, marks the save. Returns the prize struct, or undefined
/// on a loser. THE ONE mutation site for a finished ticket.
function ticket_pay(_t, _roll, _x, _y) {
	ticket_init();
	var _tk = g.tickets;
	_tk.scratched += 1;
	var _pz = undefined;
	if (_roll.win) {
		_pz = ticket_prize(_roll.sym, _t.rar);
		switch (_pz.kind) {
			case "profit":
				give_profit(_pz.amount);
				bezier_bits(_x, _y, 8 + ticket_config().rars[_t.rar].mult, g.profit_color,
					undefined, undefined, -1, _pz.amount);
				break;
			case "credits": credit_drop(_x, _y, _pz.amount, 8); break;
			case "flux":    g.tiles.flux = (g.tiles[$ "flux"] ?? 0) + _pz.amount; break;
			case "shards":
				g.tiles.shards = (g.tiles.shards >= arb(1)) ? do_add(g.tiles.shards, _pz.amount) : _pz.amount;
				break;
			case "ticket":  ticket_grant("ticket"); break;
		}
		_tk.won += 1;
		if (_t.rar > _tk.best) { _tk.best = _t.rar; _tk.best_txt = _pz.label; }
	}
	save_mark_dirty();
	return _pz;
}
