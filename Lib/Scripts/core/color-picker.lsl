// :SHOW:
// :CATEGORY:HUD
// :NAME:HUD Color Picker
// :AUTHOR:Ferd Frederix
// :KEYWORDS:
// :CREATED:2015-07-15 10:04:24
// :EDITED:2015-07-15  09:04:24
// :ID:1082
// :NUM:1802
// :REV:1
// :WORLD:Second Life
// :DESCRIPTION:
// Rainbow Palette Color picker for a HUD//:LICENSE: CC-BY-SA 3.0
// :CODE:

// add this script and the texture to a prim.  You can touch the prim to change the color of other,unlinked prims.

// Based on Rainbow Palette by Rui Clary
// Modified by Jor3l Boa. Better interface and more readable :P
// Modified by Rui Clary on 2011.06.20 - some corrections
// Modified by Ferd Frederix 2015.07.14 to have intensity control and be non-UUID specific (Opensim compatible).

// Available under the Creative Commons Attribution-ShareAlike 3.0 license
// http://creativecommons.org/licenses/by-sa/3.0/

// tunable things
string productName = "pal";// change this to match your product prim  - they must match to prevent crosstalk between products.
integer channel = 4;  // pick a channel that matches the listener prim

// no changes needed after this
 
// devolverString -> Convert and return a vector without .0000 and other
// float things :)
devolverString(float r, float g, float b) {
    string _vector = "<";
    if(r <= 0)  {
        _vector += "0,";
    }
    else if(r == 1) {
        _vector += "1,";
    }
    else    {
        string temp = (string)r;
        while(llGetSubString(temp,llStringLength(temp)-1,-1) == "0")    {
            temp = llDeleteSubString(temp,llStringLength(temp)-1,-1);
        }
        _vector += temp+",";
    }
    //----------------
    if(g <= 0)  {
        _vector += "0,";
    }
    else if(g == 1) {
        _vector += "1,";
    }
    else    {
        string temp = (string)g;
        while(llGetSubString(temp,llStringLength(temp)-1,-1) == "0")    {
            temp = llDeleteSubString(temp,llStringLength(temp)-1,-1);
        }
        _vector += temp+",";
    }
    //----------------
    if(b <= 0)  {
        _vector += "0>";
    }
    else if(b == 1) {
        _vector += "1>";
    }
    else    {
        string temp = (string)b;
        while(llGetSubString(temp,llStringLength(temp)-1,-1) == "0")    {
            temp = llDeleteSubString(temp,llStringLength(temp)-1,-1);
        }
        _vector += temp+">";
    }
    //----------------
    llOwnerSay(_vector);
    llSetColor((vector)_vector,0);
}
 
default
{
    state_entry()
    {

    }

    touch(integer num_detected) 
    {
        llOwnerSay((string)num_detected + " " + (string)llDetectedTouchFace(0));
        vector touchedpos = llDetectedTouchST(0);
        llOwnerSay((string)touchedpos);
           
 
        if(llDetectedTouchFace(0) != 1) {
            return;
        }
 
        float y = touchedpos.y;
        float l = y * 2 - 1;
        if ( l < 0 )
        {
            l = 0;
        }

        float h = y * 2;
        if ( h > 1 )
        {
            h = 1;
        }

        float s = 100;
        float c = 6 * s * touchedpos.x;

        float r = 0;
        float g = 0;
        float b = 0;

        llOwnerSay((string)c);

        if ( c >= 0 && c <= 100 )
        {
            r = h;
            g = (c / s) * h + l;
            b = l;
        }
        else if ( c > 100 && c <= 200)
        {
            r = (1 - (c - s) / s) * h + l;
            g = h;
            b = l;
        }
        else if ( c > 200 && c <= 300 )
        {
            r = l;
            g = h;
            b = (c - s * 2) / s * h + l;
        }
        else if ( c > 300 && c < 400 )
        {
            r = l;
            g = (1 - (c - s * 3) / s) * h + l;
            b = h;
        }
        else if ( c > 400 && c < 500 )
        {
            r = (c - s * 4) / s * h + l;
            g = l;
            b = h;
        }
        else if ( c > 500 && c <= 600 )
        {
            r = h;
            g = l;
            b = (1 - (c - s * 5) / s) * h + l;
        }

        if( r > 1 )
        {
            r = 1;
        }
        if( g > 1 )
        {
            g = 1;
        }
        if( b > 1 )
        {
            b = 1;
        }
        //CONVERSION
        devolverString(r,g,b);
    }
 
}