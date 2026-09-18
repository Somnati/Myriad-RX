/// @description starmap_config() -> the galaxy's numbers (the tech demo's
/// scr_starmap_config, ported 2026-09-15 - his call: "port it all over").
/// The generator, the fog, the parallax backdrop, the camera, and the
/// sky's numbers (scr_planet_config's) live here. One struct.
function starmap_config() {
	static _c = {
		// ---- plane / galaxy disc ----
		plane_w  : 6200,
		plane_h  : 6200,
		gal_r    : 2900,  // disc radius
		gal_soft : .12,   // rim feather fraction
		star_target : 10000,
		// ---- spacing: no two stars closer than this, ANY pass ----
		star_spacing : 17,
		// ---- population mix ----
		frac_core    : .07,  // soft glowing center bulge
		frac_arms    : .45,  // the spiral itself, wide and diffuse
		frac_halo    : .30,  // center-weighted dust: no dead zones
		frac_islands : .07,  // soft "continents", anchored ON the arms
		frac_paths   : .04,  // loose star roads linking the continents
		frac_feats   : .07,  // unique features: rings, arcs, streams
		// ---- spiral arms ----
		arm_count      : 2,
		arm_turns      : 2.2,
		arm_width_base : 295,
		arm_width_grow : .05,
		arm_r_min      : .05,
		arm_r_bias     : 1.0,
		// ---- core ----
		core_r : 440,
		// ---- perlin gaps ----
		gap_frac : .10,
		gap_wl   : 180,
		gap_core : 490,
		// ---- swirl (islands / paths / features) ----
		swirl_deg : 25,
		// ---- islands ----
		isl_count : 9,
		isl_r_min : 200,
		isl_r_max : 380,
		// ---- paths ----
		path_step   : 26,
		path_jitter : 40,
		path_bow    : 120,
		// ---- unique features ----
		feat_count    : 6,
		feat_ring_min : 115,
		feat_ring_max : 280,
		feat_stream_steps : 30,
		// ---- regions (named neighbourhoods) ----
		region_stars   : 150,
		region_min_sep : 540,
		// ---- rarity: climbs with distance from the core ----
		rarity_rate_center : 0,
		rarity_rate_edge   : 1440,
		rarity_curve       : 1.5,
		rarity_scale       : .3,
		rarity_growth      : .03,
		rarity_base        : 800,
		// ---- nebula fog (the baked density sheet) ----
		fog_alpha : .39,
		fog_depth : .82,
		fog_freq  : 6,    // sh_galaxy_fog (2026-09-16): noise cells across the map - the clouds' own scale (finer chopped them to smoke)
		fog_warp  : .04,  // ...how far the clouds' outlines wander, in map fraction (the circles' cure)
		// ---- the map's stars (the demo's per-star bloom: spr_star_glow's stepped frames, 2026-09-16) ----
		star_glow_size  : 6,   // wanted glow size as a multiple of star size
		star_glow_alpha : .3,  // the frame's strength (the page's bloom does the rest)
		// ---- the galaxy view's camera ----
		zoom_min     : .5,
		zoom_max     : 4,
		zoom_step    : 1.15,
		tap_max_dist : 6,
		tap_radius   : 12,
		// ---- parallax backdrop ----
		para_layers : 3,
		para_stars  : 70,
		// ---- THE SKY (obj_planet_sky's numbers) ----
		sky_range   : 900, // plane px: neighbours inside this make the sky
		sky_max     : 170, // nearest N of them
		sky_near_ref : 45,  // THE FLUX LAW (q198): a sun-like star this far fills the biggest glyph; flux = luminosity x (this / d)^2 (the inverse square)...
		sky_flux_gamma : .5, // ...its ALPHA = flux ^ gamma (.5 = the eye's square root: the class shows as brightness)...
		sky_size_pow : 2,   // ...its SIZE = (ref / d) ^ this, the class barely in it (q199: size says NEAR - 2 = the inverse square straight; higher = fewer big glyphs)
		sky_size_max : 31,  // the biggest glyph, px (spr_star_glyph's 31)
		dust_count  : 240, // full-sphere faint fill
		sky_cloud   : 520, // THE STAR CLOUDS (2026-09-16): faint points packed along the band - the milky way's grain (galaxy_sky_build)
		sky_glare   : 70,  // px about the sun inside which the stars dim (x the sun's size)
		sun_orbit_ref : 70,  // THE SUN'S SIZE BY THE ORBIT (2026-09-16): the star's size x (this / the world's orbit), clamped...
		sun_size_min  : .45,
		sun_size_max  : 2.2,
		sky_meteor  : 28,  // seconds between meteors, about (the orbit view)
		sky_fog_amp : .13, // milky way raycast fog brightness (sh_sky_fog)
		sky_fog_ms  : 100, // THE FOG'S CACHE (q215): the raycast renders into a sheet only when the camera moves or this many ms have passed; 0 = every frame
		// ---- THE RICHNESS (2026-09-16): a sky reads its neighbourhood's density (0..1) and its depth in the core (0..1) ----
		sky_rich_max   : 1100, // extra stars kept at the densest cell (on sky_max)
		sky_rich_cloud : 2,   // the star clouds' grain, x (1 + this x density)
		sky_rich_fog   : .6,  // the band's brightness, + this x density...
		sky_core_fog   : 1.6, // ...+ this x core depth (and the band fattens to a glow all round inside the bulge)
		// ---- THE NEBULAE (2026-09-16): things of the galaxy (galaxy_nebulae), on the map and in every sky in reach ----
		neb_count     : 44,   // a galaxy
		neb_apart     : 260,  // plane px between any two
		neb_r_min     : 90,   // radius, plane px: this + density x neb_r_dn + up to neb_r_rand
		neb_r_dn      : 220,
		neb_r_rand    : 120,
		neb_lean      : .8,   // a cloud's middle sits within this x its thickness off the plane (triangular): it leans, it never leaves
		neb_range     : 1500, // plane px: a sky shows the ones within this of its star
		neb_kinds     : false, // the shells / pillars / veils (neb_body): off - one kind, his call 2026-09-16 (they had oddities)
		neb_dark_frac : .3,   // DARK NEBULAE (2026-09-16): this share of the clouds are dust - they hide, they never glow
		neb_dark_map  : .92,  // ...how much of the map they hide beneath them ("a lil darker" - his ask)
		neb_dark_sky  : 1.6,  // ...their extinction in a sky (x the near / far factor); inside one, the sky goes out toward its heart
		neb_alpha_map : .3,   // their strength on the map ("very bright" at .55 - his report)
		neb_alpha_sky : .3,   // ...and in the sky (x a near / far factor)
		neb_thick_min : .2,   // half-thickness as a fraction of the radius: this + up to neb_thick_rand (flat clouds: the disc's shape)
		neb_thick_rand: .25,
		star_height   : 140,  // plane px per unit of a star's parallax depth about 1 (d .85..1.15: +-21 px) - a star's height off the plane
		                      // (900 stood the near ones far off the band - "the star height feels weird", his report 2026-09-16: a thin disc, the
		                      // sky's bearings the map's angles, a few degrees of lean at most)
		neb_in_amp    : .7,   // THE NEAR CLOUD (on the sphere): the glow's strength...
		neb_in_ext    : 1.1,  // ...and the extinction per unit of reach x density (the sky beyond dims)
		neb_in_smooth : true, // no jitter and no grain of its own in the march (twenty even steps; the page's blit still dithers) - his call 2026-09-16
		// (the world-orbit stations went 2026-09-17 - the stations orbit the STAR now, station_sys)
		// ---- THE ORBIT VIEW (the expedition panel's planet page) ----
		pr          : 86,  // the planet's radius on the page, px
		orbit_sens  : .5,  // degrees per dragged px
		orbit_glide : .86, // release momentum kept per frame
	};
	return _c;
}
