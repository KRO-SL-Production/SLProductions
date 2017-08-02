string object = "Object"; // Name of object in inventory
vector relativePosOffset = <2.0, 0.0, 1.0>; // "Forward" and a little "above" this prim
vector relativeVel = <1.0, 0.0, 0.0>; // Traveling in this prim's "forward" direction at 1m/s
rotation relativeRot = <0.707107, 0.0, 0.0, 0.707107>; // Rotated 90 degrees on the x-axis compared to this prim
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