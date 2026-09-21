/// @description delta_cost(d, what) -> the grain a thing costs (-1 = none left to buy): rain / springs / rich / seed / levee / channel / flood / valley
function delta_cost(_d, _what) {
	switch (_what) {
		case "rain":    return round(30 * power(1.7, _d.rain - 1));
		case "springs": return (_d.springs >= 3) ? -1 : ((_d.springs == 1) ? 400 : 6000);
		case "rich":    return round(80 * power(1.8, _d.rich - 1));
		case "seed":    return (_d.seed >= 3) ? -1 : [150, 2500, 40000][_d.seed];
		case "levee":   return round(12 * power(1.15, _d.nlev));
		case "channel": return round(10 * power(1.15, _d.nchan));
		case "flood":   return round(60 * power(1.5, _d.floods));
		case "valley":  { var _st = delta_stats(_d); return (_st.newland >= _st.sea0n * .6) ? 0 : -1; }   // THE NEXT VALLEY (the prestige): free, once six tenths of the sea is land
	}
	return -1;
}
