/// @description str_cap(s) -> s with its first letter capitalised (the big font has case; his ask, 2026-09-15)
function str_cap(_s) {
	if (!is_string(_s) || _s == "") return _s;
	return string_upper(string_char_at(_s, 1)) + string_delete(_s, 1, 1);
}
