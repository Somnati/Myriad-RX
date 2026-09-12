/// @description autom_piece(p, i);
/// @param p   the dial's automation struct
/// @param i   the dial index
/// ONE DIAL'S AUTOBUY PULSE: BUY MAX WITHIN THE CAP (his call,
/// 2026-09-12). The cap (p.pct) is a share of the SPENDABLE pile - the
/// reserve is never touched - and every pulse buys as many levels as
/// that share reaches, through dial_buy_ext's "max" mode handed the
/// share as its wallet. The timer is pace, the cap is size, nothing
/// hides between them.
///
/// (It carried Myriad DE's dynamic-quantity law before - a step size
/// that grew on every landed buy and collapsed on a miss. That ramp was
/// a way to approach "max" one pulse at a time; with max itself on
/// every pulse it had nothing left to do. The q / h fields survive on
/// the struct unread, for saves that still carry them.)
///
/// st is the panel's verdict pill: 1 waiting (the share does not reach
/// a level), 2 buying.
function autom_piece(_p, _i) {
	// no wallet, no shopping (this also keeps do_scale off sub-1 arbs).
	// THE WALLET IS THE SPENDABLE PILE, never the whole one - budgeting
	// against g.profit would let autobuy spend the reserve, which is
	// the exact thing the reserve exists to stop.
	var _wallet = profit_spendable();
	if (!(_wallet >= arb(1))) { _p.st = 1; return; }
	var _budget = do_scale(_wallet, _p.pct / 100);

	// ⚖️ BUY MAX WITHIN THE CAP (his call, 2026-09-12): every pulse buys
	// as many levels as the cap share reaches - the timer is PACE, the
	// cap is SIZE, and there is no third, hidden ramp between them (the
	// q/h ramp that used to live here climbed a level at a time and
	// needed its own recovery rules). buy_resolve's "max" walks the
	// exact edge of the wallet it is handed; the check below is the
	// belt to its braces (a single level past the share never buys)
	var _quote = dial_buy_ext(_i, "max", false, _budget);
	if (!_quote.ok || !(_budget >= _quote.cost)) { _p.st = 1; return; }
	dial_buy_ext(_i, "max", true, _budget);
	_p.st = 2;
}
