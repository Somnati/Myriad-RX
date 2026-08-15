/// @description set_pill(name, [opts]);
/// @param name  the pill's label
/// @param opts  optional struct, all fields optional:
///   val        value tag handed back as _pselval on pick (default: name)
///   col        base color: both palettes derive from this one hue,
///              replacing the 4-color recipe every old call site hand-rolled
///   enabled    starts lit (default false)
///   can_click  pill accepts picks (default true)
///   can_toggle pill shows the on palette when enabled (default true)
///   color_on / tcolor_on / color_off / tcolor_off   manual overrides
/// pills are STRUCTS and the spawned instances hold references: the
/// owner can flip _pills[i].enabled after the box is up and the pill
/// relights live - no _pobj bookkeeping like the old framework.
function set_pill(_name, _o = {}) {
	var _col = _o[$ "col"] ?? rgb(170, 190, 230);
	array_push(_pills, {
		name       : _name,
		val        : _o[$ "val"] ?? _name,
		enabled    : _o[$ "enabled"] ?? false,
		can_click  : _o[$ "can_click"] ?? true,
		can_toggle : _o[$ "can_toggle"] ?? true,
		color_on   : _o[$ "color_on"]   ?? merge_colour(_col, c_black, .70),
		tcolor_on  : _o[$ "tcolor_on"]  ?? color_set_comp(_col),
		color_off  : _o[$ "color_off"]  ?? merge_colour(_col, c_black, .95),
		tcolor_off : _o[$ "tcolor_off"] ?? _col,
	});
}
