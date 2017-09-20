integer c = 0;

default{
    state_entry(){
    	llSetTimerEvent(5.0);
    }
    
    touch_start(integer total_number) {
    	llResetTime();
    }
    
    timer(){
    	llOwnerSay((string)c);
    	c++;
    }
}