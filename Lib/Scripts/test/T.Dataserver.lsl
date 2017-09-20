string NOTECARD_NAME = "config"; // name of the card we are going to read
integer notecard_line = 0;
integer num_notecard_lines = 0;
key notecard_request = NULL_KEY;
list card_data; // the data in the card
 
// check that that the named inventory item is a notecard
integer isCard(string name){
    return INVENTORY_NOTECARD == llGetInventoryType(name);
}
 
default
{
    state_entry()
    {
        state init;
    }
}
 
state ready
{
    touch_start(integer detected)
    {
        llOwnerSay("the notecard contained the following data:");
        llOwnerSay(llDumpList2String(card_data, "\n"));
    }
    changed(integer change)
    {
        if (change & (CHANGED_INVENTORY)) // if someone edits the card, reset the script
        {
            llResetScript();
        }
    }
}
 
state init
{
    state_entry()
    {
        if (!isCard(NOTECARD_NAME)) // check the card exists
        {
            state error;
        }
        llSetText("initialising...", <1, 1, 1>, 0);
        notecard_request = NULL_KEY;
        notecard_line = 0;
        num_notecard_lines = 0;
        notecard_request = llGetNumberOfNotecardLines(NOTECARD_NAME); // ask for the number of lines in the card
        llSetTimerEvent(5.0); // if we don't hear back in 5 secs, then the card might have been empty
    }
    timer() // if we time out, it meant something went wrong - the notecard was probably empty
    {
        llSetTimerEvent(0.0);
        state error;
    }
    dataserver(key query_id, string data)
    {
        if (query_id == notecard_request) // make sure it's an answer to a question we asked - this should be an unnecessary check
        {
            llSetTimerEvent(0.0); // at least one line, so don't worry any more
            if (data == EOF) // end of the notecard, change to ready state
            {
                state ready;
            }
            else if (num_notecard_lines == 0) // first request is for the number of lines
            {
                num_notecard_lines = (integer)data;
                notecard_request = llGetNotecardLine(NOTECARD_NAME, notecard_line); // now get the first line
            }
            else
            {
                if (data != "" && llGetSubString(data, 0, 0) != "#") // ignore empty lines, or lines beginning with "#"
                {
                    card_data = (card_data = []) + card_data + data;
                }
                ++notecard_line;
                notecard_request = llGetNotecardLine(NOTECARD_NAME, notecard_line); // ask for the next line
            }
        }
        // update the hover-text with the progress
        llSetText("read " + (string)(notecard_line) + " of " + (string)num_notecard_lines + " lines", <1, 1, 1>, 1);
    }
 
    state_exit()
    {
        llSetText("", <0, 0, 0>, 0);
    }
}
 
state error
{
    state_entry()
    {
        llOwnerSay("something went wrong; try checking that the notecard [ " + NOTECARD_NAME + " ] exists and contains data");
    }
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)
        {
            llResetScript();
        }
    }
}