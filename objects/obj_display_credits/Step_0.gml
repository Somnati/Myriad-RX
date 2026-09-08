credits_init();

var _live = variable_global_exists("game_started") && g.game_started
	&& !in_room(rm_titlescreen) && !in_room(rm_gameload) && !in_room(rm_quit);

// ---- the show budget (DE's hp) ----
hp = max(0, hp - delta / 60);
add_hp = max(0, add_hp - delta / 60);
if (add_hp <= 0) add_val = 0;

// DE's rules, in DE's order: the menu forces it out; "always show
// popups" (g.persist_popups, settings > gameplay, off by default) keeps
// it out in the money room while no drawer is open; the dial drawer
// being OUT puts it away (DE: obj_dragautos.open -> hp = 0); the
// rebirth overlay puts it away
var _menu   = instance_exists(obj_ui_menu2) && obj_ui_menu2.open;
var _drawer = instance_exists(syst_dials) && syst_dials.sp > .5;
// a screen holding the panel open outranks the drop timer entirely -
// see `pin` in the Create. A room whose every price is in credits wants
// the balance up the whole time, not for three seconds after a drop.
if (pin) hp = hp_;
if (_menu) hp = hp_;
if (in_room(rm_clicker) && !_drawer && variable_global_exists("persist_popups") && g.persist_popups) hp = hp_;
if (!_menu && _drawer) hp = 0;
if (instance_exists(syst_rebirth) && syst_rebirth.open) hp = 0;
var _want = _live && (hp > 0);

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
if (add_val > 0) text += "+" + string(add_val);   // DE: no space

draw_set_font(fnt);
tw = string_width(text) + 15;

// the slide: tucked = fully off the left edge, out = flush with it
x_ = -(tw + 2) + (tw + 2) * move;
visible = (move > 0);

// the vertical seat: whatever was asked for this frame, else home. It
// GLIDES rather than jumps, so a screen that moves it is a slide and
// not a teleport, and two screens disagreeing across a room change look
// like one movement.
y = trickle(y, (desy == -1) ? ystart : desy, 5);

seat_x = 5 + 3;
seat_y = y + 4;

// consumed. Whoever wants it next frame asks again.
pin  = false;
desy = -1;
