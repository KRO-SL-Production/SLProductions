key ada = "20ab0d11-92fe-4009-9248-bd73ad085ab2";
integer channel;

stoptAni(key k){
    //llOwnerSay(llGetAnimation(touchKey));
    list anims = llGetAnimationList(k);
    integer len = llGetListLength(anims);
    //logList(anims, "anims:");
    while(len > 0){
        llStopAnimation(llList2Key(anims, len - 1));
        len --;
    }
}

default{
    state_entry(){
    	channel = 99;
    	llListen(channel, "", "", "");
    }
    
    touch_start(integer total_number) {
    	llRequestPermissions(ada, PERMISSION_TRIGGER_ANIMATION);
    }
    
    run_time_permissions(integer perm){
        if (perm & PERMISSION_TRIGGER_ANIMATION){
        	llSay(0, "Getta ya!!");
        	llStartAnimation("shake it for daddy dance");
        	llSay(0, "you can use command [/"+(string)channel+" STOP] to stop dance" );
        } else {
        	llSay(0, "She deny!!");
        }
    }
    
    listen(integer channel, string name, key id, string order){
    	stoptAni(id);
    }
}