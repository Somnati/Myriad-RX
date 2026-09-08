// EVERY ROOM STARTS EMPTY (his report: sparks from the dial hall
// reappeared on the next screen). The object is persistent - the POOL
// is what persists, so that a burst never has to allocate - but a spark
// is a thing that happened at a place in a room, and the place stops
// existing when the room does. Dropping the count is the whole reset:
// the structs stay where they are, ready to be filled again.
n  = 0;
wr = 0;
