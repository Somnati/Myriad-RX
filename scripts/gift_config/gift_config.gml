/// @description gift_config() - THE file to edit for the daily gift
/// calendar (settings_content doctrine: declarative, tune here).
/// THE SHAPE (his work order, Techdemo II 2026-07-12; ported to RX
/// 2026-09-10): a ROLLING 2-week board of 14 slots. One collect per
/// real CALENDAR day; collecting punches the next slot. Missing days
/// NEVER resets or skips anything - the board simply waits at the same
/// slot (no missed-day reset, his spec), so the calendar rolls with the
/// player's own pace, not the wall calendar. Slot 14 collected -> a
/// fresh board deals (cycle++, new rarities). Every slot carries a
/// RARITY rolled deterministically from (cycle, slot) - richer odds
/// deeper into the fortnight, and the week-cap slots (7 and 14) carry
/// guaranteed floors so each week ends on a showpiece. Collecting
/// feeds the gift LEVEL (derived from total claims, never stored -
/// house law) and every level raises reward output.
///
/// ⚖️ RX'S REWARDS (the tech demo paid flat profit / resin - a
/// placeholder economy). RX has no resin and its profit runs to e308,
/// so a flat 40 would be a rounding error by the second hour. Two
/// kinds: PROFIT, paid as SECONDS OF THE CURRENT RATE (all_gps x
/// base_secs x rarity x level - a gift that is always worth the same
/// fraction of a session, whatever the run has grown to; a fresh game
/// with no dials gets a flat floor instead), and CREDITS, flat whole
/// units (the dropper's currency is small integers by design).
function gift_config() {
	g.gift_cfg = {
		days : 14, // the rolling board length (2 weeks)

		// the rarity ladder - the house rarity colours, so a gift's
		// rarity reads like every other rarity in the game. mult scales
		// the reward; weight tables below pick the tier
		rars : [
			{ name : "common",    col : rgb(200, 200, 200), mult : 1  },
			{ name : "uncommon",  col : c_rarity_uncommon,  mult : 2  },
			{ name : "rare",      col : c_rarity_rare,      mult : 4  },
			{ name : "epic",      col : c_rarity_epic,      mult : 9  },
			{ name : "legendary", col : c_rarity_legendary, mult : 20 },
		],
		// tier weights at the board's FIRST slot and its LAST - every
		// slot between lerps across, so the fortnight ramps from mostly
		// common toward real odds of the top tiers
		w_first : [70, 22, 6, 2, 0],
		w_last  : [26, 32, 24, 13, 5],
		// week-cap floors: slot index -> minimum tier (day 7 at least
		// rare, day 14 at least epic)
		floor_a : 6,  floor_a_tier : 2,
		floor_b : 13, floor_b_tier : 3,

		// reward kinds: 0 = profit (seconds of the current rate), 1 =
		// credits (whole units). profit stays the commoner drop - it is
		// the currency the run is made of; credits are the rarer treat
		base_secs    : 120,   // a common profit gift = two minutes of income
		floor_profit : 100,   // ...or this, on a run with no rate yet
		base_credits : 2,     // a common credit gift
		profit_odds  : 65,    // % of slots that roll profit over credits

		// the gift level: derived from TOTAL claims (gift_level). a
		// level costs lvl_base + lv * lvl_step claims (3, 5, 7, ...),
		// and each level adds lvl_out to the reward output multiplier
		lvl_base : 3,
		lvl_step : 2,
		lvl_out  : .25,
	};
}
