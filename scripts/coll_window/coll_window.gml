/// @description coll_window(c) -> the clean window's half-width in log10: log10(2) x COLL_MAGNET_MULT^magnet
function coll_window(_c) {
	return log10(2) * power(COLL_MAGNET_MULT, _c.magnet_lv);
}
