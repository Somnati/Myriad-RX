/// @description settings_pill(label, kind, current, build, pick,
/// [help], [col]) - a dropdown row riding the house pillbox framework:
/// label left, the CURRENT choice at the value column, tap anywhere on
/// the row to open the box at the tap point.
///   kind    unique tag for this dropdown ("res") - routes the pick
///           back to the right row (the pill_kind convention)
///   current the current choice's label (a plain string, shown lit)
///   build   fn, runs at TAP time in syst_settings' scope: make your
///           set_pill(name, {val, col, enabled}) calls here. val is
///           what pick receives - use a stable token, not an index
///   pick    fn(val), runs on the pick. apply the value here; route
///           risky display changes through __confirm(txt, revert_fn)
///           and the keep/revert countdown handles the rest. don't
///           worry about saving - the controller marks dirty for you
///           (confirm picks save when kept/reverted instead)
/// runs in syst_settings' scope.
/// @arg [stay]  true = the box STAYS OPEN after a pick and closes on an
///              outside tap instead (do_pillbox type 1). For lists you
///              AUDITION rather than set: the sound rows play what you
///              pick, and closing the box after every one made comparing
///              two of them a four-tap job (his ask, 2026-09-08).
///              Everything else keeps the default - a resolution pick
///              opens a keep/revert popup, and a dropdown hanging over
///              that would be its own bug.
function settings_pill(_label, _kind, _current, _build, _pick, _help = "", _col = -1, _stay = false) {
	array_push(rows, {
		kind : sett_kind_pill, name : _label, val : string(_current),
		col : (_col == -1) ? sett_ink : _col,
		help : _help, ind : 0, inst : noone,
		data : { kind : _kind, build : _build, pick : _pick, stay : _stay },
	});
}
