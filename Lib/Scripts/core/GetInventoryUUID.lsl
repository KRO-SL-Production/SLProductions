GetInventoryUUIDS(){
    integer len = llGetInventoryNumber(INVENTORY_ALL);
    if(len > 0){
    	integer i = 0;
    	string name;
    	while(i < len){
    		name = llGetInventoryName(INVENTORY_ALL, i);
    		llOwnerSay(name + " : " + (string)llGetInventoryKey(name));
    		i ++;
    	}
    }
}