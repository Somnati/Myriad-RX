/// @description gift_claim(x, y) -> collect today's gift. Returns the
/// paid reward struct (gift_reward's shape + .pos = the slot that got
/// punched) for the panel to float/flash, or undefined when today's is
/// already collected. THE one mutation site: pays the wallet (profit
/// through give_profit, credits through credit_drop's explicit-grant
/// lane - both with their own ceremony from x, y), stamps the day,
/// advances the board (slot 14 rolls a fresh cycle), and marks the
/// save dirty (save-on-mutation law).
/// The reward derives BEFORE the claim counts - a collect that tips
/// the gift level pays at the OLD output, the new output starts
/// tomorrow (no self-inflating claims).
function gift_claim(_x, _y) {
	gift_init();
	if (!gift_can_claim()) return undefined;

	var _board = gift_board();
	var _rw = gift_reward(_board[g.gift.pos]);
	_rw.pos = g.gift.pos;

	if (_rw.kind == 0) {
		give_profit(_rw.amount);
		// the motes carry it home, so the header climbs as they land
		bezier_bits(_x, _y, 8 + _rw.rar.mult, g.profit_color,
			undefined, undefined, -1, _rw.amount);
	} else {
		credit_drop(_x, _y, _rw.amount, 8 + _rw.rar.mult);
	}

	// a scratch ticket rides every daily gift (2026-09-13)
	ticket_grant("gift");
	g.gift.last_day = gift_day();
	g.gift.claims++;
	g.gift.pos++;
	if (g.gift.pos >= g.gift_cfg.days) {
		g.gift.pos = 0;
		g.gift.cycle++; // fresh board, fresh rarities
	}
	save_mark_dirty();
	return _rw;
}
