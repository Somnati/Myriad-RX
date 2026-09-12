/// @description specifics
// MYRIAD RX: engine lanes only (statistics + settings). a rebuilt DE
// room that scrolls adds its lane here + Step_0, same pattern.

if i = scrl_statistics
	if not instance_exists(syst_statistics_v2)
kill;

if i = scrl_settings
	if not instance_exists(syst_settings)
kill;

if i = scrl_abilitydeck
	if not instance_exists(syst_rm_ability)
kill;

if i = scrl_menu2
	if not instance_exists(syst_menu2)
kill;

if i = scrl_stats_rail
	if not instance_exists(syst_statistics_v2)
kill;

if i = scrl_faq
	if not instance_exists(syst_faq)
kill;
