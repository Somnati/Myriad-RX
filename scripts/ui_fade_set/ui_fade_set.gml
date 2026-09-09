/// @description ui_fade_set(a) - scale everything drawn AFTER this call
/// by alpha _a, until the next call sets it back to 1.
///
/// ⚖️ ONE LEVER INSTEAD OF FIFTY-SIX (2026-09-09, his ask: the overlay
/// rows should "fade in/out with their opacity"). Doing that by hand
/// meant editing every alpha-bearing draw call on the two panels - 56
/// on the statistics screen alone - and every one of those is a chance
/// to miss a site nobody would notice until a row painted solid mid-
/// fade. This is the same result with one place to be wrong.
///
/// It also composites RIGHT. The cheap alternative is to paint a veil
/// over a finished row, but these panels sit on a translucent black
/// backdrop over a BLURRED room: a veil darkens a row toward flat black
/// while the correct destination is "the blurred room, seen through the
/// backdrop". Scaling alpha dissolves to exactly that, for free.
///
/// _a >= 1 is the OFF switch, and it is cheap enough to call every
/// frame - it only touches the pipeline when something is actually
/// mid-fade. Always pair a fade with a ui_fade_set(1): a shader left
/// set belongs to the rest of the frame, not to the caller.
function ui_fade_set(_a) {
	if (_a >= .999) {
		if (shader_current() == sh_ui_fade) shader_reset();
		return;
	}
	if (shader_current() != sh_ui_fade) {
		shader_set(sh_ui_fade);
		// the handle is per-shader and never moves; looking it up once
		// per game beats once per row
		if (!variable_global_exists("ui_fade_u"))
			g.ui_fade_u = shader_get_uniform(sh_ui_fade, "u_alpha");
	}
	shader_set_uniform_f(g.ui_fade_u, max(0, _a));
}
