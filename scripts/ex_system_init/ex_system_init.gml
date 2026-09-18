/// @description ex_system_init() - THE STAR SYSTEM VIEW and THE STATION PAGE of syst_exped_panel: their state and their methods, defined on the panel (self = the panel; called from its Create). q217, the deconvolution: the view's code in its own files - ex_system_init / ex_system_step / ex_station_step / ex_system_press / ex_system_draw / ex_station_draw - the panel dispatches
/// (Every variable and method here is the panel's, as before: sy_* the
/// system view, st_* the station page, __sy_* / __st_* / __rock_draw /
/// __draw_system / __draw_station their methods. A function literal made
/// here is bound to the panel, the caller.)
function ex_system_init() {
// THE STAR SYSTEM VIEW (his ask, 2026-09-16: the tech demo's, ported whole): orbits in the GALACTIC plane (world y = 0,
// the plane the sky's milky way lives in), a camera that orbits the star like the orbit view's orbits the world (drag +
// glide, wheel = distance), the planets as real sh_planet mini worlds (planet_get_lite: the same generation at 48x24),
// rings, their REAL moons (planet_moons) at their true phases, lit from the star by their true bearing, spinning by
// the universal clock; the local star's own sky behind (galaxy_sky_build for the star, no sun, no siblings); a tap
// picks (a pulsing box, the card), [enter] dives (the swell, then the world's page); a dock on the right: the star's
// numbers, the worlds listed
sy_star = -1; sy_sys = undefined; sy_sel = -1; sy_dest = undefined; sy_from = "galaxy";   // (sy_from: where [back] returns - the map, or the planet page)
sy_cam = mat3_rot(1, 0, 0, -55); sy_D = 250; sy_F = 230;
sy_drag = false; sy_drag_px = 0; sy_dx = 0; sy_dy = 0; sy_vx = 0; sy_vy = 0;
sy_warp_pl = -1; sy_warp_s = 1; sy_warp_t = 0; sy_wfx = 0; sy_wfy = 0;
sy_pd = [];                          // the lite worlds, one a planet (planet_get_lite - begun on entry, built a slice a frame: __sy_lite_step)
/// THE STAMPS' BUILDER (q201; his report: "a hitch when hitting view starmap" - eight worlds sampled and baked whole in
/// __sy_enter, a quarter second in one frame): the first unfinished world takes three milliseconds a frame - rows of
/// samples (planet_gen_step), then its textures (planet_bake with the deadline) - and stands within a few frames; the
/// painter draws a plain ball in the world's colour until then. The cache keeps the finished ones: the next visit costs nothing
__sy_lite_step = function() { planet_lite_step_list(sy_pd, 3000); };   // (the builder is planet_lite_step_list's - q216)
sy_stns = [];                        // THE STAR'S SPACE STATIONS (station_sys, 2026-09-17): on their own rings, picked like a world
sy_belts = [];                       // THE ASTEROID BELTS (belt_sys, 2026-09-17): a crowd of rocks on a band, turning
sy_bsel = -1;                        // the belt tapped (its name in the caption, its row lit - nothing to enter)
sy_ssel = -1;                        // the picked station (-1 none; a station and a world are never both picked)
sy_warp_st = -1;                     // the dive, to a station (its page)
st_sel = -1;                         // THE STATION PAGE: which of sy_stns; its own camera and spin
st_cam = mat3_rot(1, 0, 0, -20); st_drag = false; st_drag_px = 0; st_dx = 0; st_dy = 0; st_vx = 0; st_vy = 0;
st_yaw = 0; st_pitch = -20;          // A TURNTABLE (his report, 2026-09-17: "it kinda skews when i rotate it" - a free arcball rolls; yaw and pitch never do)
__st_ppos = function(_st) { var _a = (_st.ang + _st.spd * 60 * universal_now()) mod 360; return [dcos(_a) * _st.orbit, 0, dsin(_a) * _st.orbit, _a]; };
sy_moons = [];                       // ...and their moons (planet_moons)
sy_info = [];                        // ...and their tiers (galaxy_world)
sy_cx = 0; sy_cy = 0;                // the projection's centre on the page
sy_dw = false; sy_dwa = 0;           // THE DOCK AS A DRAWER (his ask, 2026-09-16: the planet page's tab - the view slides left as it opens)
__sy_dock_w = function() { return land ? 150 : 110; };
__sy_dock_x = function() { return room_width - 9 - __sy_dock_w() * sy_dwa; };   // (the drawer's left edge: its tab when shut)
__sy_tab_r  = function() { return { x : __sy_dock_x(), y : list_y + 22, w : 9, h : 60 }; };
__sy_enter_r = function() { return { x : room_width - (land ? 14 : 4) - 80, y : room_height - 8 - 16, w : 80, h : 16 }; };   // [enter] bottom right while the drawer is shut
__sy_box_r  = function() { var _x = __sy_dock_x() + 9; return { x : _x, y : list_y + 16, w : room_width - _x, h : 54 }; };   // the star's numbers (the drawer's box runs to the edge)
__sy_row_r  = function(_i) { var _x = __sy_dock_x() + 13; return { x : _x, y : list_y + 16 + 58 + _i * 24, w : room_width - _x - 4, h : 22 }; };
__sy_open_r = function() { var _x = __sy_dock_x() + 13; return { x : _x, y : room_height - 8 - 16, w : room_width - _x - 4, h : 16 }; };
__sy_view_r = function() { return { x : 0, y : list_y, w : room_width, h : room_height - list_y }; };
/// one rock of a belt on the page (the polish, 2026-09-17): [sx, sy, k, b, belt, size, glint] under the swell - its size in cells, its glint a white flare over it
__rock_draw = function(_r, _s) {
	var _rx = floor(sy_wfx + (_r[0] - sy_wfx) * _s), _ry = floor(sy_wfy + (_r[1] - sy_wfy) * _s), _sz = _r[5];
	var _bl = sy_belts[_r[4]], _col = (sy_bsel == _r[4]) ? merge_colour(_bl.col, c_gold, .35) : _bl.col;
	draw_sprite_ext(spr_pixel_1x1, 0, _rx - (_sz div 2), _ry - (_sz div 2), _sz, _sz, 0, _col, clamp(_r[3] * (.35 + .65 * min(1, _r[2] * _s * 1.1)), .12, .95));
	if (_r[6] > 0) draw_sprite_ext(spr_pixel_1x1, 0, _rx - 1, _ry - 1, 3, 3, 0, c_white, _r[6] * .85);
};
/// world -> page: [sx, sy, scale, depth], or undefined when behind the camera
__sy_proj = function(_wx, _wy, _wz) {
	var _v = mat3_apply(mat3_transpose(sy_cam), _wx, _wy, _wz);
	var _dz = sy_D - _v[2];
	if (_dz < 24) return undefined;
	var _k = sy_F / _dz;
	return [sy_cx + _v[0] * _k, sy_cy + _v[1] * _k, _k, _dz];
};
/// a planet's world position on its orbit NOW (the universal clock)
__sy_ppos = function(_p) { var _a = (_p.ang + _p.spd * 60 * universal_now()) mod 360; return [dcos(_a) * _p.orbit, 0, dsin(_a) * _p.orbit, _a]; };
/// into a star's system: the system, the lite worlds, their moons, the tiers, the camera fresh
__sy_enter = function(_star) {
	var _sm = starmap_get();
	if (_star < 0 || _star >= _sm.count) return;
	sy_star = _star;
	sy_sys = starsystem_get(_sm.stars[_star].seed, _sm.stars[_star].props);   // (kept by seed - q212)
	sy_sel = -1; sy_pd = []; sy_moons = []; sy_info = [];
	sy_stns = station_sys(_sm.stars[_star].seed, sy_sys); sy_ssel = -1; sy_warp_st = -1;   // (the star's stations, 2026-09-17)
	sy_belts = belt_sys(_sm.stars[_star].seed, sy_sys, sy_stns); sy_bsel = -1;   // (its belts, in the gaps the stations left)
	var _hm = galaxy_home();
	for (var _i = 0; _i < array_length(sy_sys.planets); _i++) {
		var _p = sy_sys.planets[_i];
		var _gw = galaxy_world(_star, _i);
		var _hint = is_struct(_gw) ? exped_planet_hint(_gw) : { kind : _p.kind, clim : _p.clim, ring : (_p[$ "has_ring"] ?? false) };
		array_push(sy_pd, planet_get_lite(_p.seed, _hint, false));   // (begun here, built a slice a frame by __sy_lite_step - q201: the whole build was the hitch on [star system])
		array_push(sy_moons, planet_moons(_p.seed));
		array_push(sy_info, is_struct(_gw) ? _gw.tier : 0);
		if (is_struct(pl_dest) && pl_dest.seed == _p.seed) sy_sel = _i;
	}
	if (sy_sel < 0 && _star == _hm.star) sy_sel = _hm.planet;
	// the sky's world: the one we came from when it is of this star - its sky is built and its holes baked already, and the
	// system page draws no sun and no siblings, so nothing of it is the wrong planet's (q200; his question: "are you rebaking
	// the skybox?" - the stand-in below was planets[0], a different cache key from any other world's, so yes, it was);
	// else a stand-in world of this star (the sky builder wants one)
	sy_dest = (sy_sel >= 0 && is_struct(pl_dest) && pl_dest.seed == sy_sys.planets[sy_sel].seed) ? pl_dest : { seed : sy_sys.planets[0].seed, star : _star, pl : 0 };
	sy_cam = mat3_rot(1, 0, 0, -55); sy_D = 250; sy_vx = 0; sy_vy = 0; sy_drag = false; sy_dw = false; sy_dwa = 0;
	sy_warp_pl = -1; sy_warp_s = 1; sy_warp_t = 0;
};
/// THE STATION PAGE (2026-09-17, his ask: "click on one like I do a planet to
/// zoom in on it"): the system's sky behind, the station large in the
/// middle - its solid, lit by its star - turning under its own spin and the
/// drag's; the card bottom left says what it is
__draw_station = function() {
	var _vr = __sy_view_r();
	var _w = room_width, _h = room_height - list_y;
	if (!surface_exists(wb_surf) || surface_get_width(wb_surf) != _w || surface_get_height(wb_surf) != _h) { if (surface_exists(wb_surf)) surface_free(wb_surf); wb_surf = page_surface(_w, _h); }
	if (!surface_exists(sky_fog_surf) || surface_get_width(sky_fog_surf) != _w || surface_get_height(sky_fog_surf) != _h) { if (surface_exists(sky_fog_surf)) surface_free(sky_fog_surf); sky_fog_surf = surface_create(_w, _h); }
	var _st = sy_stns[st_sel];
	var _cx = room_width * .5, _cy = _vr.h * .5;
	var _sky = __sky_for(sy_dest);
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	surface_set_target(wb_surf);
	draw_clear_alpha(c_black, 1);
	galaxy_sky_draw(_sky, st_cam, _cx, _cy, _w, _h, false, false);
	galaxy_fog_draw(_sky, st_cam, _cx, _cy, _w, _h, sky_fog_surf, false);
	galaxy_sky_holes(_sky, st_cam, _cx, _cy, _w, _h, false);   // (the holes over the fog - 2026-09-17)
	// lit from its star: from where it stands on its ring, the star is at the origin
	var _pp = __st_ppos(_st);
	var _lw = [-dcos(_pp[3]), .15, -dsin(_pp[3])];
	g.dither_off = page_float();
	station_render(_st, _cx, _cy, min(_w, _h) * .27, st_cam, _lw);
	g.dither_off = false;
	surface_reset_target();
	ui_fade_set(_fa);
	page_blit(wb_surf, 0, list_y);
};
/// the star system page painted into the page surface: the star's sky, the rings, the star and the worlds far to near
__draw_system = function() {
	var _vr = __sy_view_r();
	var _w = room_width, _h = room_height - list_y;
	if (!surface_exists(wb_surf) || surface_get_width(wb_surf) != _w || surface_get_height(wb_surf) != _h) { if (surface_exists(wb_surf)) surface_free(wb_surf); wb_surf = page_surface(_w, _h); }
	if (!surface_exists(sky_fog_surf) || surface_get_width(sky_fog_surf) != _w || surface_get_height(sky_fog_surf) != _h) { if (surface_exists(sky_fog_surf)) surface_free(sky_fog_surf); sky_fog_surf = surface_create(_w, _h); }
	sy_cx = room_width * .5 - __sy_dock_w() * sy_dwa * .5; sy_cy = _vr.h * .52;   // (page space: centred, slid left as the drawer opens)
	var _sky = __sky_for(sy_dest);
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	surface_set_target(wb_surf);
	draw_clear_alpha(c_black, 1);
	galaxy_sky_draw(_sky, sy_cam, sy_cx, sy_cy, _w, _h, false, false);
	galaxy_fog_draw(_sky, sy_cam, sy_cx, sy_cy, _w, _h, sky_fog_surf, false);   // (no sun on this sky: the star is drawn as itself)
	galaxy_sky_holes(_sky, sy_cam, sy_cx, sy_cy, _w, _h, false);   // (the neighbours' holes over the fog - 2026-09-17)
	var _pls = sy_sys.planets, _np = array_length(_pls), _s = sy_warp_s;
	var _cfgp = planet_config(), _pxs = max(1, _cfgp.px_size);
	// the dive's focus: the picked world's spot anchors the swell
	sy_wfx = sy_cx; sy_wfy = sy_cy;
	if (sy_warp_pl >= 0) { var _fpp0 = __sy_ppos(_pls[sy_warp_pl]); var _fpp = __sy_proj(_fpp0[0], 0, _fpp0[2]); if (!is_undefined(_fpp)) { sy_wfx = _fpp[0]; sy_wfy = _fpp[1]; } }
	if (sy_warp_st >= 0) { var _fsp0 = __st_ppos(sy_stns[sy_warp_st]); var _fsp = __sy_proj(_fsp0[0], 0, _fsp0[2]); if (!is_undefined(_fsp)) { sy_wfx = _fsp[0]; sy_wfy = _fsp[1]; } }   // (the dive to a station - 2026-09-17)
	// the star's place and depth first: the rings split at it (q195 - the near half of a ring passes IN FRONT of the star:
	// its cells wait and are drawn right after the star; a great star's disc hid them)
	var _sp0 = __sy_proj(0, 0, 0), _sdz = is_undefined(_sp0) ? sy_D : _sp0[3], _rc_near = [];
	// the orbit rings: true circles in the plane, as grid-snapped cells (the demo's)
	for (var _i = 0; _i < _np; _i++) {
		var _or = _pls[_i].orbit, _stp = max(.4, _pxs * 55 / max(1, _or)), _lcx = -10000, _lcy = -10000;
		for (var _a = 0; _a < 360; _a += _stp) {
			var _rp = __sy_proj(dcos(_a) * _or, 0, dsin(_a) * _or);
			if (is_undefined(_rp)) continue;
			var _gx = floor((sy_wfx + (_rp[0] - sy_wfx) * _s) / _pxs) * _pxs, _gy = floor((sy_wfy + (_rp[1] - sy_wfy) * _s) / _pxs) * _pxs;
			if (_gx == _lcx && _gy == _lcy) continue;
			_lcx = _gx; _lcy = _gy;
			if (_rp[3] < _sdz && !is_undefined(_sp0)) array_push(_rc_near, [_gx, _gy, (sy_sel == _i) ? c_gold : c_white, (sy_sel == _i) ? .3 : .14]);
			else draw_sprite_ext(spr_pixel_1x1, 0, _gx, _gy, _pxs, _pxs, 0, (sy_sel == _i) ? c_gold : c_white, (sy_sel == _i) ? .3 : .14);
		}
	}
	// THE STATIONS' RINGS (2026-09-17): dashed, in the hull's colour - one in twelve cells, so a world's ring and a station's read apart
	for (var _j = 0; _j < array_length(sy_stns); _j++) {
		var _sor = sy_stns[_j].orbit, _sstp = max(.4, _pxs * 55 / max(1, _sor)), _slcx = -10000, _slcy = -10000, _dash = 0;
		for (var _a = 0; _a < 360; _a += _sstp) {
			var _srp = __sy_proj(dcos(_a) * _sor, 0, dsin(_a) * _sor);
			if (is_undefined(_srp)) continue;
			var _sgx = floor((sy_wfx + (_srp[0] - sy_wfx) * _s) / _pxs) * _pxs, _sgy = floor((sy_wfy + (_srp[1] - sy_wfy) * _s) / _pxs) * _pxs;
			if (_sgx == _slcx && _sgy == _slcy) continue;
			_slcx = _sgx; _slcy = _sgy; _dash++;
			if ((_dash mod 3) != 0) continue;
			if (_srp[3] < _sdz && !is_undefined(_sp0)) array_push(_rc_near, [_sgx, _sgy, (sy_ssel == _j) ? c_gold : sy_stns[_j].hull, (sy_ssel == _j) ? .4 : .22]);
			else draw_sprite_ext(spr_pixel_1x1, 0, _sgx, _sgy, _pxs, _pxs, 0, (sy_ssel == _j) ? c_gold : sy_stns[_j].hull, (sy_ssel == _j) ? .4 : .22);
		}
	}
	// z-sort the star, the worlds and the stations, far to near (a station is item 1000 + its index)
	var _items = [];
	if (!is_undefined(_sp0)) array_push(_items, [_sp0[3], -1, _sp0[0], _sp0[1], _sp0[2]]);
	for (var _i = 0; _i < _np; _i++) { var _pp0 = __sy_ppos(_pls[_i]); var _pp = __sy_proj(_pp0[0], 0, _pp0[2]); if (!is_undefined(_pp)) array_push(_items, [_pp[3], _i, _pp[0], _pp[1], _pp[2]]); }
	for (var _j = 0; _j < array_length(sy_stns); _j++) { var _sq0 = __st_ppos(sy_stns[_j]); var _sq = __sy_proj(_sq0[0], 0, _sq0[2]); if (!is_undefined(_sq)) array_push(_items, [_sq[3], 1000 + _j, _sq[0], _sq[1], _sq[2]]); }
	// THE BELTS' ROCKS (2026-09-17): every rock where it stands now - NOT in the sort (five hundred of them, sorted
	// every frame, would be the cost): split at the star's depth, the far half painted before everything, the
	// near half after (a rock over a far world reads right; a rock behind the star but before a farther world is a pixel wrong)
	var _bnow = universal_now(), _rk_far = [], _rk_near = [];
	var _gslot = floor(_bnow / .45), _gfr = frac(_bnow / .45);   // THE GLINTS' clock: a slot a little under half a second (each rock its own phase below)
	for (var _b = 0; _b < array_length(sy_belts); _b++) {
		var _bl = sy_belts[_b], _rks = _bl.rocks;
		// THE DUST (the polish, 2026-09-17; a haze since the same day - three faint rings read as three more orbits, his report):
		// scattered specks across the band, very faint, brighter nearer, gold-tinted when the belt is picked
		var _dcol = (sy_bsel == _b) ? merge_colour(_bl.col, c_gold, .5) : _bl.col, _dsts = _bl.dust;
		for (var _di = 0; _di < array_length(_dsts); _di++) {
			var _dd = _dsts[_di], _da = (_dd[1] + _bl.dspd * 60 * _bnow) mod 360;
			var _dp = __sy_proj(dcos(_da) * _dd[0], _dd[2], dsin(_da) * _dd[0]);
			if (is_undefined(_dp)) continue;
			draw_sprite_ext(spr_pixel_1x1, 0, floor(sy_wfx + (_dp[0] - sy_wfx) * _s), floor(sy_wfy + (_dp[1] - sy_wfy) * _s), 1, 1, 0, _dcol, ((sy_bsel == _b) ? .14 : .06) * _dd[3] * (.5 + .5 * min(1, _dp[2] * _s * 1.1)));
		}
		for (var _k = 0; _k < array_length(_rks); _k++) {
			var _rk = _rks[_k], _ra = (_rk[1] + _rk[4] * 60 * _bnow) mod 360;
			var _rp = __sy_proj(dcos(_ra) * _rk[0], _rk[2], dsin(_ra) * _rk[0]);
			if (is_undefined(_rp)) continue;
			// A GLINT (the polish): a facet catching the star - a hash per rock per slot, the odd one flares and decays through its slot
			var _gl = 0;
			if (_rk[3] > .55) { var _gph = floor((_bnow + _k * .173) / .45), _gr = hash_mix(_k * 31 + _b * 977, _gph) mod 1000; if (_gr > 993) _gl = power(1 - frac((_bnow + _k * .173) / .45), 2.5); }
			array_push((_rp[3] > _sdz) ? _rk_far : _rk_near, [_rp[0], _rp[1], _rp[2], _rk[3], _b, _rk[5], _gl]);
		}
		// THE BIG ONES: into the sort with the worlds and the stations (item 3000 + belt x 8 + which)
		for (var _bi = 0; _bi < array_length(_bl.bigs); _bi++) {
			var _bg = _bl.bigs[_bi], _ba = (_bg.a0 + _bg.spd * 60 * _bnow) mod 360;
			var _bp = __sy_proj(dcos(_ba) * _bg.r, _bg.y, dsin(_ba) * _bg.r);
			if (!is_undefined(_bp)) array_push(_items, [_bp[3], 3000 + _b * 8 + _bi, _bp[0], _bp[1], _bp[2]]);
		}
	}
	for (var _k = 0; _k < array_length(_rk_far); _k++) __rock_draw(_rk_far[_k], _s);
	array_sort(_items, function(_a, _b) { return _b[0] - _a[0]; });
	g.dither_off = page_float();
	for (var _n = 0; _n < array_length(_items); _n++) {
		var _it = _items[_n];
		var _sx = sy_wfx + (_it[2] - sy_wfx) * _s, _sy = sy_wfy + (_it[3] - sy_wfy) * _s, _k = _it[4] * _s;
		if (_it[1] < 0) {
			// the star: sh_star (star_draw, 2026-09-16) - the disc, its corona and prominences; the same star its worlds' skies show
			var _stc = sy_sys.star.col, _ss = sy_sys.star.size * _k / 12;
			if (sy_sys.star[$ "hole"] ?? false) hole_draw(_sx, _sy, 6 * _ss, _stc, sy_star * .37, 1, sy_cam);   // (a black hole: hole_draw bends the sky already on the page - 2026-09-17)
			else {
				star_draw(_sx, _sy, 6 * _ss, _stc, sy_star * .37, 1, sy_cam);
				var _skd2 = sy_sys.star[$ "skind"] ?? "main";
				if (_skd2 == "pulsar") pulsar_draw(_sx, _sy, 6 * _ss, _stc, sy_star * .37, sy_sys.star.spin, sy_sys.star.tilt, 1, sy_cam);   // (the beams over it, held to the world - 2026-09-17)
				else if (_skd2 == "dwarf") dwarf_draw(_sx, _sy, 6 * _ss, _stc, 1);   // (a white dwarf's blaze - his ask, q195)
			}
			// the rings' near halves, over the star (their far halves went under everything)
			for (var _rc = 0; _rc < array_length(_rc_near); _rc++) { var _rcc = _rc_near[_rc]; draw_sprite_ext(spr_pixel_1x1, 0, _rcc[0], _rcc[1], _pxs, _pxs, 0, _rcc[2], _rcc[3]); }
		} else if (_it[1] >= 3000) {
			// A BIG ROCK of a belt (the polish, 2026-09-17): a small tumbling solid, lit from the star
			var _bb = sy_belts[(_it[1] - 3000) div 8].bigs[(_it[1] - 3000) mod 8], _bba = (_bb.a0 + _bb.spd * 60 * _bnow) mod 360;
			station_render(_bb.st, _sx, _sy, max(1.5, _bb.size * _k * 1.2), sy_cam, [-dcos(_bba), 0, -dsin(_bba)], (_bnow * 60 * _bb.st.spin) mod 360);
		} else if (_it[1] >= 1000) {
			// A STATION on its ring (2026-09-17): its solid, lit from the star; picked = the pulsing box, like a world's
			var _j = _it[1] - 1000, _stj = sy_stns[_j], _sq1 = __st_ppos(_stj);
			var _srad = max(2, _stj.size * _k * 1.2);
			var _svv = mat3_apply(mat3_transpose(sy_cam), _sq1[0], _sq1[1], _sq1[2]);   // (the eye sits at view z = sy_D: the ray toward it - no shear off the centre)
			station_render(_stj, _sx, _sy, _srad, sy_cam, [-dcos(_sq1[3]), 0, -dsin(_sq1[3])], undefined, [_svv[0], _svv[1], _svv[2] - sy_D]);
			if (sy_ssel == _j && sy_warp_pl < 0 && sy_warp_st < 0) { var _mr3 = _srad * 1.7 + 3 + dsin(current_time * .25) * 1.2; draw_px_rect(_sx - _mr3, _sy - _mr3, _mr3 * 2, _mr3 * 2, c_white, .8); }
		} else {
			var _i = _it[1], _p = _pls[_i], _pd = sy_pd[_i];
			var _pw = __sy_ppos(_p);
			var _rad = max(1.5, _p.size * _k * 1.2);
			// lit from the star: toward the origin from the world, in the plane (world space - planet_draw turns it through the camera);
			// a world still building (q201) is a plain ball in its colour, its edge dark, until its textures stand
			if (planet_lite_ready(_pd)) planet_draw(_pd, _sx, _sy, _rad, undefined, 1, sy_cam, [-dcos(_pw[3]), 0, -dsin(_pw[3])]);
			else { draw_set_circle_precision(32); draw_circle_colour(_sx, _sy, _rad, _p.col, merge_colour(_p.col, c_black, .65), false); draw_set_circle_precision(24); }
			// its moons at their true phases, as the demo drew them: pixel dots on the plane
			var _mns = sy_moons[_i], _mn = min(4, _p[$ "moon_n"] ?? 0);
			for (var _m = 0; _m < _mn; _m++) {
				var _mo = _mns[_m];
				var _ma = _mo.ang + _mo.spd * 60 * universal_now(), _mr = _p.size * _mo.dist;
				var _mp = __sy_proj(_pw[0] + dcos(_ma) * _mr, 0, _pw[2] + dsin(_ma) * _mr);
				if (is_undefined(_mp)) continue;
				var _mx = sy_wfx + (_mp[0] - sy_wfx) * _s, _my = sy_wfy + (_mp[1] - sy_wfy) * _s, _ms = max(1, _mo.size * _p.size * 2 * _mp[2] * _s);
				draw_sprite_ext(spr_pixel_1x1, 0, _mx - _ms * .5, _my - _ms * .5, _ms, _ms, 0, _mo.col, .9);
			}
			// picked: the pulsing box (no mark for the opened ones - his call, 2026-09-16: the worlds need not know they have been)
			if (sy_sel == _i && sy_warp_pl < 0) { var _mr2 = _rad * 1.7 + 3 + dsin(current_time * .25) * 1.2; draw_px_rect(_sx - _mr2, _sy - _mr2, _mr2 * 2, _mr2 * 2, c_white, .8); }
			// "you": the world the panel stands on (the home world when nothing does)
			var _here = is_struct(pl_dest) ? (pl_dest.seed == _p.seed) : (galaxy_home().planet_seed == _p.seed);
			if (_here && sy_warp_pl < 0) {
				var _bob = abs(dsin(current_time * .25)) * 3, _ty = floor(_sy - _rad - 6 - _bob);
				draw_sprite_ext(spr_pixel_1x1, 0, floor(_sx) - 3, _ty - 3, 7, 1, 0, c_sgreen, .95); draw_sprite_ext(spr_pixel_1x1, 0, floor(_sx) - 2, _ty - 2, 5, 1, 0, c_sgreen, .95); draw_sprite_ext(spr_pixel_1x1, 0, floor(_sx) - 1, _ty - 1, 3, 1, 0, c_sgreen, .95); draw_sprite_ext(spr_pixel_1x1, 0, floor(_sx), _ty, 1, 1, 0, c_sgreen, .95);
				draw_set_halign(fa_center); draw_set_color(c_sgreen); draw_set_alpha(.95); draw_text(floor(_sx), _ty - 13, "you"); draw_set_halign(fa_left); draw_set_alpha(1);   // (the alpha put back - it leaked .95 into every later draw that reads it; bug hunt 2026-09-18)
			}
		}
	}
	// ...the near half of the belts' rocks, over everything
	for (var _k = 0; _k < array_length(_rk_near); _k++) __rock_draw(_rk_near[_k], _s);
	g.dither_off = false;
	surface_reset_target();
	ui_fade_set(_fa);
	page_blit(wb_surf, 0, list_y);
};
}
