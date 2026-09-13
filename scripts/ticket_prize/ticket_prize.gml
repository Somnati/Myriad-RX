/// @description ticket_prize(sym, rar) -> { kind, amount, label, col }
/// - what a matched symbol pays at THIS moment, at the ticket's rarity
/// multiplier. Derived at scratch time, never stored: a ticket kept a
/// week pays today's rate. kind is the symbol's key; flux and shards
/// fall back to profit before the tile room has unfolded (the symbol
/// still prints - a grid needs five - it just pays the coin you have).
function ticket_prize(_sym, _rar) {
	var _c = ticket_config();
	var _m = _c.rars[_rar].mult;
	var _sd = _c.syms[_sym];
	var _kind = _sd.key;
	var _tiles = unfold_has("tiles") && variable_global_exists("tiles");
	if ((_kind == "flux" || _kind == "shards") && !_tiles) _kind = "profit";
	switch (_kind) {
		case "profit": {
			gift_init();
			var _secs = _c.syms[0].secs * _m;
			var _amt = 0;
			var _rate = variable_global_exists("all_gps") ? g.all_gps : 0;
			if (_rate >= arb(1)) _amt = do_scale(_rate, _secs);
			var _fl = g.gift_cfg.floor_profit * _m;
			if (!(_amt >= arb(_fl))) _amt = arb(max(1, round(_fl)));
			return { kind : "profit", amount : _amt, label : "+" + crunch_arb(_amt) + " profit", col : g.profit_color };
		}
		case "credits": {
			var _n = max(1, ceil(_sd.per * _m));
			return { kind : "credits", amount : _n, label : "+" + string(_n) + " credits", col : c_lavender };
		}
		case "flux": {
			var _n = max(_sd.min, round((g.tiles[$ "flux"] ?? 0) * _sd.pct / 100 * _m));
			return { kind : "flux", amount : _n, label : "+" + string(_n) + " flux", col : c_aqua };
		}
		case "shards": {
			var _held = (g.tiles.shards >= arb(1)) ? g.tiles.shards : 0;
			var _amt = (_held > 0) ? do_scale(_held, _sd.pct / 100 * _m) : 0;
			if (!(_amt >= arb(_sd.min))) _amt = arb(_sd.min);
			return { kind : "shards", amount : _amt, label : "+" + crunch_arb(_amt) + " shards", col : c_horange };
		}
	}
	return { kind : "ticket", amount : 1, label : "+1 ticket", col : c_gold };
}
