/// @description an overlay takes its furniture with it

// ⚖️ EVERY INSTANCE THIS SCREEN SPAWNED DIES HERE. As a ROOM it never
// needed this - leaving the room swept the lot - but an overlay is
// destroyed inside a room that carries on, so anything left behind is a
// live widget parked at -1000 listening for clicks forever. Open and
// close settings twenty times and you would have twenty scrollbars.
//
// The pool is keyed by label and rebuilt on the next open, so there is
// nothing to preserve: the bindings are closures over globals, not
// state the widgets hold.
var _k = variable_struct_get_names(pool);
for (var _i = 0; _i < array_length(_k); _i++) {
	var _w = pool[$ _k[_i]];
	if (instance_exists(_w)) instance_destroy(_w);
}

if (instance_exists(sb))       instance_destroy(sb);
if (instance_exists(strip_px)) instance_destroy(strip_px);

// and any dropdown still hanging off it - do_pillbox spawns one
// instance per option, all pointing back here
with (obj_pillbox) if (obj == other.id) instance_destroy();
