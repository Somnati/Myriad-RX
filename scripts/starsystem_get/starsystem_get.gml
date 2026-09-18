/// @description starsystem_get(seed, [props]) -> the star's system, generated once a session and kept (starsystem_generate is pure; this is the one door)
/// Every reader used to regenerate the system on every call - galaxy_home's
/// four hundred candidates, every galaxy_world_sys, the season, the sky
/// build - and a patch had to live inside the generator to reach them all
/// (q210). Kept here by seed in g.starsys_c, one struct for everybody: a
/// patch (the debug scenario) is made once on the kept object, and the
/// generator stays pure. starsystem_forget(seed) drops one (a star whose
/// props changed). q212
function starsystem_get(_seed, _props = undefined) {
	if (!variable_global_exists("starsys_c")) g.starsys_c = {};
	var _k = string(_seed);
	var _s = g.starsys_c[$ _k];
	if (is_struct(_s)) return _s;
	_s = starsystem_generate(_seed, _props);
	g.starsys_c[$ _k] = _s;
	return _s;
}
