/// @description planet_lite_ready(pn) -> true once a world's maps are sampled and its three textures stand (planet_gen_step done, planet_bake done) - safe to hand to planet_draw
function planet_lite_ready(_pn) {
	return is_struct(_pn) && _pn.row >= _pn.th && (_pn[$ "brow"] ?? 0) >= 3 * _pn.th;
}
