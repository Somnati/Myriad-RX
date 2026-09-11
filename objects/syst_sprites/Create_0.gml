/// syst_sprites - THE SPRITES' RUNNER. Persistent, made by setgame
/// after the tube. Two jobs: run their headless work everywhere
/// (sprites_tick), and give every sprite a body in the money room - an
/// obj_blob per struct, made on arrival, gone with the room. The blob
/// is the VIEW and the live executor of that sprite; the struct is the
/// truth (g.sprites, saved).
persistent = true;
