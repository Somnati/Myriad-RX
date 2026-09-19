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

	// ⚖️ THE MENU UNFOLDS (his spec, 2026-09-13): a line exists once its
	// feature has arrived (unfold_has / unfold_config). The menu rebuilds
	// on every open, so a feature that unfolded a second ago is here
	// a line whose feature has unfolded and not been visited yet pulses
	// "new" beside its name (DE's ability-slot pulse, drawn by syst_menu2
	// off the key here) until its panel is opened (unfold_tick)

	menu2_section("game");
	menu2_button("clicker",      rm_clicker,       c_feat_clicker);
	if (!is_undefined(objective_cur()))   // the chain, in full - and gone once it is complete (his ask, 2026-09-14)
		menu2_button("objectives",   function() { objectives_open(); }, c_feat_objectives);
	if (unfold_has("rebirth"))    menu2_button("rebirth",      function() { rebirth_open(); }, c_feat_rebirth, "rebirth"); // myriad
	if (unfold_has("cheat"))      menu2_button("cheat shop",   function() { cheat_open(); },   c_feat_cheat, "cheat");   // disgaea's obtain rates (2026-09-13)
	if (unfold_has("upgrades"))   menu2_button("upgrades",     function() { upgrades_open(); }, c_feat_upgrades, "upgrades"); // myriad (an overlay, 2026-09-12)
	if (unfold_has("tiles"))      menu2_button("tiles",        function() { tiles_open(); },     c_feat_tiles, "tiles");        // myriad (an overlay, 2026-09-12)
	if (unfold_has("abilities"))  menu2_button("abilities",    function() { abilities_open(); }, c_feat_abilities, "abilities");   // DE: gold // techdemo (an overlay, 2026-09-12)
	if (unfold_has("automation")) menu2_button("automation",   function() { automation_open(); }, c_feat_automation, "automation");
	if (unfold_has("timebank"))   menu2_button("time bank",    function() { timebank_open(); }, c_feat_timebank, "timebank");
	// THE SPRITE MENU, in the main set (his call, 2026-09-17: "not in misc"): the
	// roster's manager sits with the game's own features, expeditions right under it
	if (unfold_has("sprites"))    menu2_button("sprites",      function() { exped_open("sprites"); }, c_feat_expeditions, "sprites");
	if (unfold_has("expeditions")) menu2_button("expeditions",  function() { exped_open(); }, c_feat_expeditions, "expeditions");   // (below sprites, in the main set - his call 2026-09-18; it sat in misc since 09-13)
	if (unfold_has("expeditions")) menu2_button("arena",        rm_arena,         c_feat_expeditions);   // THE ARENA (q246): a practice fight, turn by turn, nothing kept
	// (the battery, the credit core, statistics and the daily gift are DOCK
	// icons now - obj_ui_gear, beside the settings gear, 2026-09-13)
	// an OVERLAY now, so it is a method destination: syst_menu2 folds the
	// drawer and runs the closure instead of changing room
	menu2_button("titlescreen",  rm_titlescreen,   c_gray);
	menu2_button("quit",         rm_quit,          c_hred);    // myriad

	menu2_section("misc");
	menu2_button("number formats", rm_numfmt,      c_gold);   // the comparison table (his ask)
	menu2_button("gamepad",      rm_gamepad,       c_steelblue);
	menu2_button("services",     rm_services,      c_seagreen);
	menu2_button("saves",        rm_saves,         c_pink);
	menu2_button("faq",          function() { faq_open(); }, c_gold);
	if (unfold_has("dimensions")) menu2_button("dimensions",   rm_dimensions,    c_hpurple, "dimensions");   // THE DIMENSIONS (the antimatter cascade, ported 2026-09-18: stand-alone, behind its unfold key - F10 grants it; in misc - his call 2026-09-18)
	if (unfold_has("offlog"))      menu2_button("offline log",  function() { offlog_open(); }, c_feat_offlog, "offlog");   // every absence's story (2026-09-12)
}
