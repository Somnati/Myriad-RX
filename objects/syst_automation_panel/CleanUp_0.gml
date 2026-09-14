/// an overlay takes its furniture with it: the bar, and an open dropdown
if (instance_exists(sb)) instance_destroy(sb);
with (obj_pillbox) if (obj == other.id) instance_destroy();
