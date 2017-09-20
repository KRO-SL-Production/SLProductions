string animate = "";

default
{
    state_entry()
    {

    }

    link_message(integer sender_number, integer number, string message, key id)
    {
        // llOwnerSay("SLAVE::" + (string)sender_number + "," + (string)number + "," + (string)message + "," + (string)id);
        if(message)
        {
            animate = message;
            llRequestPermissions(id, PERMISSION_TRIGGER_ANIMATION);
        }
    }
    
    run_time_permissions(integer perm)
    {
        // llOwnerSay("SLAVE::" + (string)perm);
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {
            // llOwnerSay("SLAVE::" + animate);
            llStopAnimation("sit");
            llStartAnimation(animate);
        }
    }
}