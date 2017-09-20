//Config

// version
string VERSION = "1.2 Alpha";

// failure text
string CODE_NODES = "#";

// split text
string CODE_SPLIT = " ";

// config file name
string CONFIG_FILE = "config";

// config file request handle
key CONFIG_FILE_REQUEST_KEY = NULL_KEY;

// config file current read line
integer CONFIG_FILE_CURRENT_LINE = 0;

// config file total number of lines
integer CONFIG_FILE_NUM_LINES = 0;

// config file all data
list CONFIG_FILE_DATA = [];

// config file all data rule
list CONFIG_FILE_DATA_RULE = [];

// config data
list CONFIG_DATA = [];

// config data rule
list CONFIG_DATA_RULE = [
    "TMP_DEFAULT", //0
    "TMP_PREV", //1
    "TMP_NEXT", //2
    "TMP_STOP", //3
    "TMP_RANDOM", //4
    "TMP_RETURN", //5
    "TMP_ALL", //6
    "TMP_SELF", //7
    "TMP_INVITE", //8
    "TMP_SETTING", //9
    "DIALOG_PREPAGE", //10
    "CHANNEL", //11
    "USER_DETECT_RANGE", //12
    "USER_DETECT_INTERVAL", //13
    "USER_DETECT_MAX", //14
    "TIPS_STARTDANCE", //15
    "TMP_COMMAND_STOP", //16
    "TIPS_STOPDANCE", //17
    "TMP_LEAD" //18
];

// Copy configuration template
string TMP_EMPTY   = "";
string TMP_EXTEND  = "#EXTEND#";

// Can be replaced
string TMP_DEFAULT      = "-"; //0
string TMP_PREV         = "<<PREV"; //1
string TMP_NEXT         = "NEXT>>"; //2
string TMP_STOP         = "STOP"; //3
string TMP_RANDOM       = "RANDOM"; //4
string TMP_RETURN       = "RETURN"; //5
string TMP_ALL          = "ALL"; //6
string TMP_SELF         = "SELF"; //7
string TMP_INVITE       = "INVITE"; //8
string TMP_SETTING      = "SETTING"; //9
string TMP_COMMAND_STOP = "stop"; //16
string TMP_LEAD         = "LEAD"; //18
string TMP_SETRANGE     = "SETRANGE";
string TMP_SETUSER      = "SETUSER";
string TMP_SYNC         = "SYNC";
string TMP_CHANGE       = "CHANGE";

integer DIALOG_PREPAGE = 12; //10
//channel num
integer CHANNEL = 8800; //11
integer CHANNEL_REPORT;

integer USER_DETECT_RANGE = 20; //12
float USER_DETECT_INTERVAL = 5.000; //13
integer USER_DETECT_MAX = 0; //14

//Global
integer LISTEN_HANDLE;

//owner state
string STATE;
string STATE_PREPARE  = TMP_EMPTY;
string STATE_NORMAL   = "normal";
string STATE_DANCING  = "dancing";
string STATE_LEADING  = "leading";

//menu state
string STATE_MENU;
string STATE_MENU_MAIN        = "main";
string STATE_MENU_USER        = "user";
string STATE_MENU_ANIMATION   = "animation";
string STATE_MENU_SETTING     = "setting";
string STATE_MENU_LEADER      = "leader";
string STATE_MENU_LEADING     = "leading";
string STATE_MENU_DANCING     = "dancing";
string STATE_MENU_SETMAXUSER  = "setmaxuser";
string STATE_MENU_SETMAXRANGE = "setmaxrange";

integer CURRENT_PAGE = 0;

string TIPS_STARTDANCE = "You can enter \"/#{CHANNEL} #{COMMAND}\" to stop dancing."; //15
string TIPS_STOPDANCE  = "You have stopped dancing.\n If you still can't stop, please move a little step."; //17

key OWNER;

list LIST_ANIMATION = [];
list LIST_ANIMATION_DISPLAY = [];

list LIST_USER = [];
list LIST_USER_DISPLAY = [];
list LIST_USER_QUEUE = [];

list SELECT_USER = [];
list SELECTED_USER = [];
string SELECT_ANIMATION = TMP_EMPTY;
string SELECTED_ANIMATION = TMP_EMPTY;

__METHOD__(){}

regionSayToAll(list users, string message){
	integer len = llGetListLength(users);
	while(~len){
		llRegionSayTo(llList2Integer(users, --len), 0, message);
	}
}

// create random number
integer randomInteger(integer min, integer max){
    return min + (integer)( llFrand( max - min ) );
}

// check that that the named inventory item is a notecard
integer isNoteCard(string name) {
    return INVENTORY_NOTECARD == llGetInventoryType(name);
}

// replace a string in the resource string
string stringReplace(string res, string find, string replace){
    list l = llParseString2List(res, [find], []);
    if(llGetListLength(l) > 1){
        res = llDumpList2String(l, replace);
    }
    return res;
}

// replace all strings in the resource string
string stringReplaceAll(string res, list find, list replace){
    integer len = llGetListLength(find);
    integer i = 0;
    for(; i<len; i++){
        res = (res = "") + stringReplace(res, llList2String(find, i), llList2String(replace, i));
    }
    return res;
}

// add a member to resource list
list listAdd(list res, list mem){
    if(!~llListFindList(res, mem)){
        return res + mem;
    }
    return res;
}

// return a list of one list elements not in other list
list ListXnotY(list lx, list ly) {
    list lz = [];
    integer i = 0;
    integer n = lx != []; list t;
    for (; i < n; i++) 
        if (!~llListFindList(ly, (t = llList2List(lx, i, i)))) lz += t; //Note *
    return lz;
}

parseConfig(){
    CONFIG_DATA = [];
    integer len = llGetListLength(CONFIG_DATA_RULE);
    if(len > 0){
        integer i = 0;
        integer a;
        while(i < len){
            a = llListFindList(CONFIG_FILE_DATA_RULE, llList2List(CONFIG_DATA_RULE, i, i));
            if(~a){
                CONFIG_DATA = (CONFIG_DATA = []) + CONFIG_DATA + llList2List(CONFIG_FILE_DATA, a, a);
            } else {
                CONFIG_DATA = (CONFIG_DATA = []) + CONFIG_DATA + [TMP_EXTEND];
            }
            i ++;
        }
        
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 0))  TMP_DEFAULT = llList2String(CONFIG_DATA, 0);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 1))  TMP_PREV = llList2String(CONFIG_DATA, 1);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 2))  TMP_NEXT = llList2String(CONFIG_DATA, 2);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 3))  TMP_STOP = llList2String(CONFIG_DATA, 3);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 4))  TMP_RANDOM = llList2String(CONFIG_DATA, 4);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 5))  TMP_RETURN = llList2String(CONFIG_DATA, 5);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 6))  TMP_ALL = llList2String(CONFIG_DATA, 6);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 7))  TMP_SELF = llList2String(CONFIG_DATA, 7);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 8))  TMP_INVITE = llList2String(CONFIG_DATA, 8);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 9))  TMP_SETTING = llList2String(CONFIG_DATA, 9);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 10)) DIALOG_PREPAGE = llList2Integer(CONFIG_DATA, 10);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 11)) CHANNEL = llList2Integer(CONFIG_DATA, 11);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 12)) USER_DETECT_RANGE = llList2Integer(CONFIG_DATA, 12);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 13)) USER_DETECT_INTERVAL = llList2Float(CONFIG_DATA, 13);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 14)) USER_DETECT_MAX = llList2Integer(CONFIG_DATA, 14);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 15)) TIPS_STARTDANCE = llList2String(CONFIG_DATA, 15);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 16)) TMP_COMMAND_STOP = llList2String(CONFIG_DATA, 16);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 17)) TIPS_STOPDANCE = llList2String(CONFIG_DATA, 17);
        if(TMP_EXTEND != llList2String(CONFIG_DATA, 18)) TMP_LEAD = llList2String(CONFIG_DATA, 18);
    }
}

__MENU__(){}

// show main menu
menuMain(key uuid){
    STATE_MENU = STATE_MENU_MAIN;
    list btns = [];
    if(TMP_SELF != TMP_EMPTY) btns = (btns = []) + btns + [TMP_SELF];
    if(TMP_INVITE != TMP_EMPTY) btns = (btns = []) + btns + [TMP_INVITE];
    if(TMP_LEAD != TMP_EMPTY) btns = (btns = []) + btns + [TMP_LEAD];
    if(TMP_SETTING != TMP_EMPTY) btns = (btns = []) + btns + [TMP_SETTING];
    llDialog(uuid, "menuMain", btns, CHANNEL);
}

// show animation menu
menuAnimation(key uuid, integer page){
    STATE_MENU = STATE_MENU_ANIMATION;
    list btns = [];
    integer perpage = DIALOG_PREPAGE;
    integer len = llGetListLength(LIST_ANIMATION);
    
    if(TMP_RETURN != TMP_EMPTY){
        btns = (btns = []) + btns + [TMP_RETURN];
        perpage--;
    }
        
    if(len > 0){
        if(TMP_PREV != TMP_EMPTY){
            if(page == 0){ //first page
                btns = (btns = []) + [TMP_DEFAULT] + btns;
            } else {
                btns = (btns = []) + [TMP_PREV] + btns;
            }
            perpage--;
        }
        if(TMP_NEXT != TMP_EMPTY){
            if(page >= len / perpage){ //last page
                btns = (btns = []) + btns + [TMP_DEFAULT];
            } else {
                btns = (btns = []) + btns + [TMP_NEXT];
            }
            perpage--;
        }
        if(TMP_RANDOM != TMP_EMPTY){
            btns = (btns = []) + btns + [TMP_RANDOM];
            perpage--;
        }
        btns = (btns = []) + btns + llList2List(LIST_ANIMATION_DISPLAY, page * perpage, (page + 1) * perpage - 1);
    }
    //logList(currentPageList, "currentPageList:");
    llDialog(uuid, "menuAnimation", btns, CHANNEL);
}

// show user menu
menuUser(key uuid, integer page){
    STATE_MENU = STATE_MENU_USER;
    list btns = [];
    integer perpage = DIALOG_PREPAGE;
    integer len = llGetListLength(LIST_USER);
    
    if(TMP_RETURN != TMP_EMPTY){
        btns = (btns = []) + btns + [TMP_RETURN];
        perpage--;
    }
    
    if(len > 0){
        if(TMP_PREV != TMP_EMPTY){
            if(page == 0){ //first page
                btns = (btns = []) + [TMP_DEFAULT] + btns;
            } else {
                btns = (btns = []) + [TMP_PREV] + btns;
            }
            perpage--;
        }
        if(TMP_NEXT != TMP_EMPTY){
            if(page >= len / perpage){ //last page
                btns = (btns = []) + btns + [TMP_DEFAULT];
            } else {
                btns = (btns = []) + btns + [TMP_NEXT];
            }
            perpage--;
        }
        if(TMP_ALL != TMP_EMPTY){
            btns = (btns = []) + btns + [TMP_ALL];
            perpage--;
        }
        btns = (btns = []) + btns + llList2List(LIST_USER_DISPLAY,  page * perpage, (page + 1) * perpage - 1);
    }
    
    llDialog(uuid, "menuUser", btns, CHANNEL);
}

menuSetting(key uuid){
	STATE_MENU = STATE_MENU_SETTING;
	list btns = [];
    if(TMP_RETURN != TMP_EMPTY) btns = (btns = []) + btns + [TMP_RETURN];
    if(TMP_SETRANGE != TMP_EMPTY) btns = (btns = []) + btns + [TMP_SETRANGE];
    if(TMP_SETUSER != TMP_EMPTY) btns = (btns = []) + btns + [TMP_SETUSER];
	llDialog(uuid, "menuSetting", btns, CHANNEL);
}

menuDanceing(key uuid){
	STATE_MENU = STATE_MENU_DANCING;
    list btns = [];
    if(TMP_RETURN != TMP_EMPTY) btns = (btns = []) + btns + [TMP_RETURN];
    if(TMP_LEAD != TMP_EMPTY) btns = (btns = []) + btns + [TMP_LEAD];
    if(TMP_STOP != TMP_EMPTY) btns = (btns = []) + btns + [TMP_STOP];
    llDialog(uuid, "menuDanceing", btns, CHANNEL);
}

menuLeader(key uuid, integer page){
	STATE_MENU = STATE_MENU_LEADER;
	list btns = [];
    integer perpage = DIALOG_PREPAGE;
    integer len = llGetListLength(LIST_ANIMATION);
    
    if(TMP_RETURN != TMP_EMPTY){
        btns = (btns = []) + btns + [TMP_RETURN];
        perpage--;
    }
        
    if(len > 0){
        if(TMP_PREV != TMP_EMPTY){
            if(page == 0){ //first page
                btns = (btns = []) + [TMP_DEFAULT] + btns;
            } else {
                btns = (btns = []) + [TMP_PREV] + btns;
            }
            perpage--;
        }
        if(TMP_NEXT != TMP_EMPTY){
            if(page >= len / perpage){ //last page
                btns = (btns = []) + btns + [TMP_DEFAULT];
            } else {
                btns = (btns = []) + btns + [TMP_NEXT];
            }
            perpage--;
        }
        if(TMP_RANDOM != TMP_EMPTY){
            btns = (btns = []) + btns + [TMP_RANDOM];
            perpage--;
        }
        btns = (btns = []) + btns + llList2List(LIST_ANIMATION_DISPLAY, page * perpage, (page + 1) * perpage - 1);
    }
    
    llDialog(uuid, "menuLeader", btns, CHANNEL);
}

menuLeading(key uuid, integer page){
	STATE_MENU = STATE_MENU_LEADING;
	list btns = [];
    if(TMP_RETURN != TMP_EMPTY) btns = (btns = []) + btns + [TMP_RETURN];
    if(TMP_STOP != TMP_EMPTY) btns = (btns = []) + btns + [TMP_STOP];
    if(TMP_SYNC != TMP_EMPTY) btns = (btns = []) + btns + [TMP_SYNC];
    if(TMP_CHANGE != TMP_EMPTY) btns = (btns = []) + btns + [TMP_CHANGE];
	llDialog(uuid, "menuLeading", btns, CHANNEL);
}

menuSetMaxUser(key uuid){
	STATE_MENU = STATE_MENU_SETMAXUSER;
	list btns = [];
    if(TMP_RETURN != TMP_EMPTY) btns = (btns = []) + btns + [TMP_RETURN];
	llDialog(uuid, "menuSetMaxUser", btns, CHANNEL);
}

menuSetMaxRange(key uuid){
	STATE_MENU = STATE_MENU_SETMAXRANGE;
	list btns = [];
    if(TMP_RETURN != TMP_EMPTY) btns = (btns = []) + btns + [TMP_RETURN];
	llDialog(uuid, "menuSetMaxRange", btns, CHANNEL);
}

__GET__(){}

list getUserQueue(){
	if(LIST_USER_QUEUE != LIST_USER){
		list users = LIST_USER;
		integer nl = users != [];
		integer ol = LIST_USER_QUEUE != [];
		if(nl > 0 && ol > 0){ 
			list newList = ListXnotY(users, LIST_USER_QUEUE);
			nl = newList != [];
			integer i = 0;
			for(;i<ol;i++){
				if(llList2Key(LIST_USER_QUEUE, i) == NULL_KEY || !~llListFindList(users, llList2List(LIST_USER_QUEUE, i, i))){
					if(nl > 0){
						LIST_USER_QUEUE = (LIST_USER_QUEUE = []) + llListReplaceList(LIST_USER_QUEUE, llList2List(newList, 0, 0), i, i);
						newList = (newList = []) + llDeleteSubList(newList, 0, 0);
						nl = newList != [];
					} else {
						LIST_USER_QUEUE = (LIST_USER_QUEUE = []) + llListReplaceList(LIST_USER_QUEUE, [NULL_KEY], i, i);
					}
				}
			}
			LIST_USER_QUEUE = (LIST_USER_QUEUE = []) + (users = []) + (newList = []) + LIST_USER_QUEUE + newList;
		} else {
			LIST_USER_QUEUE = (LIST_USER_QUEUE = []) + LIST_USER;
		}
	}
	return LIST_USER_QUEUE;
}

// get full user key by username
list getUserKeys(string name){
    list L = [];
    integer u = llListFindList(LIST_USER_DISPLAY, [name]);
    if(~u){
        L = llList2List(LIST_USER, u, u);  //llList2Key(userList, u);
    }
    return L;
}

// get full animatin name
string getAnimationName(string name){
    if(name != TMP_EMPTY){
        if(name == TMP_RANDOM){
            name = llList2String(LIST_ANIMATION, randomInteger(0, llGetListLength(LIST_ANIMATION) - 1));
        } else if(name == TMP_STOP){
        	name = "";
        } else {
            integer a = llListFindList(LIST_ANIMATION_DISPLAY, [name]);
            if(~a){
                name = llList2String(LIST_ANIMATION, a);
            }
        }
    }
    return name;
}

__ACTIONS__(){}

// request permission to user
permissionAnimation(){
	list users = SELECT_USER;
	integer len = users != [];
    integer me = llListFindList(users, [OWNER]);
        
    if(~me){
    	llRequestPermissions(llList2Key(users, me), PERMISSION_TRIGGER_ANIMATION);
    	users = (users = []) + llDeleteSubList(users, me, me);
    	len --;
    }
    
    if(len > 0){
        string tip;
        if(SELECT_ANIMATION == TMP_EMPTY){
            tip = TIPS_STOPDANCE;
        } else {
            tip = TIPS_STARTDANCE;
        }
    	llMessageLinked(LINK_SET, CHANNEL, llList2CSV([] + [SELECT_ANIMATION] + users), NULL_KEY);
    	regionSayToAll(users, tip);
    }
    
    if(STATE_PREPARE != TMP_EMPTY){
    	STATE = STATE_PREPARE;
    	STATE_PREPARE = TMP_EMPTY;
    }
    
    SELECTED_ANIMATION = SELECT_ANIMATION;
    SELECTED_USER = (SELECTED_USER = []) + SELECT_USER;
}

// change animation
changeAnimation(key uuid, string name){
    stopAnimation(uuid);
    name = getAnimationName(name);
    if(name != TMP_EMPTY){
        if(TIPS_STARTDANCE != TMP_EMPTY){
            llRegionSayTo(uuid, 0, TIPS_STARTDANCE);
        }
        llStartAnimation(name);
    } else {
        if(TIPS_STOPDANCE != TMP_EMPTY){
            llRegionSayTo(uuid, 0, TIPS_STOPDANCE);
        }
    }
}

// stop animation
stopAnimation(key uuid){
    list ani = llGetAnimationList(uuid);
    integer len = llGetListLength(ani);
    while(~len){
        llStopAnimation(llList2Key(ani, --len));
    }
}

// reflush and update animation list
reflushAnimationList(){
    integer len = llGetInventoryNumber(INVENTORY_ANIMATION);
    if(len != llGetListLength(LIST_ANIMATION)){
        LIST_ANIMATION = [];
        LIST_ANIMATION_DISPLAY = [];
        if(len > 0){
            string name;
            integer i = 0;
            for(; i<len; i++){
                name = llGetInventoryName(INVENTORY_ANIMATION, i++);
                LIST_ANIMATION = (LIST_ANIMATION = []) + LIST_ANIMATION + [name];
                LIST_ANIMATION_DISPLAY = (LIST_ANIMATION_DISPLAY = []) + LIST_ANIMATION_DISPLAY + llGetSubString(name, 0, 23);
            }
        }
    }
}

// reflush and update user list
reflushUserList(integer detected){
    LIST_USER = LIST_USER_DISPLAY = [];
    key uuid;
    integer i = 0;
    while(i < detected){
        uuid = llDetectedKey(i++);
        LIST_USER = (LIST_USER = []) + LIST_USER + [uuid];
        LIST_USER_DISPLAY = (LIST_USER_DISPLAY = []) + LIST_USER_DISPLAY + [llGetSubString(llKey2Name(uuid), 0, 23)];
    }
}

// initChannel
initChannel(){
    llMessageLinked(LINK_SET, CHANNEL, TMP_EMPTY, NULL_KEY);
}

// creage listen proess
listenStart(){
    if(!LISTEN_HANDLE){
        LISTEN_HANDLE = llListen(CHANNEL, TMP_EMPTY, NULL_KEY, TMP_EMPTY);
    }
}

// remove listen proess
listenStop(){
    if(LISTEN_HANDLE){
        llListenRemove(LISTEN_HANDLE);
    }
}

// actions on listen
listenActions(integer channel, string name, key id, string content){
    llOwnerSay((string)channel + " " + STATE_MENU + " " + content);
    if(channel == CHANNEL){
        if(content == TMP_COMMAND_STOP){
            SELECTED_USER = [id];
            SELECTED_ANIMATION = TMP_EMPTY;
        } else
        
        if(STATE_MENU == STATE_MENU_MAIN){
            if(content == TMP_SELF){
            	SELECT_USER = [OWNER];
                menuAnimation(id, CURRENT_PAGE = 0);
                STATE_PREPARE = STATE_DANCING;
            } else if(content == TMP_INVITE){
                menuUser(id, CURRENT_PAGE = 0);
            } else if(content == TMP_LEAD){
                menuLeader(id, CURRENT_PAGE = 0);
                STATE_PREPARE = STATE_LEADING;
            } else if(content == TMP_SETTING){
                menuSetting(id);
            }
        } else if(STATE_MENU == STATE_MENU_USER){
            if(content == TMP_DEFAULT){
                menuUser(id, CURRENT_PAGE);
            } else if(content == TMP_RETURN){
                menuMain(id);
            } else if(content == TMP_PREV){
                menuUser(id, -- CURRENT_PAGE);
            } else if(content == TMP_NEXT){
                menuUser(id, ++ CURRENT_PAGE);
            } else if(content == TMP_ALL){
            	SELECT_USER = getUserQueue();
                menuAnimation(id, CURRENT_PAGE = 0);
            } else {
            	SELECT_USER = getUserKeys(content);
                menuAnimation(id, CURRENT_PAGE = 0);
            }
        } else if(STATE_MENU == STATE_MENU_ANIMATION){
            if(content == TMP_DEFAULT){
                menuAnimation(id, CURRENT_PAGE);
            } else if(content == TMP_RETURN){
                menuMain(id);
            } else if(content == TMP_PREV){
                menuAnimation(id, -- CURRENT_PAGE);
            } else if(content == TMP_NEXT){
                menuAnimation(id, ++ CURRENT_PAGE);
            } else if(content == TMP_RANDOM){
            	SELECT_ANIMATION = getAnimationName(TMP_RANDOM);
            	permissionAnimation();
            } else {
            	SELECT_ANIMATION = getAnimationName(content);
            	permissionAnimation();
            }
        } else if(STATE_MENU == STATE_MENU_SETTING){
        	if(content == TMP_RETURN){
        		menuMain(id);
        	} else if(content == TMP_SETRANGE){
        		menuSetMaxRange(id);
        	} else if(content == TMP_SETUSER){
        		menuSetMaxUser(id);
        	}
        } else if(STATE_MENU == STATE_MENU_LEADER){
        	if(content == TMP_DEFAULT){
                menuAnimation(id, CURRENT_PAGE);
            } else if(content == TMP_RETURN){
                menuMain(id);
            } else if(content == TMP_PREV){
                menuLeader(id, -- CURRENT_PAGE);
            } else if(content == TMP_NEXT){
                menuLeader(id, ++ CURRENT_PAGE);
            } else if(content == TMP_RANDOM){
        		SELECT_USER = [OWNER] + getUserQueue();
				SELECT_ANIMATION = getAnimationName(TMP_RANDOM);
				permissionAnimation();
            } else {
        		SELECT_USER = [OWNER] + getUserQueue();
				SELECT_ANIMATION = getAnimationName(content);
				permissionAnimation();
            }
        } else if(STATE_MENU == STATE_MENU_LEADING){
        	if(content == TMP_RETURN){
        		menuMain(id);
        	} else if(content == TMP_STOP){
        		STATE = STATE_NORMAL;
        	} else if(content == TMP_SYNC){
        		
        	} else if(content == TMP_CHANGE){
        		menuAnimation(id, CURRENT_PAGE = 0);
        	}
        } else if(STATE_MENU == STATE_MENU_DANCING){
        	if(content == TMP_RETURN){
        		menuMain(id);
        	} else if(content == TMP_STOP){
				SELECT_USER = [OWNER];
				SELECT_ANIMATION = getAnimationName(TMP_STOP);
				permissionAnimation();
        	} else if(content == TMP_LEAD){
        		SELECT_USER = [OWNER] + getUserQueue();
				SELECT_ANIMATION = SELECTED_ANIMATION;
				permissionAnimation();
        	}
        } else if(STATE_MENU == STATE_MENU_SETMAXUSER){
        	if(content == TMP_RETURN){
        		menuSetting(id);
        	}
        } else if(STATE_MENU == STATE_MENU_SETMAXRANGE){
        	if(content == TMP_RETURN){
        		menuSetting(id);
        	}
        }
    }
}

// reset selected data
reset(){
    SELECTED_USER = [];
    SELECTED_ANIMATION = TMP_EMPTY;
}

// default state
default{
    state_entry() {
        state init;
    }
}

state init{
    state_entry() {
        if(!isNoteCard(CONFIG_FILE)){
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
                    data = (data = "") + llStringTrim(data, STRING_TRIM);
                    integer index = llSubStringIndex(data, CODE_SPLIT);
                    if(-1 < index){
                        CONFIG_FILE_DATA_RULE = (CONFIG_FILE_DATA_RULE = []) + CONFIG_FILE_DATA_RULE + llGetSubString(data, 0, index - 1);
                        llOwnerSay(llGetSubString(data, 0, index - 1));
                        data = (data = "") + llDeleteSubString(data, 0, index);
                        CONFIG_FILE_DATA = (CONFIG_FILE_DATA = []) + CONFIG_FILE_DATA + [llStringTrim(data, STRING_TRIM)];
                        llOwnerSay(llStringTrim(data, STRING_TRIM));
                    } else {
                        llOwnerSay(data);
                        CONFIG_FILE_DATA_RULE = (CONFIG_FILE_DATA_RULE = []) + CONFIG_FILE_DATA_RULE + [data];
                        CONFIG_FILE_DATA = (CONFIG_FILE_DATA = []) + CONFIG_FILE_DATA + [""];
                    }
                }
                ++ CONFIG_FILE_CURRENT_LINE;
                CONFIG_FILE_REQUEST_KEY = llGetNotecardLine(CONFIG_FILE, CONFIG_FILE_CURRENT_LINE); // ask for the next line
            }
        }
        // update the hover-text with the progress
        llSetText("Loading... " + (string)(CONFIG_FILE_CURRENT_LINE) + "/" + (string)CONFIG_FILE_NUM_LINES, <1, 1, 1>, 1);
    }
    
    state_exit() {
        llSetText(TMP_EMPTY, <0,0,0>, 1);
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
        parseConfig();
        initChannel();
        OWNER = llGetOwner();
        CHANNEL_REPORT = CHANNEL + 1;
        TIPS_STARTDANCE = (TIPS_STARTDANCE = "") + stringReplaceAll(TIPS_STARTDANCE, ["#{CHANNEL}", "#{COMMAND}"], [CHANNEL, TMP_COMMAND_STOP]);
        state main;
    }
}

//main state
state main{
    state_entry(){
        reflushAnimationList();
        listenStart();
        llSensorRepeat(TMP_EMPTY, NULL_KEY, AGENT, USER_DETECT_RANGE, PI, USER_DETECT_INTERVAL);        
    }
    
    touch_start(integer total_number) {
    	if(STATE == STATE_DANCING){
    		menuDanceing(OWNER);
    	} else if(STATE == STATE_LEADING){
    		menuLeading(OWNER, CURRENT_PAGE = 0);
    	} else {
    		menuMain(OWNER);
    	}
    }
    
    sensor(integer detected){
        reflushUserList(detected);
    }
    
    no_sensor(){
        reflushUserList(-1);
    }
    
    run_time_permissions(integer perm){
        if (perm & PERMISSION_TRIGGER_ANIMATION){
            changeAnimation(llGetPermissionsKey(), SELECT_ANIMATION);
        }
    }
    
    listen(integer channel, string name, key id, string content){
    	listenActions(channel, name, id, content);
    }
    
    changed(integer change) {
        if (change & (CHANGED_INVENTORY)) { // if someone edits the card, reset the script
            llResetScript();
        }
    }
}