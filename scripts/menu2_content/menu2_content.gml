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
	menu2_button("upgrades",     function() { upgrades_open(); }, c_lavender); // myriad (an overlay, 2026-09-12)
	menu2_button("tiles",        function() { tiles_open(); },     c_aqua);        // myriad (an overlay, 2026-09-12)
	menu2_button("abilities",    function() { abilities_open(); }, c_rarity_epic); // techdemo (an overlay, 2026-09-12)
	menu2_button("automation",   function() { automation_open(); }, c_sblue);
	menu2_button("time bank",    function() { timebank_open(); }, c_gold);
	menu2_button("battery",      function() { battery_open(); },  c_sgreen);   // the offline budget + the crank
	menu2_button("credit core",  function() { ccore_open(); },    c_lavender); // DE's credit farm, the well of credits
	// the line says when a gift is waiting - the menu rebuilds on every
	// open, so the label is live (Techdemo II's calendar, ported)
	menu2_button(gift_can_claim() ? "daily gift  -  ready" : "daily gift",
		function() { gift_open(); }, c_pink);
	// an OVERLAY now, so it is a method destination: syst_menu2 folds the
	// drawer and runs the closure instead of changing room
	menu2_button("statistics",   function() { statistics_open(); }, c_sgreen);
	menu2_button("titlescreen",  rm_titlescreen,   c_gray);
	menu2_button("quit",         rm_quit,          c_hred);    // myriad

	menu2_section("misc");
	menu2_button("number formats", rm_numfmt,      c_gold);   // the comparison table (his ask)
	menu2_button("gamepad",      rm_gamepad,       c_steelblue);
	menu2_button("services",     rm_services,      c_seagreen);
	menu2_button("saves",        rm_saves,         c_pink);
	menu2_button("mandelbrot",   rm_mandel,        c_lavender);
	menu2_button("faq",          function() { faq_open(); }, c_gold);
}
