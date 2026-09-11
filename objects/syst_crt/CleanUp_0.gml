if (surface_exists(scratch)) surface_free(scratch);
if (surface_exists(bright)) surface_free(bright);
for (var _i = 0; _i < array_length(bloom_ch); _i++)
	if (surface_exists(bloom_ch[_i])) surface_free(bloom_ch[_i]);
