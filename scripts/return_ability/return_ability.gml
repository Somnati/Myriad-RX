/// @description return_ability(current) -> new value. the write-back
/// mirror of ability(): the cursor walks the same order, skipping
/// locked entries, and the row matching the caller's `a` writes its
/// (possibly toggled) input back to the global. ported from Myriad.
function return_ability(_cur) {
	if (_cur == -1) return -1; // locked: cursor skips, exactly like ability()
	if (a == _a) _cur = input;
	_a++;
	return _cur;
}
