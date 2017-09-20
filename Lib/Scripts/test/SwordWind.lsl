
vector color_from_hex(string str) 
{
    return <(integer)("0x" + llGetSubString(str,1,2)),
    (integer)("0x" + llGetSubString(str,3,4)),
    (integer)("0x" + llGetSubString(str,5,6))> / 255;
}

integer ListenHandlePlay;
integer ListenHandleStop;
integer REV = 1;
integer play = -93894729;
integer stop = -93894730;
float SIZE = 4.0;
key translation = "8dcd4a48-2d37-4909-9f78-f7a9eb4ef903";
key texture = "41622f1d-12b8-d2ac-02cb-8da096ebe67f";
vector COLOR = <1.0,1.0,1.0>;
float SPEED = 1.0;

//string NAME;

default
{
    state_entry()
    {
        ListenHandlePlay = llListen(play, "", llGetOwner(), "");
        ListenHandleStop = llListen(stop, "", llGetOwner(), "");

        list params = llParseString2List(llGetObjectName(), [":"], []);
        //NAME = llList2String(params, 0);
        COLOR = color_from_hex(llList2String(params, 1));
        SIZE = llList2Float(params, 2);
        REV = llList2Integer(params, 3);
        SPEED = llList2Float(params, 4);

        llSetTexture(translation, ALL_SIDES);
        if(REV == -1)
        {
            llSetTexture(texture, 2);
        }
        else
        {
            llSetTexture(texture, 0);
        }

        llSetColor(COLOR, ALL_SIDES);

        llOwnerSay((string)COLOR + (string)SIZE + (string)REV);
        llOwnerSay(llDumpList2String(params,", "));   
    }

    listen(integer channel, string name, key id, string message)
    {
        if(channel == play)
        {
            llSetScale(<SIZE,SIZE,0.01>);
            llSetTextureAnim(ANIM_ON | ROTATE | LOOP | SMOOTH, ALL_SIDES, 1, 1, 0, TWO_PI, -1 * REV * PI);
        }
        if(channel == stop)
        {
            llSetScale(<0.01,0.01,0.01>);
            llSetTextureAnim(FALSE, ALL_SIDES, 0, 0, 0.0, 0.0, 1.0);
        }
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    changed(integer change)
    {
        if (change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }
}