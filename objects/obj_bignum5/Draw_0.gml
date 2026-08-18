/// the whole visualiser. Drawn in the NORMAL draw pass (not Draw
/// Begin, which runs before layers and lost to the room's black
/// Background layer), so this object's depth arbitrates it.
/// everything positional derives from this frame's values - pure.

vis.draw();
