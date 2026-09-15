/// @description exped_quest_life() -> seconds a fresh quest slot lives (EXPED_QUEST_LIFE_LO..HI)
function exped_quest_life() {
	return random_range(EXPED_QUEST_LIFE_LO, EXPED_QUEST_LIFE_HI);
}
