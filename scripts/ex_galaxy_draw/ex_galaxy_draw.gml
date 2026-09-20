/// @description ex_galaxy_draw(ea, dim) -> true when the page is drawn (the old exit): THE GALAXY page - the parallax backdrop, the stars and their kinds, the fog, the holes over it, the marks, the minimap, [enter] (syst_exped_panel's Draw, q218; self = the panel; ea / dim the event's ease and colour)
function ex_galaxy_draw(_ea, _dim) {
	var _gcf = starmap_config();
	var _sm = starmap_get();
	var _hm = galaxy_home();
	var _gr = __gx_r();
	var _vw = _gr.w, _vh = _gr.h;
	// AT THE WINDOW'S RESOLUTION (his ask, 2026-09-16: the demo's map is smooth; ours snapped to the room's pixels - the page was
	// a room-sized surface): the page is drawn gs times over and blitted back down, so a star sits between the room's pixels
	var _gs = max(1, floor(surface_get_width(application_surface) / max(1, room_width)));
	var _vws = _vw * _gs, _vhs = _vh * _gs;
	if (!gx_init) { gx_init = true; gx_zoom = 1; gx_x = _sm.stars[_hm.star].x - _vw * .5; gx_y = _sm.stars[_hm.star].y - _vh * .5; }
	if (array_length(gx_para) == 0) {
		var _tw = _vw + 200, _th = _vh + 200;
		for (var _l = 0; _l < _gcf.para_layers; _l++) {
			var _lst = [];
			repeat (_gcf.para_stars) array_push(_lst, { x : random(_tw), y : random(_th), col : choose(rgb(150, 160, 190), rgb(150, 160, 190), rgb(190, 170, 150)), a : .08 + .07 * _l + random(.06) });
			array_push(gx_para, { f : .15 + .175 * _l, tw : _tw, th : _th, stars : _lst });
		}
	}
	// (the fade off before anything bakes: a sheet baked under the open
	// animation's fade shader would keep that alpha for good)
	var _fa = g.ui_fade_a;
	ui_fade_set(1);
	// the fog sheet: the density grid baked once a galaxy (galaxy_neb_sheet - the skies read the same sheet, 2026-09-16)
	var _gxf = galaxy_neb_sheet();
	if (!surface_exists(wb_surf) || surface_get_width(wb_surf) != _vws || surface_get_height(wb_surf) != _vhs) {
		if (surface_exists(wb_surf)) surface_free(wb_surf);
		wb_surf = page_surface(_vws, _vhs);
	}
	surface_set_target(wb_surf);
	draw_clear_alpha(c_black, 1);
	draw_set_alpha(1);
	// the parallax backdrop: wrapped tiles panning slower than the plane
	for (var _l = 0; _l < array_length(gx_para); _l++) {
		var _pl = gx_para[_l];
		var _lz = lerp(1, gx_zoom, _pl.f);
		var _twz = _pl.tw * _lz, _thz = _pl.th * _lz;
		var _ox = gx_x * _pl.f * _lz, _oy = gx_y * _pl.f * _lz;
		var _sx0 = (_twz - _vw) * .5, _sy0 = (_thz - _vh) * .5;
		for (var _i = 0; _i < array_length(_pl.stars); _i++) {
			var _ps = _pl.stars[_i];
			var _px = (_ps.x * _lz - _ox) mod _twz; if (_px < 0) _px += _twz;
			var _py = (_ps.y * _lz - _oy) mod _thz; if (_py < 0) _py += _thz;
			draw_sprite_ext(spr_pixel_1x1, 0, (_px - _sx0) * _gs, (_py - _sy0) * _gs, _lz * _gs, _lz * _gs, 0, _ps.col, _ps.a);
		}
	}
	// the stars, with their depth parallax about the view's centre
	var _vcx = gx_x + _vw * .5 / gx_zoom, _vcy = gx_y + _vh * .5 / gx_zoom;
	var _vis = star_visible(gx_x, gx_y, gx_zoom, _vw, _vh);
	var _m = 12 * gx_zoom + 4;
	// THE NEBULAE (2026-09-16): the galaxy's clouds (galaxy_nebulae), each its own bent body (sh_nebula), IN THE STAR PLANE
	// (they are the clusters' own clouds: at the haze's depth they slid off their stars as the map panned - his note) and
	// under the stars, so the stars stay crisp and pickable over them
	var _nbs = galaxy_nebulae();
	gpu_set_blendmode(bm_add);
	for (var _ni = 0; _ni < array_length(_nbs); _ni++) {
		var _nb = _nbs[_ni];
		var _nx = (_nb.x - gx_x) * gx_zoom, _ny = (_nb.y - gx_y) * gx_zoom, _nr = _nb.r * gx_zoom;
		if (_nx + _nr < 0 || _nx - _nr > _vw || _ny + _nr < 0 || _ny - _nr > _vh) continue;
		if (_nb[$ "dark"] ?? false) continue;   // (the dark ones come after the stars and the haze: they hide them)
		nebula_draw(_nb, _nx * _gs, _ny * _gs, _nr * _gs, _gcf[$ "neb_alpha_map"] ?? .3);
	}
	// THE STAR GLYPHS (his ask, 2026-09-16: "a nicer looking star image"): spr_star_glyph - ten sizes from a pixel, core + halo (+ spikes on the biggest three),
	// a whole-scale pixel glyph (gs times: crisp), tinted the star's colour and its core laid white over it, both additive;
	// the frame by the star's size on the page - a dwarf a five-pixel spark, a giant a thirty-one-pixel star
	gpu_set_blendmode(bm_add);
	for (var _i = 0; _i < array_length(_vis); _i++) {
		var _st = _sm.stars[_vis[_i]];
		var _sx = ((_vcx + (_st.x - _vcx) * _st.d) - gx_x) * gx_zoom;
		var _sy = ((_vcy + (_st.y - _vcy) * _st.d) - gx_y) * gx_zoom;
		if (_sx < -_m || _sx > _vw + _m || _sy < -_m || _sy > _vh + _m) continue;
		var _skd0 = _st.props[$ "skind"] ?? "main";
		var _s = max(.8, _st.props.size * gx_zoom * ((_skd0 == "giant") ? 1.35 : 1));   // (1.8 read too big - his report)   // (a giant's glyph nearly twice its size's - "I can't tell which one is one", 2026-09-17)
		var _gi = star_glyph_frame(_s);
		var _gx0 = floor(_sx * _gs), _gy0 = floor(_sy * _gs);
		// THE KIND'S OWN MARK (his ask, 2026-09-17: "the stars on the galactic map match the type of stellar body"): a
		// BLACK HOLE is a black disc in a thin ring of its disc's colour with the disc's glow laid flat across it; a
		// RED GIANT wears a wide deep-red halo; a PULSAR is a white point with two beams turning on its own spin; a
		// WHITE DWARF stays the smallest spark, blue-white
		var _skd = _st.props[$ "skind"] ?? "main";
		var _gw0 = max(1, sprite_get_width(spr_vis_glow_soft)), _gh0 = max(1, sprite_get_height(spr_vis_glow_soft));
		if (_skd == "hole") continue;   // (a black hole is drawn AFTER the fog, below: the fog lay over its black - 2026-09-17)
		if (_skd == "dwarf") {
			// a tiny spark with a subtle line bloom, horizontal (his ask); the bloom centred ON the spark's pixel (the glyph's
			// canvas is even: its spark sits a pixel right and down of the origin), a pixel longer each side
			var _dc = merge_colour(_st.props.color, c_white, .6);
			draw_sprite_ext(spr_vis_glow_soft, 0, _gx0 + _gs * .5, _gy0 + _gs * .5, (max(6, _s * 5) + 2) * _gs / _gw0, max(1, _gs * .8) / _gh0, 0, _dc, .30);
			draw_sprite_ext(spr_star_glyph, min(_gi, 1), _gx0, _gy0, _gs, _gs, 0, _dc, 1);
			continue;
		}
		// a pulsar is a plain star here with a pulse on its own spin - PLAIN to see now (his report: "too subtle"): dim
		// between beats, the beat a sharp flash with its white core
		var _pk = 1;
		if (_skd == "pulsar") { var _pt = (current_time / 1000) * (_st.props[$ "spin"] ?? 1) + (_st.seed mod 1000) / 1000; _pk = .55 + .45 * power(.5 + .5 * dsin(_pt * 360), 4); }   // (a touch gentler - his ask)
		// THE NEW KINDS' MARKS (q253 / q267): a swelling star fills and snaps; a brown dwarf is a dull red mote; a chromatic star's glyph splits into red and blue; a protostar sits in an orange puff
		if (_skd == "swell") _pk = .65 + .35 * (star_swell(_st.seed).s - .84) / .58;   // (the swelling star fills and snaps - q267)
		if (_skd == "brown") { draw_sprite_ext(spr_star_glyph, min(_gi, 1), _gx0, _gy0, _gs, _gs, 0, merge_colour(_st.props.color, c_black, .3), .8); continue; }
		if (_skd == "chroma") {
			// the chromatic star's mark: the glyph split into its red and blue, a pixel each way, turning (q267)
			var _ca = (current_time / 1000) * 17 + (_st.seed mod 360), _cdx = round(dcos(_ca)) * _gs, _cdy = -round(dsin(_ca)) * _gs;
			gpu_set_colorwriteenable(true, false, false, true);  draw_sprite_ext(spr_star_glyph, _gi, _gx0 + _cdx, _gy0 + _cdy, _gs, _gs, 0, c_white, .95);
			gpu_set_colorwriteenable(false, true, false, true);  draw_sprite_ext(spr_star_glyph, _gi, _gx0, _gy0, _gs, _gs, 0, c_white, .95);
			gpu_set_colorwriteenable(false, false, true, true);  draw_sprite_ext(spr_star_glyph, _gi, _gx0 - _cdx, _gy0 - _cdy, _gs, _gs, 0, c_white, .95);
			gpu_set_colorwriteenable(true, true, true, true);
			continue;
		}
		if (_skd == "proto") draw_sprite_ext(spr_vis_glow_soft, 0, _gx0 + _gs * .5, _gy0 + _gs * .5, _s * 4 * _gs / _gw0, _s * 4 * _gs / _gh0, 0, merge_colour(_st.props.color, rgb(255, 160, 100), .5), .45);
		draw_sprite_ext(spr_star_glyph, _gi, _gx0, _gy0, _gs, _gs, 0, _st.props.color, .95 * _pk);
		if (_gi >= 2 && (_skd != "pulsar" || _pk > .7)) draw_sprite_ext(spr_star_glyph, STAR_GLYPH_CORE + _gi, _gx0, _gy0, _gs, _gs, 0, c_white, .8 * _pk);   // (a dot stays its colour)
		if (_skd == "pulsar" && _pk > .85) draw_sprite_ext(spr_star_glyph, min(9, _gi + 1), _gx0, _gy0, _gs, _gs, 0, c_white, .5 * (_pk - .85) / .15);   // (the flash swells a frame)
		if (_skd == "giant") draw_sprite_ext(spr_vis_glow_soft, 0, _gx0 + _gs * .5, _gy0 + _gs * .5, _s * 3.6 * _gs / _gw0, _s * 3.6 * _gs / _gh0, 0, _st.props.color, .45);   // (the halo in the giant's OWN palette - yellow, orange, red, the carbon ruby; it was tinted red over all four - q267)
	}
	gpu_set_blendmode(bm_normal);
	// the fog, additive over the stars (the demo's order), bilinear, PROCEDURAL (sh_galaxy_fog: the sheet through a warped
	// domain, frayed to wisps - the clouds were circles; his report 2026-09-16); dithered there only on an 8-bit page
	var _fd = _gcf.fog_depth;
	var _ffx = (_vcx * (1 - _fd) - gx_x) * gx_zoom, _ffy = (_vcy * (1 - _fd) - gx_y) * gx_zoom;
	var _ffs = _fd * gx_zoom * _sm.width / surface_get_width(_gxf);
	var _ftf = gpu_get_tex_filter();
	gpu_set_tex_filter(true);
	gpu_set_blendmode(bm_add);
	var _fsh_ok = shader_is_compiled(sh_galaxy_fog);   // (a shader that failed to compile draws nothing: the sheet goes plain instead, and the page says so)
	if (_fsh_ok) {
	shader_set(sh_galaxy_fog);
	shader_set_uniform_f(gxf_u.time, (current_time mod 100000) / 1000);   // (the handles looked up once, in the Create - q215)
	shader_set_uniform_f(gxf_u.dither, page_float() ? 0 : 1);
	shader_set_uniform_f(gxf_u.seed, (_sm.seed mod 97) * .37, (_sm.seed mod 89) * .53);
	shader_set_uniform_f(gxf_u.freq, _gcf[$ "fog_freq"] ?? 34);
	shader_set_uniform_f(gxf_u.warp, _gcf[$ "fog_warp"] ?? .03);
	shader_set_uniform_f(gxf_u.gal, _sm.cx / _sm.width, _sm.cy / _sm.width, _sm.gal_r / _sm.width);
	}
	draw_surface_ext(_gxf, _ffx * _gs, _ffy * _gs, _ffs * _gs, _ffs * _gs, 0, _fsh_ok ? c_white : rgb(255, 185, 125), _fsh_ok ? _gcf.fog_alpha : _gcf.fog_alpha * .5);
	if (_fsh_ok) shader_reset();
	// THE DARK NEBULAE (2026-09-16): over the stars and the haze - dust hides what lies under it
	for (var _ni = 0; _ni < array_length(_nbs); _ni++) {
		var _nb = _nbs[_ni];
		if (!(_nb[$ "dark"] ?? false)) continue;
		var _nx = (_nb.x - gx_x) * gx_zoom, _ny = (_nb.y - gx_y) * gx_zoom, _nr = _nb.r * gx_zoom;
		if (_nx + _nr < 0 || _nx - _nr > _vw || _ny + _nr < 0 || _ny - _nr > _vh) continue;
		nebula_draw(_nb, _nx * _gs, _ny * _gs, _nr * _gs, _gcf[$ "neb_dark_map"] ?? .7);
	}
	gpu_set_blendmode(bm_normal);
	gpu_set_tex_filter(_ftf);
	// THE BLACK HOLES, over the fog and the dust (2026-09-17: the fog added over the black made a grey dot of a hole; smaller
	// than before - his report): a black disc, its disc's glow laid flat and tilted across it, a thin ring of its colour
	var _gw2 = max(1, sprite_get_width(spr_vis_glow_soft)), _gh2 = max(1, sprite_get_height(spr_vis_glow_soft));
	for (var _i = 0; _i < array_length(_vis); _i++) {
		var _st = _sm.stars[_vis[_i]];
		if ((_st.props[$ "skind"] ?? "main") != "hole") continue;
		var _sx = ((_vcx + (_st.x - _vcx) * _st.d) - gx_x) * gx_zoom;
		var _sy = ((_vcy + (_st.y - _vcy) * _st.d) - gx_y) * gx_zoom;
		if (_sx < -_m || _sx > _vw + _m || _sy < -_m || _sy > _vh + _m) continue;
		var _s = max(.8, _st.props.size * gx_zoom), _gx0 = floor(_sx * _gs) + _gs * .5, _gy0 = floor(_sy * _gs) + _gs * .5;
		var _hr = max(1, _s * .4) * _gs;   // (smaller again, and no drawn ring - it read as a selection circle; his report q195)
		gpu_set_blendmode(bm_add);
		draw_sprite_ext(spr_vis_glow_soft, 0, _gx0, _gy0, _hr * 5 / _gw2, _hr * 1.6 / _gh2, 18, _st.props.color, .28);   // (the accretion disc, flat and tilted)
		draw_sprite_ext(spr_vis_glow_soft, 0, _gx0, _gy0, _hr * 2.8 / _gw2, _hr * 2.8 / _gh2, 0, merge_colour(_st.props.color, c_white, .4), .20);   // (the lensed light round the black)
		gpu_set_blendmode(bm_normal);
		draw_circle_colour(_gx0, _gy0, _hr, c_black, c_black, false);
	}
	gpu_set_blendmode(bm_normal);
	// the home star: a pulsing hollow square and its name; the tapped star: a white one - gs times over, on the window's grid
	// (no mark for the opened worlds' stars: the worlds need not know they have been - his call, 2026-09-16)
	draw_set_font(fnt); draw_set_halign(fa_left); draw_set_valign(fa_top);
	var _marks = [ { i : _hm.star, col : c_gold, txt : star_name(_hm.star) + "  -  you are here" } ];
	if (gx_sel >= 0 && gx_sel != _hm.star) array_push(_marks, { i : gx_sel, col : c_white, txt : star_name(gx_sel) + "  -  " + star_kind_word(_sm.stars[gx_sel].props[$ "skind"] ?? "main") + ", class " + _sm.stars[gx_sel].props.stellar_class + (is_struct(gx_sys) ? ("  -  " + string(array_length(gx_sys.planets)) + " worlds") : "") });
	// THE NEIGHBOURHOOD'S ODDITIES (q265; his report: "i dont know how to find them"): every star of a kind within the
	// home's sky range, the twelve nearest, labelled with its kind in the dim - the debug neighbourhood reads, and in a
	// real game these are the ones you would fly to
	var _lcfg = starmap_config(), _lrng = _lcfg.sky_range, _hst = _sm.stars[_hm.star];
	var _lcand = star_visible(_hst.x - _lrng, _hst.y - _lrng, 1, _lrng * 2, _lrng * 2), _lodd = [];
	for (var _li = 0; _li < array_length(_lcand); _li++) {
		var _lst = _sm.stars[_lcand[_li]];
		if ((_lst.props[$ "skind"] ?? "main") == "main" || _lcand[_li] == _hm.star) continue;
		var _ld = point_distance(_hst.x, _hst.y, _lst.x, _lst.y);
		if (_ld > _lrng) continue;
		array_push(_lodd, { i : _lcand[_li], d : _ld });
	}
	array_sort(_lodd, function(_a, _b) { return _a.d - _b.d; });
	for (var _li = 0; _li < min(12, array_length(_lodd)); _li++) {
		var _lst = _sm.stars[_lodd[_li].i];
		if (_lodd[_li].i == gx_sel) continue;   // (the card says it)
		var _lsx = ((_vcx + (_lst.x - _vcx) * _lst.d) - gx_x) * gx_zoom, _lsy = ((_vcy + (_lst.y - _vcy) * _lst.d) - gx_y) * gx_zoom;
		if (_lsx < -40 || _lsy < -10 || _lsx > _vw + 40 || _lsy > _vh + 10) continue;
		draw_set_halign(fa_center); draw_set_color(merge_colour(_lst.props.color, c_white, .4)); draw_set_alpha(.6);
		draw_text_transformed(floor(_lsx * _gs), floor((_lsy + 5) * _gs), star_kind_word(_lst.props[$ "skind"] ?? "main", true), _gs, _gs, 0);
		draw_set_halign(fa_left);
	}
	for (var _k = 0; _k < array_length(_marks); _k++) {
		var _mk = _marks[_k];
		var _st = _sm.stars[_mk.i];
		var _sx = ((_vcx + (_st.x - _vcx) * _st.d) - gx_x) * gx_zoom;
		var _sy = ((_vcy + (_st.y - _vcy) * _st.d) - gx_y) * gx_zoom;
		var _ms = 8 + ((_mk.i == _hm.star) ? floor(1.5 + 1.5 * dsin(current_time * .25)) * 2 : 0);
		var _mx0 = floor((_sx - _ms * .5) * _gs), _my0 = floor((_sy - _ms * .5) * _gs), _mss = _ms * _gs;
		draw_sprite_ext(spr_pixel_1x1, 0, _mx0, _my0, _mss, _gs, 0, _mk.col, .95);
		draw_sprite_ext(spr_pixel_1x1, 0, _mx0, _my0 + _mss - _gs, _mss, _gs, 0, _mk.col, .95);
		draw_sprite_ext(spr_pixel_1x1, 0, _mx0, _my0 + _gs, _gs, _mss - 2 * _gs, 0, _mk.col, .95);
		draw_sprite_ext(spr_pixel_1x1, 0, _mx0 + _mss - _gs, _my0 + _gs, _gs, _mss - 2 * _gs, 0, _mk.col, .95);
		draw_set_color(_mk.col); draw_set_alpha(.95);
		draw_text_transformed(floor((_sx + _ms * .5 + 4) * _gs), floor((_sy - 4) * _gs), _mk.txt, _gs, _gs, 0);
	}
	draw_set_alpha(1);
	surface_reset_target();
	// THE MINIMAP (the demo's, his ask): the whole galaxy as dots baked once,
	// the view's rectangle over it, the home star gold; tap it to jump
	var _mmr = __gx_mm_r();
	if (!surface_exists(gx_mm) || gx_mm_seed != _sm.seed) {
		if (surface_exists(gx_mm)) surface_free(gx_mm);
		gx_mm = surface_create(_mmr.w, _mmr.h);
		surface_set_target(gx_mm);
		draw_clear_alpha(c_black, 0);
		var _msc = _mmr.w / _sm.width;
		for (var _i = 0; _i < _sm.count; _i++) {
			var _st = _sm.stars[_i];
			draw_sprite_ext(spr_pixel_1x1, 0, floor(_st.x * _msc), floor(_st.y * _msc), 1, 1, 0, _st.props.color, .22 + .3 * clamp(_st.props.size / 4, 0, 1));
		}
		surface_reset_target();
		gx_mm_seed = _sm.seed;
	}
	ui_fade_set(_fa);
	// THE GLOW (his memory of the demo's glow layer, as a shader: sh_blur -
	// the finished map at half size, two passes, laid back additively) -
	// into the page on a float page, then the page to the screen through
	// the one dither; on an 8-bit page the glow lands on the screen after
	if (page_float()) { __bloom(wb_surf, _vws, _vhs, _gr.x, _gr.y, .75, 1 / _gs); page_blit(wb_surf, _gr.x, _gr.y, 1 / _gs); }
	else { page_blit(wb_surf, _gr.x, _gr.y, 1 / _gs); __bloom(wb_surf, _vws, _vhs, _gr.x, _gr.y, .75, 1 / _gs); }
	if (!shader_is_compiled(sh_galaxy_fog) || !shader_is_compiled(sh_sky_fog) || !shader_is_compiled(sh_nebula) || !shader_is_compiled(sh_sky_inside) || !shader_is_compiled(sh_star) || !shader_is_compiled(sh_station)) { draw_set_font(fnt); draw_set_halign(fa_left); draw_set_color(c_hred); draw_set_alpha(.95); draw_text(_gr.x + 4, _gr.y + _gr.h - 30, (shader_is_compiled(sh_galaxy_fog) ? "" : "sh_galaxy_fog failed to compile  ") + (shader_is_compiled(sh_sky_fog) ? "" : "sh_sky_fog failed to compile  ") + (shader_is_compiled(sh_nebula) ? "" : "sh_nebula failed to compile  ") + (shader_is_compiled(sh_sky_inside) ? "" : "sh_sky_inside failed to compile  ") + (shader_is_compiled(sh_star) ? "" : "sh_star failed to compile  ") + (shader_is_compiled(sh_station) ? "" : "sh_station failed to compile")); }   // (2026-09-16: the page is the compile log)
	ui_fade_set(_ea);
	draw_sprite_ext(spr_pixel_1x1, 0, _mmr.x - 1, _mmr.y - 1, _mmr.w + 2, _mmr.h + 2, 0, c_black, .7);
	draw_surface(gx_mm, _mmr.x, _mmr.y);
	draw_px_rect(_mmr.x - 1, _mmr.y - 1, _mmr.w + 2, _mmr.h + 2, c_steelblue, .5);
	var _msc2 = _mmr.w / _sm.width;
	var _vx0 = _mmr.x + gx_x * _msc2, _vy0 = _mmr.y + gx_y * _msc2, _vw0 = max(2, _vw / gx_zoom * _msc2), _vh0 = max(2, _vh / gx_zoom * _msc2);
	draw_px_rect(floor(_vx0), floor(_vy0), ceil(_vw0), ceil(_vh0), c_white, .7);
	var _hst = _sm.stars[_hm.star];
	draw_sprite_ext(spr_pixel_1x1, 0, floor(_mmr.x + _hst.x * _msc2) - 1, floor(_mmr.y + _hst.y * _msc2) - 1, 2, 2, 0, c_gold, 1);
	// the title
	draw_set_color(c_white); draw_set_alpha(.95);
	draw_text(land ? 14 : 4, list_y + 6, _sm.name);
	draw_set_color(_dim); draw_set_alpha(.7);
	draw_text((land ? 14 : 4) + string_width(_sm.name) + 10, list_y + 6, string(_sm.count) + " stars  -  " + _sm.regions[_sm.stars[_hm.star].props.region].name + "  -  x" + string_format(gx_zoom, 1, 2));
	draw_set_alpha(.5);
	draw_text(land ? 14 : 4, list_y + 20, "drag to pan  -  wheel to zoom  -  tap a star" + ((gx_sel >= 0) ? "  -  [enter] for its system" : ""));
	// [ENTER] (his ask, 2026-09-16: the demo's star system view, back): a star tapped, the button bottom right takes you into its system
	if (gx_sel >= 0 && is_struct(gx_sys)) { var _ger = __gx_enter_r(); draw_ui_button(_ger.x, _ger.y, _ger.w, _ger.h, "enter  >", c_gold, true, true); }
	__draw_back();
	ui_fade_set(1);
	return true;
}
