/// @description galaxy_region_name() -> a named neighbourhood of the galaxy (the tech demo's gen_name_region)
function galaxy_region_name() {
	var _base = gen_name_planet();
	var _roll = irandom(21);
	switch (_roll) {
		case 0:  return _base + " Adjunct";
		case 1:  return _base + " Void";
		case 2:  return _base + " Expanse";
		case 3:  return _base + " Terminus";
		case 4:  return _base + " Boundary";
		case 5:  return _base + " Fringe";
		case 6:  return _base + " Cluster";
		case 7:  return _base + " Mass";
		case 8:  return _base + " Band";
		case 9:  return _base + " Cloud";
		case 10: return _base + " Nebula";
		case 11: return _base + " Quadrant";
		case 12: return _base + " Sector";
		case 13: return _base + " Anomaly";
		case 14: return _base + " Conflux";
		case 15: return _base + " Instability";
		case 16: return "Sea of " + _base;
		case 17: return "The Arm of " + _base;
		case 18: return _base + " Spur";
		case 19: return _base + " Shallows";
		default: return _base;
	}
}
