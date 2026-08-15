/// begin step: settle this frame's input state BEFORE anything reads
/// it. that ordering is also what kills click fall-through for free:
/// the click that picks a dialogue option is evaluated while the
/// blocker is still up, so nothing behind the box can see it.

// ---- blockers ----
// listed in ascending layer order: later, stronger blockers overwrite
g.input_block = 0;
if (instance_exists(obj_pillbox))
	g.input_block = ui_layer_popup;
if (instance_exists(syst_settings) && syst_settings.confirm_active)
	g.input_block = ui_layer_popup; // keep/revert countdown owns the room
if (instance_exists(obj_ui_menu2) && obj_ui_menu2.open)
	g.input_block = ui_layer_menu;
if (instance_exists(obj_dialogue) && obj_dialogue.dialogue_active
&& !obj_dialogue.passive) // passive barks never block (round 19)
	g.input_block = ui_layer_modal;
// (MYRIAD RX: rebuilt DE systems that own the room - offline card,
// rebirth overlay - add their blocker line back here as they land)

// ---- pointer owner: topmost eligible clickable under the cursor ----
// eligible = visible, and its ui_layer (default 0) clears the block.
// the menu's chrome declares ui_layer_menu so it outlives its own
// blocker. ties in depth go to instance order, consistently.
g.click_owner = noone;
var _best = infinity;

// every family whose members call mouse_over(). a new clickable family
// is one entry here; par_* children are swept through their parent
var _fams = [par_button, par_toggle, par_toggle_single, par_slider,
             obj_scrollbar, obj_deb_menu, obj_pillbox];

for (var _i = 0; _i < array_length(_fams); _i++) {
	with (_fams[_i]) {
		if (!visible) continue;
		if (depth >= _best) continue;
		var _ly = variable_instance_exists(id, "ui_layer") ? ui_layer : 0;
		if (_ly < g.input_block) continue;
		if (!mouse_over_raw()) continue;
		_best = depth;
		g.click_owner = id;
	}
}
