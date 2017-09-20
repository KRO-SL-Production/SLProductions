stand(){
    llStartAnimation("holdinglollypop");
}

eat(){
    llStartAnimation("lickinglollypop");
    llPlaySound("eat_apple(9s)", 1);
}

start(){
    stand();
    llSetTimerEvent(20);
}

default{
    state_entry() {
        llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
    }
    
    timer() {
        eat();
    }
    
    run_time_permissions(integer permissions) {
        if(permissions == PERMISSION_TRIGGER_ANIMATION){
            start();
        }
    }
    
    on_rez(integer start_param) {
        llResetScript();
    }
}