/// @description stats_v2_folder(name, [color]) -> ALWAYS true
/// begins a (sub)folder. the author pattern IS the nesting:
///
///   if (stats_v2_folder("tiles")) {
///       stats_v2_line("merges", ...);
///       if (stats_v2_folder("rarity")) { ... } stats_v2_folder_end();
///   } stats_v2_folder_end();
///
/// it now always returns true: children BUILD even when the folder is
/// closed (favorites capture, search and the clipboard dump need the
/// whole tree), they just don't emit visible rows (_fhid > 0 while
/// inside any closed folder). the `if` stays purely for the authoring
/// shape. open state persists in g.stats_open keyed by the full PATH
/// ("/tiles/rarity"), so two subfolders can share a name. everything
/// starts COLLAPSED.
function stats_v2_folder(_name, _col = c_sblue) {
	_fpath += "/" + _name;
	var _open = g.stats_open[$ _fpath] ?? false;
	array_push(dump, { name : _name, val : "", dep : _fdepth });
	if (_fhid == 0 && search == "") array_push(rows, {
		kind : 1, // folder
		name : _name,
		val  : "",
		c1   : _col,
		c2   : c_white,
		fdep : _fdepth,
		path : _fpath,
		key  : _fpath,
		help : "",
		fav  : false,
		data : -1,
		open : _open,
		inst : noone,
		span : 1,
	});
	array_push(_fstack, _open);
	if (!_open) _fhid++;
	_fdepth++;
	return true;
}
