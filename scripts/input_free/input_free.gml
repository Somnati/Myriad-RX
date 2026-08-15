/// @description input_free(layer);
/// @param layer
/// the ONE authority on "is clicking allowed right now". every ui
/// blocker (dialogue, menu, whatever comes later) is a line HERE, not
/// a condition sprayed across every clickable object.
///
/// blockers set a level; a clickable passes if its layer reaches it.
/// plain room ui is layer 0 (the default). the menu's own chrome
/// (obj_ui_menu / obj_deb_menu) is ui_layer_menu, so it keeps working
/// while the open menu blocks the room behind it. the dialogue box is
/// fully modal: nothing beats it, its input runs internally.
/// syst_input recomputes g.input_block every begin step.

#macro ui_layer_popup 200
#macro ui_layer_menu  500
#macro ui_layer_modal 1000

function input_free(_layer = 0) {

	if (!variable_global_exists("input_block")) return true; // bare-room testing
	return _layer >= g.input_block;

}
