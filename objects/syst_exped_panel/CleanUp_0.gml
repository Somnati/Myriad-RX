/// the world box's surface goes with the panel
if (surface_exists(wb_surf)) surface_free(wb_surf);
wb_surf = -1;
if (surface_exists(sky_fog_surf)) surface_free(sky_fog_surf);
sky_fog_surf = -1;
if (surface_exists(gx_mm)) surface_free(gx_mm);
gx_mm = -1;
if (surface_exists(gx_glow_a)) surface_free(gx_glow_a);
if (surface_exists(gx_glow_b)) surface_free(gx_glow_b);
gx_glow_a = -1; gx_glow_b = -1;
if (surface_exists(log_surf)) surface_free(log_surf);
log_surf = -1;
if (instance_exists(sb)) instance_destroy(sb);
__hand_close();
if (instance_exists(turn_px)) instance_destroy(turn_px);
