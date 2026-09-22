/// @description coll_lfield(c) -> the field's factor, LOG10 (levels x log10(COLL_FIELD_MULT))
function coll_lfield(_c) {
	return _c.field * log10(COLL_FIELD_MULT);
}
