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

/// ⚖️ THE OVERLAY RUNG (2026-09-09). Settings and statistics used to
/// raise ui_layer_popup, the same rung a dropdown does, and that one
/// collision is what made the tapper dead inside settings while a
/// comment in obj_clicker insisted it was live. They are not the same
/// kind of busy: a dropdown is a thing you must answer before anything
/// else happens, a full-screen panel is a thing you are standing in
/// front of while the game carries on behind it. Splitting them lets
/// the tapper ask for exactly "the panel may be up, a dropdown may not"
/// - which is the rule he actually described - without re-deriving the
/// blocker ladder at the call site.
#macro ui_layer_overlay 100
#macro ui_layer_popup 200
#macro ui_layer_menu  500
#macro ui_layer_modal 1000

function input_free(_layer = 0) {

	if (!variable_global_exists("input_block")) return true; // bare-room testing
	return _layer >= g.input_block;

}
