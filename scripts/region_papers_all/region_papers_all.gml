/// @description region_papers_all(dest, region) - every node's papers made (region_node_info caches on the node)
/// Called BEFORE a seeded section that reads the folk's names
/// (exped_quest_gen): the papers roll their names under a seed of their
/// own and leave through rng_release - a FRESH seed - which, inside a
/// deterministic deal, would send every roll after it somewhere else
/// (the offers re-deal from their salts on load and would change).
/// Cached nodes cost nothing here.
function region_papers_all(_d, _rg) {
	for (var _i = 0; _i < array_length(_rg.nodes); _i++) region_node_info(_d, _rg, _i);
}
