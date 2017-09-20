integer totaldonated;
string owner;

default {
    state_entry(){
        owner = llKey2Name(llGetOwner());
        llSetPayPrice(10, [1 ,10, 100, 1000]);
        llSetText( owner + "'s donation box.\nAll donations gratefully accepted.\n$0 donated so far.\nRight-click on me and select Pay to donate.",<1,1,1>,1);
    }
    
    on_rez( integer sparam ){
        llResetScript();
    }

    money(key id, integer amount){
        totaldonated+=amount;
        llSetText( owner + "'s donation box.\nAll donations gratefully accepted.\n$" + (string)totaldonated + " donated so far.\nRight-click on me and select Pay to donate.",<0.2,1.0,0.2>,1);
        llInstantMessage(id,"Thanks very much for the tip!");
        llInstantMessage(llGetOwner(),llKey2Name(id)+" donated $" + (string)amount);
    }
}