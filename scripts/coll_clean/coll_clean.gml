/// @description coll_clean(c) -> the clean-collision factor 1..COLL_CLEAN: full at exact balance, gone at the window's edge (a factor of two apart; THE MAGNET widens it x1.5 a level - coll_window)
function coll_clean(_c) {
	if (_c.m.stock < COLL_LZ * .5 || _c.a.stock < COLL_LZ * .5) return 1;
	return 1 + (COLL_CLEAN - 1) * max(0, 1 - abs(_c.m.stock - _c.a.stock) / coll_window(_c));
}
