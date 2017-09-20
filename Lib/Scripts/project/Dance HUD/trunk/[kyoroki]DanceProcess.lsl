integer SELF;
integer CHANNEL = -1;
string TIPS;
string A;
key U;

reset(){
    A = "";
    U = NULL_KEY;
}

//change animation
changeAnimation(key uuid, string name){
    list ani = llGetAnimationList(uuid);
    integer len = llGetListLength(ani);
    while(~len){
        llStopAnimation(llList2Key(ani, --len));
    }
    if(name != ""){
        llStartAnimation(name);
        llOwnerSay((string)uuid + " start dance " + name);
    }
    if(TIPS != ""){
        llRegionSayTo(uuid, 0, TIPS);
    }
}

default{
    state_entry() {
        SELF = (integer)llGetSubString(llGetScriptName(), 3, -1);
        reset();
    }
    
    link_message(integer sender_number, integer number, string message, key id) {
        if(CHANNEL < 0){ //initialize channel
            CHANNEL = number;
        } else if(number == CHANNEL){
            reset();
            list l = llCSV2List(message);
            if(SELF < llGetListLength(l) - 2){
                TIPS = llUnescapeURL(llList2String(l, 0));
                A = llList2String(l, 1);
                U = llList2Key(l, SELF + 2);
                if(U != NULL_KEY){
                    llRequestPermissions(U, PERMISSION_TRIGGER_ANIMATION);
                }
            }
        }
    }
    
    run_time_permissions(integer permissions) {
        if(U == llGetPermissionsKey()){
            changeAnimation(U, A);
        }
        reset();
    }
    
    on_rez(integer start_param) {
        llResetScript();
    }
}