/// @description pad_init() - the controller framework's one-time
/// boot: builds g.pad (per-slot device structs, per-action runtime
/// state, the scannable-input tables for rebind capture + glyphs),
/// loads saved binds/deadzones, and lazy-spawns the persistent
/// syst_gamepad runner (the tiles_init pattern). idempotent - every
/// consumer may call it, first one pays.
///
/// slot note (windows): 0-3 are XInput, 4-11 DirectInput. we track
/// all 12; gamepad_is_connected() decides who's real each scan.
function pad_init() {
	if (variable_global_exists("pad")) exit;
	var _acts = pad_config();
	var _nm = variable_struct_get_names(_acts);
	var _st = {};
	for (var _i = 0; _i < array_length(_nm); _i++)
		_st[$ _nm[_i]] = { down : false, prev : false, val : 0, x : 0, y : 0 };
	var _dv = array_create(12);
	for (var _i = 0; _i < 12; _i++)
		_dv[_i] = { conn : false, name : "", kind : "generic" };
	g.pad = {
		acts : _acts,
		act_names : _nm,   // cached - struct_get_names every step is waste
		state : _st,
		devs : _dv,
		n_conn : 0,
		active : -1,       // last slot that produced input (glyphs/rumble)
		// radial deadzone: below dz = dead, dz..dz_hi remaps to 0..1
		// (dz_hi < 1 because worn sticks never reach the corner)
		dz : .25,
		dz_hi : .97,
		digi_thr : .5,     // axis-as-button / trigger threshold
		rebind : "",       // action name being captured ("" = idle)
		rebind_i : 0,
		rebind_guard : 0,  // frames swallowed after arming
		rumble_t : 0,
		scan_t : 0,        // 0 = rescan now (async hotplug forces it)
		log : [],          // bench feed: hotplug / rebinds / rumble
		// the scannable-input tables: btns paired with per-family
		// glyph names, axes paired with theirs (rebind + display)
		btns : [gp_face1, gp_face2, gp_face3, gp_face4, gp_shoulderl,
			gp_shoulderr, gp_shoulderlb, gp_shoulderrb, gp_select,
			gp_start, gp_stickl, gp_stickr, gp_padu, gp_padd, gp_padl,
			gp_padr],
		glyph_xbox : ["a","b","x","y","lb","rb","lt","rt","view","menu",
			"l3","r3","d-up","d-dn","d-lt","d-rt"],
		glyph_ps   : ["cross","circle","square","triangle","l1","r1",
			"l2","r2","share","options","l3","r3","d-up","d-dn","d-lt","d-rt"],
		glyph_sw   : ["b","a","y","x","l","r","zl","zr","minus","plus",
			"l3","r3","d-up","d-dn","d-lt","d-rt"],
		axes : [gp_axislh, gp_axislv, gp_axisrh, gp_axisrv],
		axis_names : ["lstick x", "lstick y", "rstick x", "rstick y"],
	};
	pad_binds_load();
	if (!instance_exists(syst_gamepad)) create_obj(0, 0, syst_gamepad);
}
