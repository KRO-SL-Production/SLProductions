// Jippen Faddoul's Poseball script - Low ram/lag posepall thats just drag-and drop simple
// Copyright (C) 2007 Jippen Faddoul
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License version 3, as 
//    published by the Free Software Foundation.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>
 
 
 
//This text will appear in the floating title above the ball
string TITLE="Sit here";            
//You can play with these numbers to adjust how far the person sits from the ball. ( <X,Y,Z> )
vector offset=<0.0,0.0,0.5>;            
 
///////////////////// LEAVE THIS ALONE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
string ANIMATION;
integer visible = TRUE;
key avatar;
 
vector COLOR = <1.0,1.0,1.0>;
float ALPHA_ON = 1.0;
float ALPHA_OFF = 0.0;
 
show(){
    visible = TRUE;
    llSetText(TITLE,COLOR,ALPHA_ON);        
    llSetAlpha(ALPHA_ON, ALL_SIDES);
}
 
hide(){
    visible = FALSE;
    llSetText("",COLOR,ALPHA_ON);        
    llSetAlpha(ALPHA_OFF, ALL_SIDES);
}
 
default{
    state_entry() {
        llSitTarget(offset,ZERO_ROTATION);
        if((ANIMATION = llGetInventoryName(INVENTORY_ANIMATION,0)) == ""){
            llOwnerSay("Error: No animation");
            ANIMATION = "sit";
            }
        llSetSitText(TITLE);
        show();
    }
 
    touch_start(integer detected) {
        //llOwnerSay("Memory: " + (string)llGetFreeMemory());
        if(visible){ hide(); }
        else       { show(); }
    }
 
    changed(integer change) {
        if(change & CHANGED_LINK) {
            avatar = llAvatarOnSitTarget();
            if(avatar != NULL_KEY){
                //SOMEONE SAT DOWN
                hide();
                llRequestPermissions(avatar,PERMISSION_TRIGGER_ANIMATION);
                return;
            }else{
                //SOMEONE STOOD UP
                if (llGetPermissionsKey() != NULL_KEY){ llStopAnimation(ANIMATION); }
                show();
                return;
            }
        }
        if(change & CHANGED_INVENTORY) { llResetScript(); }
        if(change & CHANGED_OWNER)     { llResetScript(); }
    }
 
    run_time_permissions(integer perm) {
        if(perm & PERMISSION_TRIGGER_ANIMATION) {
            llStopAnimation("sit");
            llStartAnimation(ANIMATION);
            hide();
        }
    }
}