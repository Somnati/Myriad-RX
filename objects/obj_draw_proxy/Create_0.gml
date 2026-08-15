/// a draw slot at a depth of the owner's choosing: draws NOTHING of
/// its own, just runs the bound method. exists because an instance
/// only gets ONE normal-pass draw at ONE depth, and screens like
/// statistics/settings need rows < widgets < pinned strip < menu -
/// four depths, one controller. (draw begin/end passes can't do this:
/// begin is painted over by the room's BACKGROUND layers, end paints
/// over the open menu drawer. depth stacking is the only correct way.)
/// usage (owner side):
///   var _px = create_obj(0, 0, obj_draw_proxy);
///   _px.owner = id;
///   _px.depth = depth - 2;       // wherever the slot belongs
///   _px.fn    = __draw_strip;    // a method bound to the owner

owner = noone;
fn    = -1;
