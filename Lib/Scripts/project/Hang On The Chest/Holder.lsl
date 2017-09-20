integer CHANNEL = -94835;
integer CHANNEL_REQUEST = -94836;
string NAME;

default
{
    state_entry()
    {
        NAME = llStringTrim(llGetObjectDesc(), STRING_TRIM);
        llSetText("", <0, 0, 0>, 0.0);
        if ( NAME == "" )
        {
            llSetText("The name is not set", <1, 0.255, 0.212>, 1.0);
        }
        else
        {
            llListen(CHANNEL, "", NULL_KEY, "");
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        if ( channel == CHANNEL )
        {
            // llOwnerSay(name + " " + (string)id + " " + message);
            if ( message == "CONNECT" )
            {
                llSay(CHANNEL_REQUEST, NAME + ":CONNECT");
            }
            else
            {
                llSay(CHANNEL_REQUEST, NAME + ":DISCONNECT");
            }
        }
    }

    changed(integer change)
    {
        llResetScript();
    }
}