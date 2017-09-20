string object = "ball"; // Name of object in inventory
vector relativePosOffset = <0.0, 0.0, 2.0>; // "Forward" and a little "above" this prim
vector relativeVel = <0.0, 0.0, 1.0>; // Traveling in this prim's "forward" direction at 1m/s
rotation relativeRot = <0.0, 0.0, 0.0, 0.0>; // Rotated 90 degrees on the x-axis compared to this prim
integer startParam = 10;
 
default
{
    touch_start(integer a)
    {
        vector myPos = llGetPos();
        rotation myRot = llGetRot();
 
        vector rezPos = myPos+relativePosOffset*myRot;
        vector rezVel = relativeVel*myRot;
        rotation rezRot = relativeRot*myRot;
 
        llRezObject(object, rezPos, rezVel, rezRot, startParam);
    }
}