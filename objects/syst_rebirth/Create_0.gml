/// syst_rebirth - THE REBIRTH OVERLAY (Myriad DE's syst_rebirth,
/// rebuilt). Placed in rm_clicker, dormant until opened from the
/// menu's [rebirth] line (rebirth_open). Open, it darkens the room
/// under the header and shows DE's collect banner: the full-width
/// button (spr_rebirth_btn is DE's spr_buttontype_4, 144 wide = the
/// room, at DE's y 172), HOLD to fill it centre-out, and at 100 the
/// rebirth commits. All the maths is rebirth_calc / rebirth_do; this
/// object is view + ceremony only.
/// INPUT: a syst_input family member wearing ui_layer_modal. While
/// open it raises the modal block (syst_input's blocker line), so
/// the tap surface, the drawer and the menu go quiet and only this
/// widget hears the pointer. Closed it is invisible and the families
/// skip it.

// DE's geometry, portrait: the banner spans the room at y 172
bx = 0; by = 172; bw = room_width;

open   = false;
alpha  = 0;    // overlay fade
balpha = 0;    // banner pop
scale  = 0;    // banner y-scale pop
ts     = 1.5;  // label settle (starts big, trickles to 1)
hp     = 0;    // the hold-to-fill charge, 0..100
glow   = 0;    // white flash on open
fired  = false; // one-shot: the rebirth landed, ride the wipe out

calc = rebirth_calc();

ui_layer = ui_layer_modal;
depth = -600;   // over the room and the drawer, under the header (-1000)
// THE OVERLAY CONTRACT (2026-09-10, his ask: rebirth opens in whatever
// room you are in, with the blur): ui_overlay lists this while it is
// open, so ui_blur_tick reads oa off it and the burger becomes the X.
// oa mirrors alpha, closing mirrors !open - see the Step.
oa      = 0;
closing = false;
// A GUEST INSTANCE is one rebirth_open spawned outside the money room
// (this object is placed only there). It has no banner to go back to
// being, so once it has closed and faded it destroys itself.
guest = !in_room(rm_clicker);

// THE MILESTONE SCALES (2026-09-13): the ruler under the tap room - DE's
// and the rebuilt one, both while he compares (SCALE_COMPARE); they live
// with this object because it is the one thing placed only in rm_clicker
if (!guest) {
	if (SCALE_COMPARE && !instance_exists(obj_scale_de)) create_obj(0, 0, obj_scale_de);
	if (!instance_exists(obj_scale_rx)) create_obj(0, 0, obj_scale_rx);
}
image_speed = 0;
visible = false; // closed: draws nothing, families skip it

x = bx; y = by;
image_xscale = bw / sprite_get_width(sprite_index);
image_yscale = 1;

/// THE FLAVOR NAMES (DE's originals, his words). Seeded by the rebirth
/// count so each rebirth greets consistently; the stream is released
/// after (rng_release - a set_seed "restore" would rewind it).
__roll_names = function() {
	var _keep = random_get_seed();
	random_set_seed(g.rebirth.total + 777001);
	name = choose(
		"lets go", "come on", "bring it", "bring it on", "sure",
		"sounds good", "good to go", "alright", "ok", "fine", "confirm",
		"okay", "yes", "get some", "again?...really?", "press me");
	name_error = choose(
		"error", "error 404", "failure", "incomplete", "missing no.",
		"println(null)", "syntax error", "nope", "not yet", "loading...",
		"please stand by", "[insert nonsense here]", "dont look at me");
	if (irandom(99) == 0) name_error = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
	if (irandom(99) == 1) name = "ready to lose everything?";
	if (g.rebirth.total == 0)   name = "press this to earn units";
	if (g.rebirth.total == 3)   name = "ready to lose it all again.";
	if (g.rebirth.total == 5)   name = "this is fun right?";
	if (g.rebirth.total == 20)  name = "why stop here right?";
	if (g.rebirth.total == 99)  name = "this is your 100th rebirth!!!";
	if (g.rebirth.total == 199) name = "this is your 200th rebirth...get help.";
	rng_release(_keep);
	name = string_upper(name);
	name_error = string_upper(name_error);
};
__roll_names();

/// open the overlay (the menu's line lands here through rebirth_open)
__open = function() {
	__roll_names();
	open = true; visible = true;
	hp = 0; glow = 1; ts = 1.5; scale = 0; balpha = 0;
	calc = rebirth_calc();
	if (variable_global_exists("rebirth_open_pending")) g.rebirth_open_pending = false;
};

// opened from another room: the pending flag rode the room hop
if (variable_global_exists("rebirth_open_pending") && g.rebirth_open_pending) __open();
