key OWNER;
key SOUND_SET_REQUEST_ID;
integer SOUND_SET_LINE;
string SOUND_SET_NAME;
integer LSN;
integer DIALOG_CHANNEL = -99;
integer PRELOAD_COUNT = 5;
float PRELOAD_TIME = 2.0;
list SOUND_SET_CURRENT_PLAY_LIST;
integer CLIP_CURRENT_PLAY;
float TIMER_INTERVAL = 9.0;
integer DEBUG = 0;
integer CURRENT_PAGE = 1;
integer TOTAL_SOUND_SET = 0;

list GetSoundSets()
{
    integer startNum = 9 * (CURRENT_PAGE - 1);
    integer endNum = startNum + 9;
    list soundSetList = createEmptyMenu(9);

    integer i = startNum;
    integer z = 8;
    integer a = -2;
    string soundName;
    while (i < endNum)
    {
        soundName = llGetInventoryName(INVENTORY_NOTECARD, i);
        if(soundName)
        {
            soundSetList = llListReplaceList(soundSetList, [soundName], z + a, z + a);
        }
        z--;
        i++;
        a += 2;
        if(a == 4)
        {
            a = -2;
        }
    }

    debug((string)llGetListLength(soundSetList));

    return soundSetList;
}

list createEmptyMenu(integer length){
    string l;
    list t = [];
    while (length--)
    {
        t = (t = []) + t + " ";
    }

    return t;
}

showSoundMenu()
{
    list soundList = GetSoundSets();
    list Pager;

    Pager = (Pager = []) + Pager + "PREV";
    Pager = (Pager = []) + Pager + "CLOSE";
    Pager = (Pager = []) + Pager + "NEXT";

    Pager = (Pager = soundList = []) + Pager + soundList;

    llDialog(OWNER, "\nPAGE: " + (string)CURRENT_PAGE + "\n\nWhich one you want to play?", Pager, DIALOG_CHANNEL);
}

debug(string msg)
{
    if(DEBUG == 1){
        llOwnerSay(msg);
    }
}

default
{
    state_entry()
    {
        OWNER = llGetOwner();
        TOTAL_SOUND_SET = llGetInventoryNumber(INVENTORY_NOTECARD);
        debug("Welcome!");
        state Main;
    }
}

state Main
{
    touch_start(integer total_number)
    {
        llListenRemove(LSN);
        LSN = llListen(DIALOG_CHANNEL, "", OWNER, "");
        showSoundMenu();
    }

    listen(integer channel, string name, key id, string content)
    {
        debug((string)channel + " " + name + " " + content);

        string action = content;

        if (action == "NEXT")
        {
            CURRENT_PAGE += 1;
            
            if(CURRENT_PAGE > llCeil((float)TOTAL_SOUND_SET / 9))
            {
                CURRENT_PAGE -= 1;
            }
            showSoundMenu();
            return;
        }

        if (action == "PREV")
        {
            CURRENT_PAGE -= 1;
            if(CURRENT_PAGE < 1)
            {
                CURRENT_PAGE = 1;
            }
            showSoundMenu();
            return;
        }

        if (action == "CLOSE")
        {
            return;
        }

        SOUND_SET_NAME = content;

        if (llGetInventoryKey(SOUND_SET_NAME) == NULL_KEY)
        {
            debug( "Sound Set '" + SOUND_SET_NAME + "' not EXISIT!!");
            return;
        }
        SOUND_SET_CURRENT_PLAY_LIST = [];
        SOUND_SET_LINE = 0;
        SOUND_SET_REQUEST_ID = llGetNotecardLine(SOUND_SET_NAME, SOUND_SET_LINE);

        // The user did not click "Yes" ...
        // Make the timer fire immediately, to do clean-up actions
        llListenRemove(LSN);
    }

    dataserver(key query_id, string data)
    {
        if (query_id == SOUND_SET_REQUEST_ID)
        {
            if (data == EOF)
            {
                debug("Done reading notecard, read " + (string)SOUND_SET_LINE + " notecard lines.");
                state Play;
            }
            else
            {
                // bump line number for reporting purposes and in preparation for reading next line
                ++SOUND_SET_LINE;
                if(data != "" && "#" != llGetSubString(data, 0, 0))
                {
                    SOUND_SET_CURRENT_PLAY_LIST = (SOUND_SET_CURRENT_PLAY_LIST = []) + SOUND_SET_CURRENT_PLAY_LIST + [data];
                    debug("READ " + (string)SOUND_SET_LINE + " " + data);
                }
                SOUND_SET_REQUEST_ID = llGetNotecardLine(SOUND_SET_NAME, SOUND_SET_LINE);
            }
        }
    }
}

state Play
{
    state_entry(){
        integer len = llGetListLength(SOUND_SET_CURRENT_PLAY_LIST);
        if(len < PRELOAD_COUNT)
            PRELOAD_COUNT = len;
        else
            PRELOAD_COUNT = 3;
        integer i;
        key soundID;
        string soundName;
        llSetSoundQueueing(TRUE);
        while (i < PRELOAD_COUNT) {
            soundID = llList2String(SOUND_SET_CURRENT_PLAY_LIST, i);
            soundName = llList2String(SOUND_SET_CURRENT_PLAY_LIST, i);
            debug("Preload: " + soundName);
            llPreloadSound(soundID);
            llSleep(PRELOAD_TIME);
            ++i;
        }

        llSetTimerEvent(0.1);
        CLIP_CURRENT_PLAY = 0;
    }

    touch_start(integer total_number)
    {
        llListenRemove(LSN);
        LSN = llListen(DIALOG_CHANNEL, "", OWNER, "");
        llDialog(OWNER, "\nWhat you want?", ["STOP"], DIALOG_CHANNEL);
    }

    listen(integer channel, string name, key id, string cmd)
    {
        debug((string)channel + " " + name + " " + cmd);

        if ( cmd == "STOP" )
        {
            llStopSound();
            llSetTimerEvent(0);
            state Main;
        }

        llListenRemove(LSN);
    }

    timer()
    {
        integer len = llGetListLength(SOUND_SET_CURRENT_PLAY_LIST);
        if(CLIP_CURRENT_PLAY > len - 1)
        {
            llSetTimerEvent(0);
            state Main;
        }
        else
        {
            list soundLine = llParseString2List(llList2String(SOUND_SET_CURRENT_PLAY_LIST, CLIP_CURRENT_PLAY), [","], []);

            float time = llList2Float(soundLine, 1);
            if(time <= 0)
            {
                time = TIMER_INTERVAL;
            }

            key soundID = llList2Key(soundLine, 0);
            string soundName = (string)soundID;

            llSetTimerEvent(time);

            //key soundID = llList2Key(SOUND_SET_CURRENT_PLAY_LIST, CLIP_CURRENT_PLAY);
            //string soundName = llList2String(SOUND_SET_CURRENT_PLAY_LIST, CLIP_CURRENT_PLAY);
            llPlaySound(soundID, 1.0);
            debug("Playing: " + (string)CLIP_CURRENT_PLAY + " " + soundName);

            if( len - CLIP_CURRENT_PLAY > PRELOAD_COUNT )
            {
                key preloadID = llList2Key(SOUND_SET_CURRENT_PLAY_LIST, CLIP_CURRENT_PLAY + PRELOAD_COUNT);
                string preloadName = llList2String(SOUND_SET_CURRENT_PLAY_LIST, CLIP_CURRENT_PLAY + PRELOAD_COUNT);
                llPreloadSound(preloadID);
                debug("Preloading: " + (string)(CLIP_CURRENT_PLAY + PRELOAD_COUNT) + " " + preloadName);
            }
        }

        CLIP_CURRENT_PLAY++;
    }
}