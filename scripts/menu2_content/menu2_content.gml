/// @description menu2_content() - THE menu, declared as calls (the
/// same authoring pattern as stats_v2_content: adding a destination is
/// one line, sections are one line). consumed by syst_menu2 on spawn.
/// MYRIAD RX (fresh foundation, 2026-08-14): engine destinations only.
/// Every DE system rebuilt onto RX adds its line here as it lands -
/// COLOR LAW carried from the techdemo pass: mechanics that exist in
/// Myriad DE wear MYRIAD'S menu colors (source: DE's
/// obj_button_suboptions Step_0 name->col block) - tiles aqua,
/// ability deck gold, statistics sgreen, quit red, gear orange,
/// upgrades lavender.
function menu2_content() {

	menu2_section("game");
	menu2_button("clicker",      rm_clicker,       c_horange);
	menu2_button("rebirth",      function() { rebirth_open(); }, c_hred); // myriad
	menu2_button("upgrades",     rm_upgrades,      c_lavender); // myriad
	menu2_button("tiles",        rm_tiles,         c_aqua);     // myriad
	menu2_button("abilities",    rm_abilitydeck,   c_rarity_epic); // techdemo
	menu2_button("automation",   rm_automation,    c_sblue);
	menu2_button("time bank",    rm_timebank,      c_gold);
	menu2_button("statistics",   rm_statistics_v2, c_sgreen);  // myriad
	menu2_button("titlescreen",  rm_titlescreen,   c_gray);
	menu2_button("quit",         rm_quit,          c_hred);    // myriad

	menu2_section("misc");
	menu2_button("gamepad",      rm_gamepad,       c_steelblue);
	menu2_button("services",     rm_services,      c_seagreen);
	menu2_button("saves",        rm_saves,         c_pink);
	menu2_button("mandelbrot",   rm_mandel,        c_lavender);
}
