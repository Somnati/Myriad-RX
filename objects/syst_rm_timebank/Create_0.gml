/// syst_rm_timebank - THE TIME BANK's room (Techdemo II's, ported).
/// rm_timebank is ONLY a view: the state is g.timebank, banking happens
/// in offline_replay, spending in timebank_spend on syst_production's
/// heartbeat. This screen binds the speed choice and the two upgrades
/// and paints the numbers.
///   - the bank readout BIG and central
///   - the speed row x1..x10 as a segmented control: in a room with
///     space, every option shows at once rather than cycling through a
///     pill. Leaving x1 needs a non-empty bank; a dead click buzzes.
///   - the two upgrades (capacity / rate) on cost-inside buttons,
///     profit-priced, quoted on the slow tick
///   - an explainer, because a mechanic that pays you for being absent
///     is not self-evident
/// The house room-view pattern: draw-only plus region hits, both off
/// the same geometry declared here.

timebank_init();

hh = instance_exists(obj_ui_header) ? obj_ui_header.sprite_height : 16;

// ---- layout (region law: Step's hits and Draw share these) ----
cx      = room_width * .5;
// ⚖️ THE STRIP ENDS AT hh + 16, AND hh IS 29, NOT 16. The header sprite
// is 29 tall, so the title band runs to y 45 - and the "banked time"
// caption, which sits 16 above the big readout, was landing inside it
// (his report). Everything below is measured from that 45 now instead
// of from numbers that happened to look right.
bank_y  = 68;

// THE SPEED ROW. His set: off / x2 / x4 / x10 / x50. The gaps widen as
// they climb because the choice is about PACE, not power - every speed
// converts the bank one for one (timebank_twin's invariant 2), so what
// the ladder is really offering is "how long do you want this to last".
spd_y   = 116;
spd_w   = 44;
spd_gap = 5;
spds    = [1, 2, 4, 10, 50];
NSPD    = 5;
spd_x0  = cx - (NSPD * spd_w + (NSPD - 1) * spd_gap) * .5;

// THE BURN ROW (his ask): spend a lump at once and have it happen, the
// way an absence of that length would have. See timebank_burn.
burn_y  = 152;
burn_w  = 52;
burn_gap = 6;
burns   = [60, 600, 3600, 21600];
burn_lbl = ["1m", "10m", "1h", "6h"];
NBURN   = 4;
burn_x0 = cx - (NBURN * burn_w + (NBURN - 1) * burn_gap) * .5;

upg_y   = 182;
upg_h   = 24;
upg_x   = 70;
upg_w   = room_width - 140;

// THE QUOTE CACHE. timebank_upg walks a log-space series and packs an
// arb; doing that twice a frame for a number that changes when you buy
// something is waste, so it runs on a slow tick and the Draw reads the
// answer.
qtic   = 0;
q_cap  = { ok : false, cost : 0, maxed : false, txt : "" };
q_rate = { ok : false, cost : 0, maxed : false, txt : "" };

// the last burn, so the screen can say what it paid rather than leaving
// the player to spot a counter move
burn_msg = "";
burn_hp  = 0;

__back_rect = function() {
	return { x1 : room_width - 62, y1 : hh + 6, x2 : room_width - 6, y2 : hh + 22 };
};
