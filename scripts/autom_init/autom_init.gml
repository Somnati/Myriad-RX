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
///   dial[i] { on, pct, t, q, h, st, tic }
///     on   the toggle
///     t    seconds between attempts (RAM_TIMER_MIN..MAX): its clock,
///          and what it costs - ram_cost("timer", t). tic is the
///          countdown, session-only
///     pct  spend threshold as a % of CURRENT profit. His semantics
///          from the techdemo, and the right ones: the dial buys only
///          while the bill is at most pct% of the wallet AT THAT
///          MOMENT. No reserved slices, no ledgers to keep in step -
///          the rule is re-read every pulse from the live balance.
///     q/h  the adaptive step ramp (autom_piece)
///     st   the last verdict, for the room's pills: 0 off, 1 waiting,
///          2 bought
///
///   reb  the autorebirth: ONE MASTER SWITCH (on - what costs the RAM
///        and what the panel's meter shows) over the trigger rails,
///        and EVERY ENABLED RAIL MUST PASS. AND rather than OR, because
///        these are safety rails: a player turning on "at least 30
///        minutes" and "at least 5 units" means both, and an OR would
///        fire on the weaker one and feel broken. The switch alone
///        never fires: it needs at least one rail armed.
///
///   upg  { roll, buy, sell, pct, keep, rar[], kind } - the upgrade
///        table's automation. rar[] and kind are the FILTER: one
///        keep/sell flag per rarity rung and one per roster id. keep is
///        a percentage that SETS rar[] from the live odds when dragged
///        (see upgrade_keep_rarity) rather than a standing rule.
///
///   RAM (his design, 2026-09-11 - read ram_cost / ram_used /
///   ram_throttle). Everything below that is ON costs sticks; over
///   the budget every clock slows, nothing stops.
///     tap       THE AUTOTAPPER (his ask, 2026-09-11) { on, rate, acc }:
///               rate taps a second (2..10 by 2, x the tps bonuses),
///               paid through tap_fire on the heartbeat, NOT counted
///               as your taps; costs ram_cost("tap", rate) - a stick
///               per 2/s. Online only (RAM's world); the sprites are
///               the ones that tap for you while you are away
///     run       the dials' OWN CYCLING as an automation { on, spd }:
///               on by default at 100%; slower is cheaper; off makes
///               every dial manual (tap to run, DE's rule). prod_dials
///               reads autom_rate("run")
///     fab       the fabricator, the same shape (tiles_tick reads
///               autom_rate("fab"))
///     am_speed  the automerger's speed, 5..100% (its switch is the
///               table's own g.tiles.automerge)
///     presets   three pack strings (autom_pack) - the whole setup,
///               saved and reloaded from the overview
///
///   tiles  the tile table's upgrade autobuy (his ask, 2026-09-11):
///        one { on, pct, t, st, tic } per tile_upg_config id, keyed BY ID like
///        the upgrade filter, pct the cap as a share of the SHARDS
///        held. Pre-seated for every roster id so the panel and the
///        save never meet a missing row. (The automerger's own switch
///        is g.tiles.automerge - the table's, saved with the table -
///        and the panel flips that directly.)
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
			on   : false,                // the master switch
			t_on : false, t_min  : 30,   // minutes into the run
			u_on : false, u_min  : 5,    // units the press would award
			g_on : false, g_pct  : 10,   // that award as % of units held
			c_on : false,                // only while the timeclamp is done
			p_on : false, p_oom  : 12,   // profit's exponent
		},
		// THE UPGRADE FILTER IS TWO EXPLICIT LISTS now (his ask):
		//   rar[]  one keep/sell flag per rarity rung
		//   kind   one keep/sell flag per roster id, keyed BY ID because
		//          the roster's order is not a contract and its ids are
		//          (the same discipline the save follows)
		// Everything defaults to KEEP, so switching the autosell on does
		// nothing until you have told it what you do not want - the safe
		// direction for a control that destroys things.
		//
		// `keep` survives as a QUICK-SET rather than a rule: dragging it
		// writes rar[] from the live odds through upgrade_keep_rarity,
		// so the self-adjusting logic is still there as a one-drag way
		// to configure the flags. The flags themselves are the truth.
		upg  : { roll : false, buy : false, sell : false,
		         pct : 50, keep : 50, st : 0, t : 30, tic : 0,
		         rar : array_create(UPG_RARITY_N, true),
		         kind : {} },
		// THE RESERVE, as a percentage of every earning. 0 = off.
		// It rides here rather than in its own global because it is a
		// preference about automation: the reserve exists because
		// autobuy would otherwise eat the pile rebirth is calculated
		// from. See give_profit and profit_spendable.
		lock_pct : 0,
		// THE STRATEGY (his list, 2026-09-12: "priority instead of
		// thirteen identical rows"): 0 manual (a row per dial), 1
		// strongest first, 2 cheapest first, 3 round-robin - the three
		// strategies share ONE row (dial_all) and walk the dials in their
		// order with the cap share, the leftovers trickling down
		strat    : 0,
		dial_all : { on : false, pct : 50, t : 30, tic : 0, st : 0, cur : 0 },
		// THE RAILS (his list: the rebirth's armed conditions, for the
		// autobuys too): a floor under which an autobuy holds its fire
		rails    : { d_on : false, d_oom : 6, t_on : false, t_oom : 3 },
		tiles : {},
		tap      : { on : false, rate : 2, acc : 0 },
		run      : { on : true, spd : 100 },
		fab      : { on : true, spd : 100 },
		am_speed : 100,
		// THE OVERCLOCK TOGGLE (his design, 2026-09-12 - read ram_oc):
		// on, every speed / tap / timer track grows its red notches; off,
		// ram_oc_clamp drops anything sitting on them
		oc       : false,
		presets  : ["", "", ""],
		// THE WATERMARK the reserve is measured against: the highest
		// pile ever held on this run. It exists because a reserve
		// measured against the CURRENT pile is not a floor - spending
		// lowers the pile, which lowers the reserve, which frees a
		// little more, and autobuy's one-second pulse walks straight
		// through it. datafiles/reserve_twin.py: 60 pulses leave 0.2%
		// of what was promised. Raised only by give_profit, and only
		// upward, so spending cannot erode it.
		lock_peak : 0,
		tic  : 0,
		// THE LEDGER (his list, 2026-09-12): what automation did, newest
		// first, and the session's tallies - see autom_log. Neither saves
		ledger : [],
		stat   : autom_stat_new(),
	};
	repeat (_dn) array_push(g.autom.dial,
		{ on : false, pct : 50, t : 30, q : 1, h : 0, st : 0, tic : 0 });
	var _tc = tile_upg_config();
	for (var _i = 0; _i < array_length(_tc); _i++)
		g.autom.tiles[$ _tc[_i].id] = { on : false, pct : 50, t : 30, st : 0, tic : 0 };
}
