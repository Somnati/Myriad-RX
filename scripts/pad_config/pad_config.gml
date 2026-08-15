/// @description pad_config() - THE action map (edit HERE). every
/// gameplay read goes through ACTIONS, never raw gp_* constants:
/// consumers ask pad_down("confirm") / pad_x("move"), and what
/// physical input feeds an action is this file's business (plus the
/// player's rebinds, which overwrite binds at load).
///
/// >>> ADD AN ACTION: one line. kinds:
///   "d" digital  - binds = array of bindings, ANY of them fires it
///   "v" value    - analog 0..1 (triggers); down derives at digi_thr
///   "s" stick    - src "l"/"r", radial-deadzone vector (pad_x/pad_y);
///                  sticks aren't rebindable, they ARE the stick
/// bindings (serializable structs, saved to settings.ini "pad"):
///   { k : "b", v : gp_* }         a button
///   { k : "a", v : gp_axis*, s : +-1 }  an axis half past digi_thr
///   { k : "t", v : gp_shoulder*b }      a trigger's analog value
///
/// dpad AND left stick both feed up/down/left/right - menu/list nav
/// reads one action and gets both for free.
function pad_config() {
	return {
		move    : { kind : "s", src : "l", label : "move" },
		look    : { kind : "s", src : "r", label : "look" },
		up      : { kind : "d", label : "up",
			binds : [{ k : "b", v : gp_padu }, { k : "a", v : gp_axislv, s : -1 }] },
		down    : { kind : "d", label : "down",
			binds : [{ k : "b", v : gp_padd }, { k : "a", v : gp_axislv, s : 1 }] },
		left    : { kind : "d", label : "left",
			binds : [{ k : "b", v : gp_padl }, { k : "a", v : gp_axislh, s : -1 }] },
		right   : { kind : "d", label : "right",
			binds : [{ k : "b", v : gp_padr }, { k : "a", v : gp_axislh, s : 1 }] },
		confirm : { kind : "d", label : "confirm", binds : [{ k : "b", v : gp_face1 }] },
		cancel  : { kind : "d", label : "cancel",  binds : [{ k : "b", v : gp_face2 }] },
		alt_a   : { kind : "d", label : "alt a",   binds : [{ k : "b", v : gp_face3 }] },
		alt_b   : { kind : "d", label : "alt b",   binds : [{ k : "b", v : gp_face4 }] },
		lb      : { kind : "d", label : "bumper l", binds : [{ k : "b", v : gp_shoulderl }] },
		rb      : { kind : "d", label : "bumper r", binds : [{ k : "b", v : gp_shoulderr }] },
		lt      : { kind : "v", label : "trigger l", binds : [{ k : "t", v : gp_shoulderlb }] },
		rt      : { kind : "v", label : "trigger r", binds : [{ k : "t", v : gp_shoulderrb }] },
		l3      : { kind : "d", label : "click l",  binds : [{ k : "b", v : gp_stickl }] },
		r3      : { kind : "d", label : "click r",  binds : [{ k : "b", v : gp_stickr }] },
		menu    : { kind : "d", label : "menu",     binds : [{ k : "b", v : gp_start }] },
		view    : { kind : "d", label : "view",     binds : [{ k : "b", v : gp_select }] },
	};
}
