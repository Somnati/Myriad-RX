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
bank_y  = 64;
spd_y   = 118;
spd_w   = 40;
spd_gap = 5;
spds    = [1, 2, 4, 6, 8, 10];
spd_x0  = cx - (6 * spd_w + 5 * spd_gap) * .5;
upg_y   = 168;
upg_h   = 24;
upg_x   = 70;
upg_w   = room_width - 140;

// THE QUOTE CACHE. timebank_upg walks a log-space series and packs an
// arb; doing that twice a frame for a number that changes when you buy
// something is waste, so it runs on a slow tick and the Draw reads the
// answer.
qtic   = 0;
q_cap  = { ok : false, cost : arb(1), maxed : false, txt : "" };
q_rate = { ok : false, cost : arb(1), maxed : false, txt : "" };

__back_rect = function() {
	return { x1 : room_width - 62, y1 : hh + 6, x2 : room_width - 6, y2 : hh + 22 };
};
