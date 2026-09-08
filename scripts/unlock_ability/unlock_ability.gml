/// @description unlock_ability("name", rarity) -> 100 (the "new"
/// state). the discovery moment: rarity-tiered sound + the deck
/// room's reveal card. discoveries made outside the room still land,
/// just quietly (the badge waits in the list).
function unlock_ability(_nm, _rarity) {
	var _col = c_white;
	var _rtxt = "";
	if (_rarity == 1) { _col = rgb(60, 255, 69);   _rtxt = "uncommon"; }
	if (_rarity == 2) { _col = rgb(65, 122, 255);  _rtxt = "rare"; }
	if (_rarity == 3) { _col = rgb(255, 167, 10);  _rtxt = "legendary"; }
	if (_rarity == 4) { _col = rgb(160, 32, 255);  _rtxt = "epic"; }

	if (_rarity == 0) play_sound_ext(snd_ability_common, .9, 1.1, 1, 2);
	if (_rarity == 1) play_sound_ext(snd_ability_uncommon, .9, 1.1, 1, 2);
	if (_rarity == 2) play_sound_ext(snd_ability_rare, .9, 1.1, 1, 2);
	if (_rarity == 3) play_sound_ext(snd_ability_legendary, .9, 1.1, 1, 2);
	if (_rarity == 4) play_sound_ext(snd_ability_epic, .9, 1.1, 1, 2);

	if (instance_exists(syst_rm_ability))
	with (syst_rm_ability) {
		reveal_name = _nm;
		reveal_col  = _col;
		reveal_rtxt = _rtxt;
		reveal_t    = 150;
	}

	return 100;
}
