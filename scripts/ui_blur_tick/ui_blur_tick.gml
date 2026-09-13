/// @description ui_blur_tick() - the menu blur, once a frame, for
/// everything that sits over the room.
///
/// ⚖️ IT DERIVES, IT IS NOT PUSHED. syst_menu2 used to own the blur: it
/// built the layer in its Create and set the intensity from its own fold
/// in its Step. That worked while the drawer was the only thing over the
/// room - then settings and statistics became overlays (2026-09-08) and
/// there was no blur behind either, because the object that owned it was
/// not on screen. Three owners of one effect is three ways to leave it
/// on. So this reads the target off whatever is actually up and runs
/// from system's Begin Step, which always exists.
///
/// IT ALSO SELF-HEALS PER ROOM, which the Create-time build could not:
/// layers are room-scoped, so a room without a "menu_blur" layer gets
/// one here on its first frame rather than only when a menu opens in it.
///
/// The blur layer sits at -500. Anything that must stay SHARP has to be
/// above it - the drawer at -520, the overlays at -510, the header at
/// -1000. Anything below is what gets blurred, which is the room.
function ui_blur_tick() {
	if (!layer_exists("menu_blur")) {
		var _l  = layer_create(-500, "menu_blur");
		var _nf = fx_create("_effect_gaussian_blur");
		fx_set_parameter(_nf, "g_numPasses", 4);
		fx_set_parameter(_nf, "g_numDownsamples", 1);
		fx_set_parameter(_nf, "g_intensity", 0);
		layer_set_fx(_l, _nf);
	}
	// ⚖️ THE SECOND BLUR (his report, 2026-09-13: the menu over the tiles
	// did not soften them). The first layer sits at -500 and blurs the
	// ROOM under an overlay (-510) or the drawer (-520); with the drawer
	// open OVER an overlay the overlay itself is above the layer and
	// stays sharp. This one sits at -515 - over the overlays, under the
	// drawer - and runs on the drawer's fold only while an overlay is up
	if (!layer_exists("menu_blur2")) {
		var _l2  = layer_create(-515, "menu_blur2");
		var _nf2 = fx_create("_effect_gaussian_blur");
		fx_set_parameter(_nf2, "g_numPasses", 4);
		fx_set_parameter(_nf2, "g_numDownsamples", 1);
		fx_set_parameter(_nf2, "g_intensity", 0);
		layer_set_fx(_l2, _nf2);
	}
	var _fx = layer_get_fx("menu_blur");
	if (_fx == -1) return;

	// what wants the room softened, and how much
	var _t = 0;
	if (instance_exists(syst_menu2)) _t = max(_t, syst_menu2.am);
	// ⚖️ IT RIDES THE PANEL'S OWN EASE, not the panel's existence
	// (2026-09-09, with the open animation). Pinned at 1 the blur
	// snapped on under a panel that was still arriving and stayed hard
	// under one that was already leaving - both ends visible, because
	// the panel is translucent and the room reads straight through it.
	var _ov = ui_overlay();
	if (_ov != noone) _t = max(_t, _ov.oa);

	// THE BACKING (obj_menu2_bck) goes with the blur: the plate and the
	// menu's edge gradients under the layer, for the menu and for every
	// overlay alike - see that object's Draw. It kills itself at zero.
	if (_t > .002 && !instance_exists(obj_menu2_bck)) create_obj(0, 0, obj_menu2_bck);

	// eased so the blur arrives with the panel rather than snapping on
	// under it; settles exactly, so a resting screen is not spending a
	// gaussian pass on 0.003 of an effect
	if (!variable_global_exists("ui_blur_a")) g.ui_blur_a = 0;
	g.ui_blur_a = move_to(g.ui_blur_a, _t, 3);
	if (abs(g.ui_blur_a - _t) < .01) g.ui_blur_a = _t;

	// settings > display owns the master switch (his 2026-09-06 report:
	// the toggle existed and was read by nothing)
	var _on = (variable_global_exists("blur") ? g.blur : true) && (g.ui_blur_a > .002);
	layer_set_visible("menu_blur", _on);
	fx_set_parameter(_fx, "g_intensity", _on ? g.ui_blur_a : 0);
	// the second: the drawer's fold, only with an overlay under it
	var _t2 = (instance_exists(syst_menu2) && _ov != noone) ? syst_menu2.am : 0;
	if (!variable_global_exists("ui_blur_b")) g.ui_blur_b = 0;
	g.ui_blur_b = move_to(g.ui_blur_b, _t2, 3);
	if (abs(g.ui_blur_b - _t2) < .01) g.ui_blur_b = _t2;
	var _fx2 = layer_get_fx("menu_blur2");
	if (_fx2 != -1) {
		var _on2 = (variable_global_exists("blur") ? g.blur : true) && (g.ui_blur_b > .002);
		layer_set_visible("menu_blur2", _on2);
		fx_set_parameter(_fx2, "g_intensity", _on2 ? g.ui_blur_b : 0);
	}
}
