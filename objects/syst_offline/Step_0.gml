// ---- the suspend catch-up ----
var _now = date_current_datetime();
if (_now >= last_now) {
	var _gap = date_second_span(_now, last_now);
	if (_gap >= GAP && variable_global_exists("game_started") && g.game_started)
		offline_replay(_gap);
}
last_now = _now;

// ---- the report (DE's obj_idletime: banners in the money room) ----
if (!variable_global_exists("offline_report")) exit;
var _r = g.offline_report;
if (_r.shown) exit;
if (!in_room(rm_clicker)) exit;
if (!variable_global_exists("game_started") || !g.game_started) exit;
if (!instance_exists(syst_banner)) exit;
_r.shown = true;
if (_r.secs < REPORT_MIN) exit;

// assign_banner pushes onto the TOP of the stack, so the last line
// assigned is the first one read - DE's order, verbatim. hp x3 keeps
// each line up three times longer than a passing toast.
// the time bank's slice, only when there is one to report - a line
// saying "banked 0s" is a line about nothing
var _bk = _r[$ "banked"] ?? 0;
if (_bk >= 1) {
	assign_banner("banked " + crunch_time_long(_bk * 60)
		+ ((_r[$ "bank_full"] ?? false) ? " - bank full" : ""),
		c_gold, c_black);
	syst_banner.hp[0] *= 3;
}
assign_banner("earned +" + ((_r.gain > 0) ? crunch_arb(_r.gain) : "0"),
	g.profit_color, c_black);
syst_banner.hp[0] *= 3;
assign_banner("idle rate " + ((_r.rate > 0) ? crunch_arb(_r.rate) : "0") + "/sec",
	color_set_comp(g.profit_color), c_black);
syst_banner.hp[0] *= 3;
assign_banner("time away " + crunch_time_long(_r.secs * 60), c_gold, c_black);
syst_banner.hp[0] *= 3;
assign_banner("welcome back", c_white, c_black);
syst_banner.hp[0] *= 3;
