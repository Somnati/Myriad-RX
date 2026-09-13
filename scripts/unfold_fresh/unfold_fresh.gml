/// @description unfold_fresh(key) -> has this feature unfolded and its
/// menu line not been visited yet? (the burger's ring; the menu's
/// "new" suffix - the menu rebuilds on every open, and opening it
/// clears the list, so the suffix shows exactly once)
function unfold_fresh(_key) {
	if (!variable_global_exists("unf")) return false;
	return array_contains(g.unf.fresh, _key);
}
