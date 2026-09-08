/// @description autom_init([force]);
/// @param [force]
/// THE AUTOMATION ROOM's state. Two kinds of thing live here and the
/// split matters:
///   SAVED PREFERENCES - every toggle, percentage and threshold. They
///     are choices about how you want to play, so they ride across
///     rebirths untouched (rebirth_do does not reset them) and only a
///     new game clears them.
///   SESSION PACING - the q/h ramps below. They re-derive from nothing
///     every boot, which is Myriad's own behaviour and correct: a ramp
///     is a guess about the current wallet, and the wallet is not the
///     same after a reload.
///
///   dial[i] { on, pct, q, h, st }
///     on   the toggle
///     pct  spend threshold as a % of CURRENT profit. His semantics
///          from the techdemo, and the right ones: the dial buys only
///          while the bill is at most pct% of the wallet AT THAT
///          MOMENT. No reserved slices, no ledgers to keep in step -
///          the rule is re-read every pulse from the live balance.
///     q/h  the adaptive step ramp (autom_piece)
///     st   the last verdict, for the room's pills: 0 off, 1 waiting,
///          2 bought
///
///   reb  the autorebirth conditions - EVERY ENABLED ONE MUST PASS.
///        AND rather than OR, because these are safety rails: a player
///        turning on "at least 30 minutes" and "at least 5 units" means
///        both, and an OR would fire on the weaker one and feel broken.
///
///   upg  { roll, buy, sell, pct, keep } - the upgrade table's
///        automation. keep is a PERCENTAGE, not a rarity: see
///        upgrade_keep_rarity for why that distinction is the whole
///        point of it. It defaults to 50 rather than 100 because a
///        filter that keeps everything is a switch that does nothing
///        when you turn it on.
///
///   lock_pct  the reserve: what share of every earning is locked out
///        of spending (give_profit does the split, profit_spendable
///        reads it). 0 = off.
function autom_init(_force = false) {
	if (variable_global_exists("autom") && !_force) return;
	var _dn = variable_global_exists("dial_total") ? g.dial_total : 13;
	g.autom = {
		dial : [],
		reb  : {
			t_on : false, t_min  : 30,   // minutes into the run
			u_on : false, u_min  : 5,    // units the press would award
			g_on : false, g_pct  : 10,   // that award as % of units held
			c_on : false,                // only while the timeclamp is done
			p_on : false, p_oom  : 12,   // profit's exponent
		},
		upg  : { roll : false, buy : false, sell : false,
		         pct : 50, keep : 50, st : 0 },
		// THE RESERVE, as a percentage of every earning. 0 = off.
		// It rides here rather than in its own global because it is a
		// preference about automation: the reserve exists because
		// autobuy would otherwise eat the pile rebirth is calculated
		// from. See give_profit and profit_spendable.
		lock_pct : 0,
		tic  : 0,
	};
	repeat (_dn) array_push(g.autom.dial,
		{ on : false, pct : 50, q : 1, h : 0, st : 0 });
}
