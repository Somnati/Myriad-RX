/// @description star_name(id) -> the star's name, rolled lazily from its seed (the tech demo's scr_star_get_name)
function star_name(_id) {
	var _sm = starmap_get();
	if (_id < 0 || _id >= _sm.count) return "";
	var _st = _sm.stars[_id];
	if (_st.props.name == "") {
		var _rs = random_get_seed();
		random_set_seed(_st.seed);
		_st.props.name = gen_name_planet();
		rng_release(_rs);
	}
	return _st.props.name;
}
