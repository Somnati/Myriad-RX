/// syst_exped_panel - THE EXPEDITION BENCH (the mock, his go
/// 2026-09-12): one screen with the whole loop on it so the FEEL can be
/// tested. Choose a world, send a sprite, watch the trip (travel, the
/// delve room by room, a fight you can watch or step), open the haul.
/// The loop itself lives in exped_* and runs on the heartbeat whether
/// or not this is open - this is only the view. On the overlay
/// contract (oa / closing, ui_overlay lists it, the burger's X and
/// escape close it); it paints its own ground and is OPAQUE (no paid
/// taps under it). Landscape layout (the bench is a desktop thing).
///
/// THREE VIEWS, by state:
///   the BOARD   no trip, no haul: three world cards + the crew row
///   the TRIP    the world's card, the stage bar, the log, the fight
///   the HAUL    the card of finds, [collect]

exped_init();
sprites_init();
depth   = -510;
oa      = 0;
closing = false;
opaque  = true;

hh = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;
strip_y = hh; list_y = hh + 16;

// ---- the board's cards: three across ----
card_w = 140; card_h = 118;
card_gap = 12;
card_x0 = (room_width - (3 * card_w + 2 * card_gap)) div 2;
card_y  = list_y + 8;
crew_y  = card_y + card_h + 10;      // the crew row under the cards
sel_dest = -1;                       // the world picked
sel_crew = -1;                       // the sprite picked (index into g.sprites)

// ---- the trip view ----
big_x = 16; big_y = list_y + 8; big_w = 160; big_h = 150;
log_x = big_x + big_w + 14; log_w = room_width - log_x - 16;

// ---- the shader's handles ----
u_quad  = shader_get_uniform(sh_planet_lite, "u_quad");
u_cells = shader_get_uniform(sh_planet_lite, "u_cells");
u_col1  = shader_get_uniform(sh_planet_lite, "u_col1");
u_col2  = shader_get_uniform(sh_planet_lite, "u_col2");
u_col3  = shader_get_uniform(sh_planet_lite, "u_col3");
u_sea   = shader_get_uniform(sh_planet_lite, "u_sea");
u_seed  = shader_get_uniform(sh_planet_lite, "u_seed");
u_time  = shader_get_uniform(sh_planet_lite, "u_time");
u_light = shader_get_uniform(sh_planet_lite, "u_light");

/// a world's portrait: a raycast sphere in the biome's colours,
/// turning slowly, seeded by the destination
__portrait = function(_d, _cx, _cy, _r) {
	var _b = exped_biomes()[_d.biome];
	var _qs = ceil(_r * 2 * 1.2) + 2;   // the quad holds the disc AND its halo (the shader maps the disc to 1/1.2 of it)
	var _qx = _cx - _qs * .5, _qy = _cy - _qs * .5;
	shader_set(sh_planet_lite);
	shader_set_uniform_f(u_quad, _qx, _qy, _qs, _qs);
	shader_set_uniform_f(u_cells, _qs);
	shader_set_uniform_f(u_col1, colour_get_red(_b.col1) / 255, colour_get_green(_b.col1) / 255, colour_get_blue(_b.col1) / 255);
	shader_set_uniform_f(u_col2, colour_get_red(_b.col2) / 255, colour_get_green(_b.col2) / 255, colour_get_blue(_b.col2) / 255);
	shader_set_uniform_f(u_col3, colour_get_red(_b.col3) / 255, colour_get_green(_b.col3) / 255, colour_get_blue(_b.col3) / 255);
	shader_set_uniform_f(u_sea, _b.sea);
	shader_set_uniform_f(u_seed, (_d.seed mod 100000));
	shader_set_uniform_f(u_time, ((current_time mod 200000) / 1000) * .15 + (_d.seed mod 360));
	shader_set_uniform_f(u_light, -.5, -.55, .67);
	draw_sprite_stretched(spr_pixel_1x1, 0, _qx, _qy, _qs, _qs);
	shader_reset();
};

__card_r = function(_i) { return { x : card_x0 + _i * (card_w + card_gap), y : card_y, w : card_w, h : card_h }; };
__send_r = function(_i) { var _c = __card_r(_i); return { x : _c.x + 8, y : _c.y + _c.h - 20, w : _c.w - 16, h : 14 }; };
__crew_r = function(_k) { return { x : card_x0 + _k * 30, y : crew_y + 10, w : 26, h : 26 }; };
__spd_r  = function(_k) { return { x : room_width - 8 - 3 * 28 + _k * 28, y : strip_y + 2, w : 26, h : 12 }; };
__step_r = function() { return { x : log_x, y : room_height - 8 - 14, w : 70, h : 14 }; };
__col_r  = function() { return { x : room_width * .5 - 45, y : room_height - 8 - 16, w : 90, h : 16 }; };
