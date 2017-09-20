// return a list of elements common to both lists
list ListXandY(list lx, list ly) {
    list lz = [];
    integer x;
    for (x = 0; x < llGetListLength(ly); x++) {
        if (~llListFindList(lx,llList2List(ly,x,x))) {
            lz = lz + llList2List(ly,x,x);
        }
    }
    return lz;
}