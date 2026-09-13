/// @description objective_step_done(objective, i) -> is step i of this
/// objective ticked? The STICKY mark objective_tick set ("key:i"), or
/// - for an objective already done as a whole - yes. Views read this;
/// nothing here evaluates a predicate, so a view can never disagree
/// with the runner about what is ticked.
function objective_step_done(_o, _i) {
	objective_init();
	if (g.obj.done[$ _o.key] ?? false) return true;
	return g.obj.flags[$ _o.key + ":" + string(_i)] ?? false;
}
