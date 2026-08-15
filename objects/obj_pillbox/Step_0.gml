
// hold-to-select clock: press, hold a beat, release over a pill
// (the mobile-friendly gesture the Myriad original had)
if (!mouse_check_button(mb_left)) ctic = 0;
else ctic += delta;

// ---- first-frame placement ----
if (!placed) {
	placed = true;
	// open away from the nearer screen edge, sliding in toward the tap
	// (or wherever force_side insists - the combat action menu opens
	// to the pawn's right regardless of screen position)
	openleft = (mx_ >= left_lat);
	if (force_side == 0) openleft = false;
	if (force_side == 1) openleft = true;
	if (openleft) { x_ = mx_ - 15; xx = -16; }
	else          { x_ = mx_ + 15; xx =  16; }
	y_ = my_;
	// clamp the whole stack on screen, below the header band
	var _top = 29;
	if (y_ - all_h * .5 < _top)             y_ = _top + all_h * .5;
	if (y_ + all_h * .5 > room_height - 5)  y_ = room_height - 5 - all_h * .5;
	y_ += (h + 2) * i - all_h * .5;
	y = y_;
}

tic += .7 * delta;

// the OWNER's _popen is the one open/closed authority
var _ok   = instance_exists(obj);
var _open = _ok && obj._popen;

if (_open && tic > i) alpha = trickle(alpha, 1, 4);
if (!_open) {
	alpha = trickle(alpha, 0, 4);
	if (alpha <= .01) { kill; exit; }
}

w = trickle(w, des_w, 4);
if (tic > i) xx = trickle(xx, des_x, 4);

// side-aware anchor + screen clamp
var _bnd = 4;
if (openleft) x = clamp(x_ - des_w, _bnd, room_width - des_w - _bnd) + xx;
else          x = clamp(x_,         _bnd, room_width - des_w - _bnd) + xx;

// stretch the 1x1 sprite over the pill: syst_input's sweep needs a bbox
image_xscale = max(w, 1);
image_yscale = h;

// ---- pick (fully arbitrated: mouse_over() = we own the pointer,
// input_free(ui_layer_popup) = nothing stronger blocks us) ----
if (_open && pill.can_click && input_free(ui_layer_popup))
if (mouse_over())
if (mouse_check_button_pressed(mb_left)
|| (mouse_check_button(mb_left) && ctic > 60 && !selected)) {
	play_sound_ext(snd_pop, .8, 1.2, .3, 1);
	glow = 1;
	selected = true;
	obj._pselid   = i;
	obj._pselname = pill.name;
	obj._pselval  = pill.val;
	if (type == 0) {
		des_x = openleft ? -16 : 16; // slide out the way we came
		obj._popen = false;
	}
}

// outside tap closes the whole stack; pill 0 polices it for everyone.
// sticky boxes (combat action menu) ignore outside taps entirely
if (i == 0 && _open && !sticky)
if (input_free(ui_layer_popup) && mouse_check_button_pressed(mb_left))
if (!point_in_rectangle(mouse_x, mouse_y, x, y, x + w, y + all_h))
	obj._popen = false;

glow = clamp(glow - .07 * delta, 0, 1);
