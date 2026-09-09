/// @description an overlay takes its furniture with it

// ⚖️ EVERY INSTANCE THIS SCREEN SPAWNED DIES HERE. As a ROOM it never
// needed this - leaving swept the lot - but an overlay is destroyed
// inside a room that carries on, so anything left behind is a live
// widget parked at -1000 listening for clicks forever.
//
// widgets_all is the right list to sweep precisely because it is the
// one that survives rebuilds: a widget inside a closed folder or filtered
// out by a search is still registered there, which is what makes it get
// parked every step - and what would otherwise make it get orphaned.
for (var _i = 0; _i < array_length(widgets_all); _i++) {
	var _w = widgets_all[_i];
	if (instance_exists(_w)) instance_destroy(_w);
}

if (instance_exists(sb))       instance_destroy(sb);
if (instance_exists(strip_px)) instance_destroy(strip_px);

with (obj_pillbox) if (obj == other.id) instance_destroy();
