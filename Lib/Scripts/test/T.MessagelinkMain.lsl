default
{ 
    // To propagate an unlimted number of arguments of any type.
    // Presumed, the separator string isn't used in any source string!
    state_entry() 
    {
        list my_list = [1, 2.0, "a string", <1, 2, 3>, <1, 2, 3, 4>, llGetOwner()];  
        string list_parameter = llDumpList2String(my_list, "|");	// Convert the list to a string
        llMessageLinked(LINK_THIS, 0, list_parameter, "");
        llOwnerSay((string)llGetLinkNumber());
    }
 
    link_message(integer sender_num, integer num, string list_argument, key id) 
    {
        list re_list = llParseString2List(list_argument, ["|"], []);	// Parse the string back to a list
    }
}