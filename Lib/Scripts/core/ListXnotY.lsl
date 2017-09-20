// return a list of one list elements not in other list
list ListXnotY(list lx, list ly) {// return elements in X list that are not in Y list
    list lz = [];
    integer i = 0;
    integer n = lx != []; list t;
    for (; i < n; i++) 
        if (!~llListFindList(ly, (t = llList2List(lx, i, i)))) lz += t; //Note *
    return lz;
}