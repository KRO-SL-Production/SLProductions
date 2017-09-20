default
{ 
    // Quick and dirty debugging link_messages
    link_message(integer sender_num, integer num, string msg, key id) 
    {
        llSay(DEBUG_CHANNEL, llList2CSV([sender_num, num, msg, id]));
    }
}