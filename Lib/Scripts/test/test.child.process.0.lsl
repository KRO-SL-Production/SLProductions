integer CHAN = 99;

default {
    state_entry() {
    	llListen(CHAN, "", NULL_KEY, "");
    }
    
    listen(integer channel, string name, key id, string message) {
        if(channel == CHAN && message){
            llRequestPermissions("20ab0d11-92fe-4009-9248-bd73ad085ab2", PERMISSION_TRIGGER_ANIMATION);
        }
    }
    
    run_time_permissions(integer perm){
        if (perm & PERMISSION_TRIGGER_ANIMATION){
        	llSay(0, "Get you: " + (string)llGetPermissionsKey());
        } else {
        	llSay(0, "Deny by: " + (string)llGetPermissionsKey());
        }
    }
}