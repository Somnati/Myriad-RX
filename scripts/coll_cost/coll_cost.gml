/// @description coll_cost(c, what) -> the next level's energy price, LOG10: "field" a decade a level from 10^COLL_FIELD_COST; "auto" 10^3 / 10^5 / 10^8 (-1 at the top); "magnet" two decades a level from 10^COLL_MAGNET_COST, four levels
function coll_cost(_c, _what) {
	static _auto = [3, 5, 8];
	switch (_what) {
		case "field": return COLL_FIELD_COST + _c.field;
		case "auto":  return (_c.auto_lv >= 3) ? -1 : _auto[_c.auto_lv];
		case "magnet": return (_c.magnet_lv >= 4) ? -1 : (COLL_MAGNET_COST + 2 * _c.magnet_lv);
	}
	return -1;
}
