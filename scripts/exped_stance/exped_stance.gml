/// @description exped_stance(trip or key) -> the STANCE's numbers (his pick, 2026-09-16: cautious / steady / greedy, set on the preparation page)
/// One word on the trip (trip.stance, saved "stn", the haul keeps it for
/// [send again]) that bends the agent's rolls - and is read back in the
/// diary wherever it did something:
///   hurt    the crew is "hurt" under this mean hp: a bed first, a turn for home (exped_next_node); the town plan books the inn under hurt + .2
///   drink   added to the temperament's potion threshold (exped_drink)
///   tavern  the tavern's odds, as a factor (the town plan)
///   bounty  0 never (the board is read and left), 1 as it comes, 2 every time (the tavern)
///   press   -1 a delve ends at the next door once hurt, +1 one room more at the end, sometimes (exped_act_step)
///   fall    a member down = home (exped_tick_one: the quest dropped, the recall set)
///   sell    how many of the pocket's worst go over the counter at a shop (exped_shop)
/// An unknown word reads as steady.
function exped_stance(_k) {
	static _tab = {
		cautious : { key : "cautious", name : "cautious", col : c_sblue,  hurt : .55, drink : .15, tavern : .5,  bounty : 0, press : -1, fall : true,  sell : 1, blurb : "rest early, no bounties, home when one falls" },
		steady   : { key : "steady",   name : "steady",   col : c_sgreen, hurt : .4,  drink : 0,   tavern : 1,   bounty : 1, press : 0,  fall : false, sell : 2, blurb : "as it comes" },
		greedy   : { key : "greedy",   name : "greedy",   col : c_gold,   hurt : .25, drink : -.1, tavern : 1.4, bounty : 2, press : 1,  fall : false, sell : 3, blurb : "rest late, every bounty, one room more" },
	};
	if (is_struct(_k)) _k = _k[$ "stance"] ?? "steady";
	var _s = _tab[$ _k];
	return is_struct(_s) ? _s : _tab.steady;
}
