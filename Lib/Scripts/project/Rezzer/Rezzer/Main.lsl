// config file name
string CONFIG_FILE = "CONFIG";

// failure text
string CODE_NODES = "#";

// split text
string CODE_SPLIT = " ";

// config file request handle
key CONFIG_FILE_REQUEST_KEY = NULL_KEY;

// config file current read line
integer CONFIG_FILE_CURRENT_LINE = 0;

// config file total number of lines
integer CONFIG_FILE_NUM_LINES = 0;

// config file all data
list CONFIG_FILE_DATA = [];

// config data
list CONFIG_DATA = [];

// Self Position
vector SELF_POS = <0,0,0>;

// Self Rotation
rotation SELF_ROT;

string REZ_NAME;
vector REZ_POS;
vector REZ_VEL;
rotation REZ_ROT;

// default state
default{
    state_entry() {
        state init;
    }
}

state init{
    state_entry() {
        if(INVENTORY_NOTECARD != llGetInventoryType(CONFIG_FILE)){
            state error;
        }
        CONFIG_FILE_NUM_LINES = 0;
        CONFIG_FILE_CURRENT_LINE = 0;
        CONFIG_FILE_REQUEST_KEY = NULL_KEY;
        llSetText("initialising...", <1, 1, 1>, 0);
        CONFIG_FILE_REQUEST_KEY = llGetNumberOfNotecardLines(CONFIG_FILE);
        
        llSetTimerEvent(5.000);
    }
    
    timer() {
        llSetTimerEvent(0.000);
        state error;
    }
    
    dataserver(key requested, string data) {
        // make sure it's an answer to a question we asked - this should be an unnecessary check
        if (requested == CONFIG_FILE_REQUEST_KEY) {
            // at least one line, so don't worry any more
            llSetTimerEvent(0.000);
            if (data == EOF) { // end of the notecard, change to ready state
                state ready;
            } else if (CONFIG_FILE_NUM_LINES == 0) { // first request is for the number of lines
                CONFIG_FILE_NUM_LINES = (integer)data;
                CONFIG_FILE_REQUEST_KEY = llGetNotecardLine(CONFIG_FILE, CONFIG_FILE_CURRENT_LINE); // now get the first line
            } else {
                if (data != "" && llGetSubString(data, 0, 0) != CODE_NODES) { // ignore empty lines, or lines beginning with "#"
                    data = llStringTrim(data, STRING_TRIM);
                    CONFIG_FILE_DATA = CONFIG_FILE_DATA + [data];
                }
                ++ CONFIG_FILE_CURRENT_LINE;
                CONFIG_FILE_REQUEST_KEY = llGetNotecardLine(CONFIG_FILE, CONFIG_FILE_CURRENT_LINE); // ask for the next line
            }
        }
        // update the hover-text with the progress
        llSetText("Loading... " + (string)(CONFIG_FILE_CURRENT_LINE) + "/" + (string)CONFIG_FILE_NUM_LINES, <1, 1, 1>, 1);
    }
    
    state_exit() {
        llSetText("", <0,0,0>, 1);
    }
}

state error{
    state_entry() {
        llOwnerSay("Something went wrong! try checking that the notecard of config file [ " + CONFIG_FILE + " ] exists and contains data.");
    }
    
    changed(integer change) {
        if (change & CHANGED_INVENTORY) {
            llResetScript();
        }
    }
}

state ready{
    state_entry() {
        state main;
    }
}

state main{
    state_entry() {
        //llOwnerSay((string)CONFIG_FILE_DATA);
    }

    touch_start(integer total_number) {
        SELF_POS = llGetPos();
        SELF_ROT = llGetRot();
        
        integer len = llGetListLength(CONFIG_FILE_DATA);
        integer i = 0;
        list F;
        for(; i<len; i++){
            F = llParseString2List(llList2String(CONFIG_FILE_DATA, i), [" "], []);
            llOwnerSay((string)F);
            if(3 < llGetListLength(F)){
                REZ_NAME = llList2String(F,0);
                REZ_POS = SELF_POS + (vector)llList2String(F,1)*SELF_ROT;
                REZ_VEL = (vector)llList2String(F,2)*SELF_ROT;
                REZ_ROT = (rotation)llList2String(F,3)*SELF_ROT;
                                
                llRezAtRoot(REZ_NAME, REZ_POS, REZ_VEL, REZ_ROT, 10);
                llOwnerSay(REZ_NAME + " has been rezed");
            }
        }
    }
    
    changed(integer change) {
        if (change & (CHANGED_INVENTORY)) { // if someone edits the card, reset the script
            llResetScript();
        }
    }
}
