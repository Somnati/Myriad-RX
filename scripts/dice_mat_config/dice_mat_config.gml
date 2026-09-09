/// @description dice_mat_config() - THE dice material roster. Adding a
/// finish is one row here and nothing else: the settings pill builds
/// itself from this list and obj_dice reads it by id.
///
/// ⚖️ THE TECH DEMO'S MATERIAL SYSTEM IS THREE NUMBERS (his ask: go read
/// it). sh_dice takes a body colour, a pip colour, and u_metal - a
/// matte-to-metallic slide that does four things at once, all of them
/// physically motivated:
///   the diffuse floor DROPS      (metals barely scatter light)
///   the glint TIGHTENS           (exponent 9 -> 36)
///   the glint TINTS ITSELF       (a metal reflects its OWN colour;
///                                 this is the single line that makes
///                                 gold look like gold and not like a
///                                 yellow ball)
///   a grazing-angle sheen ARRIVES
/// The tech demo rolled all three at random per die and never named a
/// single combination. This is that system with the good combinations
/// written down.
///
/// ⚖️ AND ONE THING IT COULD NOT DO. Pearl is not a duller metal - it is
/// a surface whose HUE depends on the angle you view it from, and no
/// value of u_metal produces that. So sh_dice gained u_iri: a hue swept
/// by the facing term, mixed into the SPECULAR rather than the body,
/// because that is where a real film lives (a pearl's body stays pale
/// and only its sheen travels). At 0 the shader is bit-identical to
/// before it existed, so every metal here is unaffected by its presence.
///
/// Fields:
///   id     the saved key. NEVER renumber or rename - it is the save
///          format. Retiring a finish means leaving its row and
///          dropping it from the pill, not deleting it.
///   name   what the settings pill shows
///   col    body colour
///   metal  0 matte .. 1 metallic
///   iri    0 none .. 1 full film
///   ink    -1 = derive the pip colour from body luminance (the tech
///          demo's rule, and right nearly always); or an explicit
///          [r,g,b] 0..1 when a finish wants its pips a specific colour
function dice_mat_config() {
	return [
		// THE DEFAULT IS RANDOM, because that is what the tech demo did
		// and it is genuinely the most charming option - two dice that
		// never match. Everything below is the choice to stop rolling.
		{ id : "random",  name : "random",      col : -1,
		  metal : -1,  iri : 0,   ink : -1 },

		{ id : "gold",    name : "gold",        col : rgb(255, 200,  70),
		  metal : 1,   iri : 0,   ink : -1 },
		{ id : "silver",  name : "silver",      col : rgb(226, 232, 240),
		  metal : 1,   iri : 0,   ink : -1 },
		{ id : "copper",  name : "copper",      col : rgb(214, 122,  70),
		  metal : 1,   iri : 0,   ink : -1 },
		// steel is silver's cold twin - darker body, same finish, and
		// the pair is what makes either read as a specific metal rather
		// than as "grey"
		{ id : "steel",   name : "steel",       col : rgb(150, 162, 178),
		  metal : 1,   iri : 0,   ink : -1 },
		{ id : "obsidian", name : "obsidian",   col : rgb( 28,  30,  42),
		  metal : .85, iri : .15, ink : [.94, .94, .97] },

		// ---- the films ----
		// metal LOW on purpose. A film on a mirror is a mirror; pearl and
		// opal need a pale scattering body for the sheen to sit on.
		{ id : "pearl",   name : "pearlescent", col : rgb(242, 238, 246),
		  metal : .25, iri : .85, ink : [.10, .10, .16] },
		{ id : "opal",    name : "opal",        col : rgb(206, 226, 232),
		  metal : .35, iri : 1,   ink : [.08, .10, .18] },
		{ id : "oil",     name : "oil slick",   col : rgb( 42,  38,  60),
		  metal : .7,  iri : 1,   ink : [.95, .95, 1  ] },

		// ---- the plains ----
		// no glint worth the name. They exist so the roster has a floor:
		// gold only looks expensive next to something that does not.
		{ id : "bone",    name : "bone",        col : rgb(232, 226, 206),
		  metal : .05, iri : 0,   ink : [.16, .14, .12] },
		{ id : "jade",    name : "jade",        col : rgb( 96, 176, 140),
		  metal : .3,  iri : .12, ink : [.06, .14, .10] },
		{ id : "ruby",    name : "ruby",        col : rgb(196,  46,  74),
		  metal : .55, iri : .2,  ink : [1,  .92, .94] },
	];
}
