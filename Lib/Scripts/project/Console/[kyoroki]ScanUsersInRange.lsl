// Scan user in range
// @author kyoroki

list userList = [];
list rangeList = [];
list countList = [];

float detectionRange = 94.0;
float detectionInterval = 5;

integer isSensor = 0;

//Returns a string that contains the float num in a tidy text format, with optional rounding.
//• float     num     –     number to be formatted    
//• integer     places     –     number of places to use during formatting    
//• integer     rnd     –     boolean, enables/disables rounding    
//Negative floats are fine (i.e. negative signs will be preserved.)
//If you say 1 place, you will get 7.0 instead of 7.0000000
//If you say 3 places, you get 7.14 instead of 7.1400000
//7.1373699 will come out as 7.13 or 7.14, depending on whether you specify rounding
//rnd (rounding) should be set to TRUE for Rounding, FALSE for no rounded
//Example:
//string myFormattedFloat = Float2String(-7.1373699, 3, TRUE);
//rounded returns -7.14
//string myFormattedFloat = Float2String(-7.1373699, 3, FALSE);
//not rounded returns -7.13
string Float2String(float num, integer places, integer rnd) {
    if (rnd) {
        float f = llPow( 10.0, places );
        integer i = llRound(llFabs(num) * f);
        string s = "00000" + (string)i; // number of 0s is (value of max places - 1 )
        if(num < 0.0)
            return "-" + (string)( (integer)(i / f) ) + "." + llGetSubString( s, -places, -1);
        return (string)( (integer)(i / f) ) + "." + llGetSubString( s, -places, -1);
    }
    if (!places)
        return (string)((integer)num );
    if ( (places = (places - 7 - (places < 1) ) ) & 0x80000000)
        return llGetSubString((string)num, 0, places);
    return (string)num;
}

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

// return a list of one list elements not in other list
list ListXnotY(list lx, list ly) {// return elements in X list that are not in Y list
    list lz = [];
    integer i = 0;
    integer n = lx != []; list t;
    for (; i < n; i++) 
        if (!~llListFindList(ly, (t = llList2List(lx, i, i)))) lz += t; //Note *
    return lz;
}

// get a new list of all users in range
list getUserList(integer detected){
    integer counter = 0;
    list nl = [];
    for(;counter < detected; counter++){
        nl += [llDetectedKey(counter)];
    }
    return nl;
}

// get range between you and the others
list getRangeList(integer detected){
    integer counter = 0;
    list nl = [];
    for(;counter < detected; counter++){
        nl += [llVecDist(llDetectedPos(counter), llGetPos())];
    }
    return nl;
}

list getCountList(integer detected){
    integer counter = 0;
    list nl = [];
    for(;counter < detected; counter++){
        nl += [0];
    }
    return nl;
}

// use map to change element of new list form old list
list updateListByMap(list ol, list nl, list mapO, list mapN){
    integer keyO;
    integer keyN;
    integer i = 0;
    integer len = llGetListLength(mapO);
    if(len > 0){
        for(; i<len; i++){
            keyO = llList2Integer(mapO, i);
            keyN = llList2Integer(mapN, i);
            nl = llListReplaceList(nl, llList2List(ol, keyO, keyO), keyN, keyN);
        }
    }
    return nl;
}

// create map
list createMapByKey(list l1, list l2){
    integer i=0;
    integer len = llGetListLength(l1);
    integer u;
    list map = [];
    for(; i<len; i++){
        u = llListFindList(l2, [llList2Key(l1, i)]);
        if(~u){
            map += [u];
        }
    }
    return map;
}

// output by "llOwnerSay"
logList(list l, string n){
    string s = "";
    integer i = 0;
    integer len = llGetListLength(l);
    for(; i<len; i++){
        s += "\n ["+llList2String(l, i)+"] ";
    }
    llOwnerSay(n + s);
}

// main void, update all list data
updateDateList(integer detected){
    list newUserList = getUserList(detected);
    list uHold = ListXandY(userList, newUserList);
    
    list newRangeList = getRangeList(detected);
    list newCountList = getCountList(detected);
    
    list mapO = createMapByKey(uHold, userList);
    list mapN = createMapByKey(uHold, newUserList);
    
    //userList = updateListByMap(userList, newUserList, mapO, mapN);
    //rangeList = updateListByMap(rangeList, newRangeList, mapO, mapN);
    userList = newUserList;
    rangeList = newRangeList;
    
    countList = updateListByMap(countList, newCountList, mapO, mapN);
    
    //Display change
    //logList(userList, "userList: ");
    //logList(rangeList, "rangeList: ");
}

resetList(){
    userList  = [];
    rangeList = [];
    countList = [];
}

// output by "llSetText"
displayUserListByText(){
    string str = "[Range:94][Person:"+(string)llGetListLength(userList)+"]";
    integer i;
    integer len = llGetListLength(userList);
    for(i=0; i<len; i++){
        str += "\n " + llGetSubString(llGetDisplayName(llList2Key(userList, i)), 0, 4) + "..." + " ("+Float2String(llList2Float(rangeList, i), 2, TRUE)+"m)";
    }
    llSetText(str, <0.6, 1.0, 1.0>, 1.0);
}

default{
    state_entry() {
        resetList();
        //llSensor("", NULL_KEY, AGENT, detectionRange, PI);
        llSensorRepeat("", NULL_KEY, AGENT, detectionRange, PI, detectionInterval);
        //llSetTimerEvent(detectionInterval);
    }
    
    touch_start(integer total_number) {
        logList(userList, "userList: ");
    }
    
    sensor(integer detected){
        updateDateList(detected);
        displayUserListByText();
    }
    
    no_sensor(){
        resetList();
        displayUserListByText();
    }
    
    on_rez(integer start_param){
        llResetScript();
    }
}