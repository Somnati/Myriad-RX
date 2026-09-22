/// @description cas_new() -> a fresh cascade: THE FRAMEWORK's data (dims_init's shape) as a struct any side can own - counts + stock as LOG10 (COLL_LZ = zero), bought units (the per-10 doubling rides these alone), the stock at 10
function cas_new() {
	return { count : array_create(COLL_N, COLL_LZ), bought : array_create(COLL_N, 0), stock : 1 };
}
