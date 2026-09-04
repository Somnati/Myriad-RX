credits_init();

var _live = variable_global_exists("game_started") && g.game_started
	&& !in_room(rm_titlescreen) && !in_room(rm_gameload) && !in_room(rm_quit);

// ---- the show budget (DE's hp) ----
hp = max(0, hp - delta / 60);
add_hp = max(0, add_hp - delta / 60);
if (add_hp <= 0) add_val = 0;

var _want = _live && (hp > 0);
// out while the dial drawer is out: the balance is readable while shopping
if (_live && instance_exists(syst_dials) && syst_dials.sp > .5) _want = true;
// never under the rebirth overlay
if (instance_exists(syst_rebirth) && syst_rebirth.open) _want = false;

move = trickle(move, _want ? 1 : 0, 4);
if (move < .01 && !_want) { move = 0; add_val = 0; }
glow = max(0, glow - .07 * delta);

// ---- the number: glides up to the real balance (DE trickles it) ----
var _real = (g.credits >= arb(1)) ? unarb(g.credits) : 0;
if (_real < 1000000000) {
	shown = trickle(shown, _real, 5);
	if (abs(shown - _real) < .5) shown = _real;
	text = string(round(shown));
} else {
	shown = _real;
	text = crunch_arb(g.credits);
}
if (add_val > 0) text += " +" + string(add_val);

draw_set_font(fnt);
tw = string_width(text) + 15;

// the slide: tucked = fully off the left edge, out = flush with it
x_ = -(tw + 2) + (tw + 2) * move;
y  = ystart;
visible = (move > 0);

seat_x = 5 + 3;
seat_y = y + 4;
