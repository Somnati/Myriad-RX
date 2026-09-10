/// @description bit_config() - THE LOOK ROSTER for the bezier motes,
/// declared as data. One list, every lane picks from it.
///
/// ⚖️ TWO STYLES HE ASKED FOR, PLUS THE THREE THAT ALREADY EXISTED
/// (2026-09-10: "one like it is now and another without the glow").
/// obj_bezier_bit has carried Myriad DE's circle / coin / munny skins
/// since round 7, behind a g.part_style that no settings row ever set -
/// so every player has only ever seen the glowing square. This roster
/// is the row that was missing, and it lists all five because deleting
/// ported art to make a two-item list is not a simplification, it is a
/// loss. "glow" is exactly what the game drew yesterday.
///
/// PLAIN IS THE POINT. The glowing square is a halo under a pixel, and
/// under a halo eight motes a second at one spot stop being motes and
/// become a smear - which is what the tile fountain looked like. Plain
/// is the same square with no halo and no arrival bloom: it reads as
/// grains, and grains are what a fountain is made of.
///
/// >>> TO ADD A LOOK: one row here, one branch in obj_bezier_bit's aim()
/// >>> (sprite/frame) and Draw. The settings pills build themselves
/// >>> from this array and the save stores the ID.
///
/// FIELDS: id (the save key - NEVER reuse one for a different look),
/// name (the pill's label).
function bit_config() {
	if (!variable_global_exists("bit_cfg")) {
		g.bit_cfg = [
			{ id : "glow",   name : "glowing square" },
			{ id : "plain",  name : "plain square" },
			{ id : "circle", name : "circle" },
			{ id : "coin",   name : "coin" },
			{ id : "munny",  name : "munny" },
		];
	}
	return g.bit_cfg;
}
