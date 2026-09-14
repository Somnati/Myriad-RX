
// (and never for an owner that died this frame - the Step's kill lands next step)
if (fn != -1 && (owner == noone || instance_exists(owner))) fn(); // the bound method runs in the OWNER's scope
