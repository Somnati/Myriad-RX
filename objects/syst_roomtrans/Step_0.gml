
if alpha = 0 {x = mouse_x; y = mouse_y;}

visible = false;
if alpha > 0 visible = true;

balpha -= (1/15)*delta;

//topleft
r_ = point_distance(x,y,0,0);

//topright
dist = point_distance(x,y,room_width,0);
if dist > r_
r_ = dist;

//bottomleft
dist = point_distance(x,y,0,room_height);
if dist > r_
r_ = dist;

//bottomright
dist = point_distance(x,y,room_width,room_height);
if dist > r_
r_ = dist;

//if switch_rooms = true
//    if des_room = "none"
//des_room = room_get_name(rm_clicker);

if des_room != "none"
        if switch_rooms = true
            if reached_dest = false{
var _covered = false;
if (trans_active_kind == 1) {
	// SLICE cover: the clock runs, Draw End reads it; covered once
	// the LAST slat's sweep completes. alpha only feeds the visible
	// gate here - the slice draw never reads it
	slice_t += delta;
	alpha = 1;
	_covered = (slice_t >= slice_dur + slice_stag * (slice_n - 1));
}
else {
	r += (r_/13)*delta;
	alpha = r/(r_);
	_covered = (r >= r_);
}

// round 2 (his report: heavy rooms froze on a HALF-FADED screen): a
// room_goto fired the same step the cover closed skips that frame's
// draw, so the last PRESENTED frame was ~92% black. hold at full
// black for two presented frames FIRST, then switch - slow creates
// (the planet) now hang behind a truly black screen. BOTH kinds
// share the hold (the slice sits at full slats through it)
if _covered{
alpha = 1;
black_hold += 1;
if black_hold >= 3 {
switch_rooms = false;
reached_dest = true
black_hold = 0;
//if cur_room = rm_load_ui if des_room = room_get_name(rm_clicker) application_resize();

cur_room = room_get_name(des_room_id);
cur_room_id = des_room_id;

room_goto(asset_get_index(des_room))
if (trans_active_kind == 1) {
	// the slats fly onward: same directions, ease-out, revealing
	slice_phase = 2;
	slice_t = 0;
}
else balpha = 1;
//o.alpha_deg = 1/17;
// CLEAR ASSETS
//if not instance_exists(obj_idletime) syst_banner.clear = true;
//obj_button_mainoptions.back = true;
//obj_button_mainoptions.open = false;
//if instance_exists(obj_statistics_infodraw) with obj_statistics_infodraw kill();
        }
}
}

if des_room = cur_room if switch_rooms = false alpha = move_to(alpha,0,3);

// slice reveal: keep the clock running; alpha pins high so the
// visible gate can't kill the draw mid-reveal (the decay line above
// runs first, this wins while the phase is live)
if (slice_phase == 2) {
	slice_t += delta;
	alpha = 1;
	if (slice_t >= slice_dur + slice_stag * (slice_n - 1)) {
		slice_phase = 0;
		alpha = 0;
	}
}

// gameload trans: boot lands on the TITLE now (his ask); continue/
// new game send the player on to rm_visualizer, the first play room
if (in_room(rm_gameload) && (!instance_exists(syst_handle_save) || syst_handle_save.boot_phase >= 2)) goto_room(rm_titlescreen);   // (the boot's spinner first: the galaxy, then the load)


