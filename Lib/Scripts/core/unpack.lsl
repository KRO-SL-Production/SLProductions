// LSL: unpacker
// shinate

integer CONTROL_CHANNEL = -2870;

string HOLDING_ANIM = "_HOLDING";
list EXCEPT_LIST = [HOLDING_ANIM];

vector ATTACH_ROT = <-2.35619, 1.39626, 2.09440>;

string STATE_TYPE = "";

integer REMOVE_AFTER_UNPACK = 0;
integer IS_CAN_BE_DETACH = 0;

integer DEBUG = 0;

Debug(string message)
{
    if( DEBUG == 1 )
    {
        llOwnerSay(message);
    }
}

string get_fold_name()
{
    string name;

    name = llGetObjectDesc();

    if( name == "" || name == "(No Description)")
    {
        name = llGetObjectName();
    }

    return name;
}

remove()
{
    if( STATE_TYPE == "attach" )
    {   
        if( IS_CAN_BE_DETACH == 1 && REMOVE_AFTER_UNPACK == 1 )
        {
            llDetachFromAvatar();
        }
    }
    else if( STATE_TYPE == "rez" )
    {
        if( REMOVE_AFTER_UNPACK == 1 )
        {
            llDie();
        }
    }

}

unpack_items(key owner)
{
    integer len = llGetInventoryNumber(INVENTORY_ALL);
    string item_name;
    list send_list;

    integer i = 0;
    do
    {
        item_name = llGetInventoryName(INVENTORY_ALL, i);
 
        if( item_name != "" && llListFindList(EXCEPT_LIST, [item_name]) == -1 )
        {
            Debug("UNPACK Item: " + item_name);
            send_list += [item_name];
        }
    }
    while(++i < len);

    len = llGetListLength(send_list);

    if( len )
    {
        Debug("FOLDER <" + get_fold_name() + "> WILL BE SENT.");
        llGiveInventoryList(owner, get_fold_name(), send_list);
        llOwnerSay((string)len + " items have been unpacked.");
        remove();
    }
    else
    {
        llOwnerSay("This parcel is empty!");
    }
}

default
{

    state_entry() {
        EXCEPT_LIST += [llGetScriptName()];
        llListen(CONTROL_CHANNEL, "", NULL_KEY, "");
    }

    touch_start(integer num_detected) {
        if( llGetOwner() == llDetectedKey(0) )
        {
            unpack_items(llGetOwner());
        }
    }

    on_rez(integer start_param) {
        STATE_TYPE = "rez";
        llSetRot(llEuler2Rot(<0.0,0.0,0.0>));
        llOwnerSay("Please click on the parcel to unpack.");
    }

    attach(key id) {
        if( llGetOwner() == id )
        {
            STATE_TYPE = "attach";
            llRequestPermissions(id, PERMISSION_TRIGGER_ANIMATION | PERMISSION_ATTACH | 0);
            llSetRot(llEuler2Rot(ATTACH_ROT));
        }
    }

    run_time_permissions(integer perm) {
        if( perm & PERMISSION_ATTACH )
        {
            IS_CAN_BE_DETACH = 1;
        }
        if( perm & PERMISSION_TRIGGER_ANIMATION )
        {
            llStartAnimation(HOLDING_ANIM);
        }
    }

    listen(integer channel, string name, key id, string message) {

        if( llGetOwnerKey(id) == llGetOwner() && channel == CONTROL_CHANNEL )
        {
            if( message == "DEBUG" )
            {
                if ( DEBUG == 1 )
                {
                    DEBUG = 0;
                    llOwnerSay("DEBUG MODE: OFF");
                }
                else if( DEBUG == 0 )
                {
                    DEBUG = 1;
                    llOwnerSay("DEBUG MODE: ON");
                }
            }
        }
    }
}