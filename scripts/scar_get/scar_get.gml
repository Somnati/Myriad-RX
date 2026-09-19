/// @description scar_get(dest, ri) -> the region's SCARS [{ n : node, k : kind, was : the kind before }] - the changes that do not fade (q260)
function scar_get(_d, _ri) {
	exped_init();
	if (!is_struct(g.exped[$ "scars"])) g.exped.scars = {};
	return g.exped.scars[$ lane_key(_d, _ri)] ?? [];
}
