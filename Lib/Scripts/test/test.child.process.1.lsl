integer aniChan = -10000;

default {
    state_entry() {
        llListen(aniChan, "", NULL_KEY, "");
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == aniChan && message == "INV"){
            llRequestPermissions("7ae55768-2506-4606-975e-fdb6fde8ba1b", PERMISSION_TRIGGER_ANIMATION);
        }
    }
    
    run_time_permissions(integer perm){
        if (perm & PERMISSION_TRIGGER_ANIMATION){
            llSay(0, "Get you: " + (string)llGetPermissionsKey());
            llStartAnimation("sexy");
        } else {
            llSay(0, "Deny by: " + (string)llGetPermissionsKey());
        }
    }
}