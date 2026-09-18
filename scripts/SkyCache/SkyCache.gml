/// @description SkyCache() - A SKY A WORLD (q216: out of syst_exped_panel): galaxy_sky_build(d) kept by the world's seed, the sun's bearing refreshed on every read, rebuilt after ten minutes (the siblings' spots are where they were when it was built), its frozen hole renders (galaxy_sky_holes' hbake) freed with it
function SkyCache() constructor {
	c = {};
	/// the world's sky
	static get = function(_d) {
		var _k = string(_d.seed), _s = c[$ _k];
		if (!is_struct(_s) || (current_time - (_s[$ "built"] ?? 0)) > 600000) { free_bakes(_s); _s = galaxy_sky_build(_d); _s.built = current_time; c[$ _k] = _s; }
		_s.light_w = galaxy_sun_dir(0, _d);
		return _s;
	};
	/// a sky's frozen hole renders let go
	static free_bakes = function(_s) {
		if (!is_struct(_s) || !is_struct(_s[$ "hbake"])) return;
		var _ks = variable_struct_get_names(_s.hbake);
		for (var _j = 0; _j < array_length(_ks); _j++) { var _b = _s.hbake[$ _ks[_j]]; if (is_struct(_b) && surface_exists(_b.surf)) surface_free(_b.surf); }
		_s.hbake = {};
	};
	/// every sky's renders let go (the panel's CleanUp)
	static free_all = function() { var _ks = variable_struct_get_names(c); for (var _i = 0; _i < array_length(_ks); _i++) free_bakes(c[$ _ks[_i]]); };
}
