/// @description ex_orbit_init() - THE ORBIT RENDERER of syst_exped_panel and the worlds' building: __draw_orbit (the page's world, its sky, its moons, the spots), __px_box2, the cameras (__cam_face / __cam_tt / __cam_toward / __spot_yp), __world_small, __worlds_step (the page's world a few rows a frame) and the zoom tier's hooks (__lod_* onto TierKeep) - defined on the panel (self = the panel; called from its Create). q219, the deconvolution
function ex_orbit_init() {
/// THE ORBIT RENDERER (2026-09-15: "have all models of the planet match our
/// main one... stars and all"): the sky (the real neighbourhood, the milky
/// way, the sun - pv_sky), the world at (pcx, pcy) of the rect with radius
/// pr through the camera cam (view -> world) and its own spin, and the
/// regions' spots: a 2px square each on the far-side test, the focused
/// one a pulsing hollow square in 2px lines (pixel, not a circle), labels
/// in the OUTLINE font when facing you (his ask: readable over the world).
/// Rendered into wb_surf and blitted at (x, y): nothing spills. spots =
/// -1 none, -2 all, else only that region. Returns { m, r } (texture-
/// from-view and its inverse) for the caller's pick
__draw_orbit = function(_d, _x, _y, _w, _h, _pcx, _pcy, _pr, _cam, _spin, _spots, _focus, _cfade) {
	_w = max(2, floor(_w)); _h = max(2, floor(_h));
	if (!surface_exists(wb_surf) || surface_get_width(wb_surf) != _w || surface_get_height(wb_surf) != _h) {
		if (surface_exists(wb_surf)) surface_free(wb_surf);
		wb_surf = page_surface(_w, _h);   // (float where the gpu allows: one quantisation, at the blit)
	}
	if (!surface_exists(sky_fog_surf) || surface_get_width(sky_fog_surf) != _w || surface_get_height(sky_fog_surf) != _h) {
		if (surface_exists(sky_fog_surf)) surface_free(sky_fog_surf);
		sky_fog_surf = surface_create(_w, _h);
	}
	var _sky = __sky_for(_d);   // (the world's own sky, 2026-09-16)
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	var _built = (_pn.row >= _pn.th) && ((_pn[$ "brow"] ?? 0) >= 3 * _pn.th);   // (rows AND textures: planet_draw bakes whole otherwise - __worlds_step slices it)
	var _wm = mat3_mul(mat3_rot(0, 0, 1, _pn.tilt), mat3_rot(0, 1, 0, _spin));
	var _mm = mat3_mul(mat3_transpose(_wm), _cam);
	var _mr = mat3_transpose(_mm);
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	surface_set_target(wb_surf);
	draw_clear_alpha(c_black, 1);
	// the sun's occluders: the world's disc, and the moons' (the moon maths of moon_draw - an eclipse from the camera's seat, 2026-09-16)
	var _occs = [{ x : _pcx, y : _pcy, r : _pr }];
	var _mns0 = planet_moons(_d.seed), _nmn0 = min(4, planet_props(_d).moons);
	for (var _mi0 = 0; _mi0 < _nmn0; _mi0++) { var _mv0 = moon_view_pos(_pn, _mns0[_mi0], _cam); var _k0 = 6 / max(6 - _mv0[2], .5); array_push(_occs, { kind : "moon", x : _pcx + _mv0[0] * _pr * _k0, y : _pcy + _mv0[1] * _pr * _k0, r : max(1, _mv0[3] * _pr * 1.02 * _k0) }); }
	galaxy_sky_draw(_sky, _cam, _pcx, _pcy, _w, _h, true, true, _occs);   // (the sun fades behind the world - his report 2026-09-16)
	galaxy_fog_draw(_sky, _cam, _pcx, _pcy, _w, _h, sky_fog_surf);
	galaxy_sky_holes(_sky, _cam, _pcx, _pcy, _w, _h, true, _occs);   // (the holes over the fog; a hole for a sun bends the fog too - 2026-09-17)
	// THE METEOR (2026-09-16): a streak now and then, fading along its length; page space, before the world (it is sky)
	sky_met_t += delta / 60;
	if (is_undefined(sky_met) && sky_met_t > (starmap_config()[$ "sky_meteor"] ?? 28) * random_range(.6, 1.5)) {
		var _ma = random(360), _ml = random_range(40, 90);
		sky_met = { x : random_range(_w * .1, _w * .9), y : random_range(_h * .1, _h * .6), dx : dcos(_ma) * _ml, dy : -dsin(_ma) * _ml, t : 0, life : random_range(.28, .45) };
		sky_met_t = 0;
	}
	if (is_struct(sky_met)) {
		var _mt = sky_met.t / sky_met.life;
		var _hx = sky_met.x + sky_met.dx * _mt, _hy = sky_met.y + sky_met.dy * _mt;
		for (var _mi2 = 0; _mi2 < 7; _mi2++) { var _mf = _mi2 / 7; draw_sprite_ext(spr_pixel_1x1, 0, floor(_hx - sky_met.dx * .22 * _mf), floor(_hy - sky_met.dy * .22 * _mf), 1, 1, 0, merge_colour(c_white, rgb(200, 220, 255), _mf), (1 - _mf) * (1 - _mt * _mt) * .9); }
		sky_met.t += delta / 60;
		if (sky_met.t >= sky_met.life) sky_met = undefined;
	}
	g.dither_off = page_float();   // (the world into a float page: no dither of its own - the blit's grain is the one)
	// THE MOONS (the tech demo's, back - 2026-09-15): the far half before the world, the near half after
	var _mns = planet_moons(_d.seed), _nmn = min(4, planet_props(_d).moons);
	if (_built) for (var _mi = 0; _mi < _nmn; _mi++) moon_draw(_pn, _mns[_mi], _mi, false, _pcx, _pcy, _pr, _cam, _sky.light_w);
	// the moons' shadow casters, and the storm regions' spots (2026-09-16)
	var _msh = [];
	for (var _mi = 0; _mi < _nmn; _mi++) array_push(_msh, moon_view_pos(_pn, _mns[_mi], _cam));
	var _storms = [];
	for (var _si = 0; _si < EXPED_REGIONS; _si++) { var _srg = region_get(_d, _si); if (region_weather(_d, _srg) == "storm") array_push(_storms, __spot_dir(_srg.spot.lon, _srg.spot.lat)); }
	var _lod = (view == "planet") ? __lod_pick(_pn) : ((view == "trip") ? tiers.pick(_pn, true) : undefined);   // (the zoom tier standing for this zoom, the page's own - 2026-09-17; the trip page's region box wants it too - q268)
	if (is_struct(_lod)) _lod.fade = lod_fade;   // (its fade-in, __lod_step's - q256)
	// the aurora's strength is the star's (q205): main 1, a red giant 1.6, a white dwarf .45, a pulsar 2.2, a black hole's disc 1.2
	var _askd = _sky[$ "skind"] ?? "main";
	_pn.astr = (_sky[$ "hole"] ?? false) ? 1.2 : ((_askd == "giant") ? 1.6 : ((_askd == "dwarf") ? .45 : ((_askd == "pulsar") ? 2.2 : ((_askd == "chroma") ? 1.8 : ((_askd == "swell") ? 1.5 : ((_askd == "brown") ? .3 : 1))))));
	_pn.sunl = star_light((_sky[$ "hole"] ?? false) ? "hole" : _askd, _sky[$ "sseed"] ?? 0, _sky[$ "speriod"] ?? 2400).tint;   // THE STAR'S LIGHT on the world (q253): sh_planet's day in the sun's colour and strength
	if (_built) planet_draw(_pn, _pcx, _pcy, _pr, _spin, _cfade, _cam, _sky.light_w, _msh, _storms, _lod, (view == "planet") ? pv_pfade : 1);
	if (_built) for (var _mi = 0; _mi < _nmn; _mi++) moon_draw(_pn, _mns[_mi], _mi, true, _pcx, _pcy, _pr, _cam, _sky.light_w);
	// THE ECLIPSE RIM (2026-09-16): the sun behind the world - its glare leaks round the limb on the side it hides behind
	if (_built) {
		var _svr = mat3_apply(mat3_transpose(_cam), _sky.light_w[0], _sky.light_w[1], _sky.light_w[2]);
		if (_svr[2] < -.1) {
			var _sfr = 230 / -_svr[2], _rsx = _pcx + _svr[0] * _sfr, _rsy = _pcy + _svr[1] * _sfr;
			var _rdd = point_distance(_rsx, _rsy, _pcx, _pcy);
			if (_rdd < _pr * 1.25 && _rdd > .5) {
				// the leak peaks AT the limb and fades as the sun sinks behind (gone by half way in) - it held whole and snapped round, his report 2026-09-16
				var _hid = clamp(1 - abs(_rdd - _pr) / (_pr * .5), 0, 1);
				var _lx = _pcx + (_rsx - _pcx) / _rdd * _pr, _ly = _pcy + (_rsy - _pcy) / _rdd * _pr;
				var _gsz = (_pr * 1.1) / max(1, sprite_get_width(spr_vis_glow_soft));
				gpu_set_blendmode(bm_add);
				draw_sprite_ext(spr_vis_glow_soft, 0, _lx, _ly, _gsz, _gsz, 0, _sky.sun_col, .28 * _hid);
				draw_sprite_ext(spr_vis_glow_soft, 0, _lx, _ly, _gsz * .45, _gsz * .45, 0, merge_colour(_sky.sun_col, c_white, .5), .35 * _hid);
				gpu_set_blendmode(bm_normal);
			}
		}
	}
	g.dither_off = false;
	// (not built yet: the sky alone - the lite portrait that stood in "looked really bad", his report 2026-09-15; the boot builds the board's worlds)
	if (_built && _spots != -1) {
		draw_set_font(fnt_outline); draw_set_halign(fa_left); draw_set_valign(fa_top);
		var _pulse = floor(1.5 + 1.5 * dsin(current_time * .25));
		for (var _i = 0; _i < EXPED_REGIONS; _i++) {
			if (_spots >= 0 && _i != _spots) continue;
			var _rg = region_get(_d, _i);
			var _t = __spot_dir(_rg.spot.lon, _rg.spot.lat);
			var _v = mat3_apply(_mr, _t[0], _t[1], _t[2]);
			if (_v[2] <= .1) continue;
			var _rr = __spot_r(_pn, _rg.spot.lon, _rg.spot.lat);   // (on its own ground - the mountains' parallax, 2026-09-16)
			var _sx = floor(_pcx) + floor(_v[0] * _rr * _pr * .5) * 2, _sy = floor(_pcy) + floor(_v[1] * _rr * _pr * .5) * 2;
			var _on = (_i == _focus);
			// an OUTLINED SQUARE (his ask): black 8x8 under a 4x4 in the colour - a 2px outline
			draw_sprite_ext(spr_pixel_1x1, 0, _sx - 4, _sy - 4, 8, 8, 0, c_black, .9);
			draw_sprite_ext(spr_pixel_1x1, 0, _sx - 2, _sy - 2, 4, 4, 0, _on ? c_gold : c_white, 1);
			if (_on) {
				var _s = 12 + _pulse * 2;
				__px_box2(_sx - _s * .5, _sy - _s * .5, _s, c_gold, .95);
			}
			if (_v[2] > .3) {
				draw_set_color(_on ? c_gold : c_white); draw_set_alpha(_on ? .95 : .85);
				draw_text(_sx + 6 + (_on ? 3 : 0), _sy - 4, _on ? _rg.name : ("lv " + string(_rg.lv)));
			}
		}
		draw_set_font(fnt);
		draw_set_alpha(1);
	}
	surface_reset_target();
	ui_fade_set(_fa);
	page_blit(wb_surf, _x, _y);   // (the one dither)
	return { m : _mm, r : _mr };
};
/// a hollow square in 2px lines (the pixel look: no fine lines)
__px_box2 = function(_x, _y, _s, _col, _a) {
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, _s, 2, 0, _col, _a);
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y + _s - 2, _s, 2, 0, _col, _a);
	draw_sprite_ext(spr_pixel_1x1, 0, _x, _y + 2, 2, _s - 4, 0, _col, _a);
	draw_sprite_ext(spr_pixel_1x1, 0, _x + _s - 2, _y + 2, 2, _s - 4, 0, _col, _a);
};
/// a camera turned to FACE a region's spot (the face-turn run to the end):
/// the trip page's world, fixed on where the crew is
__cam_face = function(_pn, _spin, _rg, _cam) {
	// (the turntable's, 2026-09-16: the region's longitude and latitude, north up - cam is unused, kept for the callers)
	var _yp = __spot_yp(_pn, _spin, _rg);
	return __cam_tt(_pn, _yp.yaw, _yp.pitch);
};
/// THE TURNTABLE CAMERA: yaw about the world's axis, pitch above its plane, the axis
/// up the screen (the 180 roll at the end: view y runs down the screen) -> cam = view -> world
__cam_tt = function(_pn, _yaw, _pitch) {
	var _af = mat3_rot(0, 0, 1, _pn.tilt);
	return mat3_mul(mat3_mul(_af, mat3_rot(0, 1, 0, _yaw)), mat3_mul(mat3_rot(1, 0, 0, _pitch), [-1, 0, 0, 0, -1, 0, 0, 0, 1]));
};
/// a step of the camera toward a target camera: the ONE rotation between them (axis-angle of
/// target x cam^T, world space), a fraction k of its angle; undefined once within .05 degree (arrived)
__cam_toward = function(_cam, _tgt, _k) {
	var _rr = mat3_mul(_tgt, mat3_transpose(_cam));
	var _ang = darccos(clamp((_rr[0] + _rr[4] + _rr[8] - 1) * .5, -1, 1));
	if (_ang < .05) return undefined;   // (there: the caller takes the target itself)
	var _ax = _rr[7] - _rr[5], _ay = _rr[2] - _rr[6], _az = _rr[3] - _rr[1];
	var _al = sqrt(_ax * _ax + _ay * _ay + _az * _az);
	if (_al < .0001) { _ax = 0; _ay = 1; _az = 0; }   // (180 degrees apart: any axis in the plane; take the world's up)
	// THE LAST DEGREES AT A FLOOR (his report, 2026-09-17: "the jitter is at the end when it settles"): an ease that
	// only ever takes a fraction of what is left creeps for half a second under a pixel a frame, and the terrain's
	// cells flicker under the crawl. Past the fraction's own pace the step is at least a third of a degree a
	// sixtieth, so it arrives and stops
	var _stp = min(_ang, max(_ang * _k, .35 * delta));
	// (mat3_rot's sin is flipped for the screen - both signs tried, the one that closes the gap kept)
	var _c1 = mat3_mul(mat3_rot(_ax, _ay, _az, _stp), _cam), _c2 = mat3_mul(mat3_rot(_ax, _ay, _az, -_stp), _cam);
	var _r1 = mat3_mul(_tgt, mat3_transpose(_c1)), _r2 = mat3_mul(_tgt, mat3_transpose(_c2));
	return ((_r1[0] + _r1[4] + _r1[8]) >= (_r2[0] + _r2[4] + _r2[8])) ? _c1 : _c2;
};
/// a region's spot as the turntable's yaw / pitch (its direction in the axis frame, the spin in;
/// the camera's own direction there is (-sin yaw cos pitch, sin pitch, cos yaw cos pitch))
__spot_yp = function(_pn, _spin, _rg) {
	var _t = __spot_dir(_rg.spot.lon, _rg.spot.lat);
	var _a = mat3_apply(mat3_rot(0, 1, 0, _spin), _t[0], _t[1], _t[2]);
	return { yaw : darctan2(-_a[0], _a[2]), pitch : darcsin(clamp(_a[1], -1, 1)) };
};
/// a world small (the hub's card, the list's rows, the haul's card): the
/// FULL world once it is built - clouds and ring (the globe at .62 so the
/// ring fits) - the lite portrait until then (his ask: every version
/// shows clouds). The caller has the fade off (the shader replaces it)
__world_small = function(_d, _cx, _cy, _r, _rg = undefined) {
	var _pn = planet_get(_d.seed, exped_planet_hint(_d));
	if (_pn.row >= _pn.th && (_pn[$ "brow"] ?? 0) >= 3 * _pn.th) {   // (built and baked - the small world too, bug hunt 2026-09-16)
		// FACING ITS REGION when the card is about one (his ask, 2026-09-15): the
		// spot dead on, the clock's spin under it (the terminator moves, the region holds)
		if (is_struct(_rg)) { var _sp = planet_spin_now(_pn); planet_draw(_pn, _cx, _cy, _pn.ring ? (_r * .62) : _r, _sp, 1, __cam_at(_pn, _sp, _rg), __sky_for(_d).light_w); }
		else planet_draw(_pn, _cx, _cy, _pn.ring ? (_r * .62) : _r);
	}
	else __portrait(_d, _cx, _cy, _r);
};
/// the worlds are built a few rows a frame (planet_gen_step): the board's,
/// the trips' and the planet window's - one of them a frame, so every
/// portrait gets its full world within a second or two
__worlds_step = function() {
	var _e = g.exped;
	// ONLY THE WORLD ON THE PAGE builds (his report, 2026-09-16: every opened world building at once lagged the first look):
	// the planet page's, a trip's or a haul's while its page shows - each on its first look, the boot's is the home world
	var _list = [];
	if (is_struct(pl_dest)) array_push(_list, pl_dest);
	if (view == "trip") { var _wt = __trip(); if (!is_undefined(_wt)) array_push(_list, _wt.dest); }
	if (view == "haul") { var _wh = __haul_i(); if (_wh >= 0) array_push(_list, _e.hauls[_wh].dest); }
	for (var _i = 0; _i < array_length(_list); _i++) {
		var _pn = planet_get(_list[_i].seed, exped_planet_hint(_list[_i]));
		if (!planet_lite_ready(_pn)) { planet_build_step(_pn, get_timer() + 4000, 6); return; }   // (six rows a frame - a fresh world in a quarter second - then its sheets four ms a frame: the one builder's step, q225)
	}
};
// THE ZOOM TIER (his call, 2026-09-17: "LOD triggers based off zoom distance, not camera movement"): the WHOLE
// map at 3x its resolution (planet_lod_begin / planet_lod_step - the base map's fields blended between its texels
// on a smooth kernel, the biome law run on them; k odd, so the base texels' own centres are exact), built once
// for the page's world, AHEAD, as soon as its base map stands, and kept while the page shows it. It shows from
// region mode's own zoom (PV_ZOOM_RG - his ask) and any wheel zoom past it.
// Nothing about the camera. Under the camera's hand the build takes a smaller slice (q202a). A tier whose textures
// the gpu dropped (the window going full screen) is re-uploaded from its kept buffers. A NEW world's tier builds
// under the page's loading veil (q202: the world arrives finished - no pop-in anywhere on it); tiers are KEPT
// (TierKeep's keep, four of them) so a world seen before has its tier at once
// (the tiers' keeping, building and re-uploading are TierKeep's; the panel keeps only the question the zoom answers)
__lod_drop = function() { tiers.drop(); };
__lod_free_all = function() { tiers.free_all(); };
__lod_ready = function(_pn) { return tiers.ready(_pn); };
__lod_want = function() {   // the tier the zoom asks for: 0 or 3
	if (view != "planet" || !is_struct(pl_dest)) return 0;
	// FROM THE REGION VIEW'S OWN ZOOM (his ask, 2026-09-17: "trigger at the zoom level where viewing a region settles"):
	// region mode's pull-in is the tier's threshold - the map's texels are already cell-sized there and the tier's
	// three-to-one resolves the coasts at the cell; the wheel past it keeps it
	var _zt = pv_zuser * ((pv_mode == "region") ? PV_ZOOM_RG : 1);
	return (_zt >= 1.83) ? 3 : 0;   // (the tier's own threshold - the old region pull-in's; the region zoom went to x5 (q269) and the tier is wanted well before that)
};
__lod_pick = function(_pn) { return tiers.pick(_pn, __lod_want() >= 3); };
/// THE BACKGROUND SHARE (q256): the slice any page other than the planet's gives the pending build - a share of the
/// frame whatever the refresh rate (delta = the frame in sixtieths): thirty-five hundredths, 1.2 to 5 ms - a frame is
/// never dropped for it, and the crew page is a place to wait
__bg_lim = function() { return get_timer() + clamp(delta * 16667 * .35, 1200, 5000); };
__lod_step = function() {
	// THE TRIP PAGE (q268): its region box shows the TRIP's world close - that world's tier is the one to build there
	var _lw = pl_dest;
	if (view == "trip") { var _ltr = __trip(); if (!is_undefined(_ltr) && is_struct(_ltr[$ "dest"])) _lw = _ltr.dest; }
	if (!is_struct(_lw)) { tiers.drop(); lod_fade = 0; return; }
	var _pn = planet_get(_lw.seed, exped_planet_hint(_lw));
	// THE FOCUS (q270): the map v the camera looks at - the region's spot in region mode and on the trip page, the equator else
	var _lfv = .5;
	if (view == "trip") { var _ltr2 = __trip(); if (!is_undefined(_ltr2)) { var _lrg2 = exped_region(_ltr2); if (is_struct(_lrg2[$ "spot"])) _lfv = (90 - _lrg2.spot.lat) / 180; } }
	else if (pl_focus >= 0) { var _lrg3 = region_get(_lw, pl_focus); if (is_struct(_lrg3[$ "spot"])) _lfv = (90 - _lrg3.spot.lat) / 180; }
	if (view == "trip") { tiers.step(_pn, false, undefined, _lfv); lod_fade = 1; return; }
	// THE TIER BEHIND EVERY PAGE (q256; his ask: "remove stutter so I can look at the crew stats while I wait"): the
	// page's world's tier keeps building on any page at the background share (it used to drop off the planet page and
	// wait); on the planet page its own slices as before
	if (view != "planet") { tiers.step(_pn, false, __bg_lim(), _lfv); lod_fade = 0; return; }
	tiers.step(_pn, (pv_drag || pv_face >= 0 || abs(pv_vx) > .1 || abs(pv_vy) > .1), undefined, _lfv);   // (a smaller slice under the camera's hand - q202a; the focus - q270)
	// THE FADE (q256): the veil no longer waits for the tier (his call) - a tier that lands under the view eases in
	// over four tenths of a second through the shader's u_pfade; a tier that has faded once (its own flag, kept with
	// it) shows whole at once, so zooming out and in never re-fades
	var _pk = tiers.pick(_pn, __lod_want() >= 3);
	if (!is_struct(_pk)) { lod_fade = 0; return; }
	if (_pk[$ "faded"] ?? false) { lod_fade = 1; return; }
	lod_fade = min(1, lod_fade + delta / 24);
	if (lod_fade >= 1) _pk.faded = true;
};
/// THE BUILD BEHIND THE SPRITE MENU (q256): the pending world (the sheet first - it is the veil's gate), then its
/// tier, then a system page's stamps, at the background share - nothing here shows a world, so the share is all it costs
__bg_step = function() {
	if (!galaxy_ready()) return;
	var _lim = __bg_lim();
	if (is_struct(pl_dest)) {
		var _pn = planet_get(pl_dest.seed, exped_planet_hint(pl_dest));
		if (!planet_lite_ready(_pn)) { planet_build_step(_pn, _lim); return; }
		tiers.step(_pn, false, _lim);
		if (get_timer() >= _lim) return;
	}
	if (is_array(sy_pd) && array_length(sy_pd) > 0) planet_lite_step_list(sy_pd, max(0, _lim - get_timer()));
};
}
