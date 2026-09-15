/// @description page_surface(w, h) -> a page surface: 16-bit float where the gpu allows (page_float), 8-bit otherwise
function page_surface(_w, _h) {
	return page_float() ? surface_create(_w, _h, surface_rgba16float) : surface_create(_w, _h);
}
