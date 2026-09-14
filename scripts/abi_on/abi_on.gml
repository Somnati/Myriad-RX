/// @description abi_on(key) -> is this ability discovered AND switched on?
/// THE ONE READER every seat uses. Deck values: -1 locked, 0 discovered
/// and off, 1 on, 100 new (discovered, off, wearing the badge). A key
/// the deck does not carry (or a save from before it) reads as off.
function abi_on(_key) {
	if (!variable_global_exists(_key)) return false;
	return (variable_global_get(_key) == 1);
}
