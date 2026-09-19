/// @description lane_key(dest, ri) -> the lanes' key for a world's region: "seed:ri" (q259)
function lane_key(_d, _ri) {
	return string(_d.seed) + ":" + string(_ri);
}
