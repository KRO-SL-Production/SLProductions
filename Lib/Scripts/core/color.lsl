vector color_from_hex(string str) {
    return <(integer)("0x" + llGetSubString(str,1,2)),
            (integer)("0x" + llGetSubString(str,3,4)),
            (integer)("0x" + llGetSubString(str,5,6))> / 255;
}
 
vector color_from_vector(string vec) {
    // caveat: 1,1,1 will be treated as #ffffff, not #010101
    list   l = llParseString2List(vec, [" ", ",", "<", ">"], []);
    vector v;
 
    v.x = (float)llList2String(l, 0);
    v.y = (float)llList2String(l, 1);
    v.z = (float)llList2String(l, 2);
 
    if (v.x > 1 || v.y > 1 || v.z > 1)
        v /= 255;
 
    return v;
}
 
vector color_from_name(string name) {
    //                                   vv strip spaces and force lowercase                                vv
    integer x = llListFindList(COLORS, [ llToLower(llDumpList2String(llParseString2List(name, [" "], []), "")) ]);
 
    if (x == -1)
        return <-1, -1, -1>;
 
    return color_from_hex(llList2String(COLORS, x+1));
}

vector uHSL2RGB( vector vColHSL ){ //-- <H, S, L>

    vector vColRGB;

    if (vColHSL.y)
    {
        vColRGB.x = (1.0 - llFabs( 2 * vColHSL.z - 1.0 )) * vColHSL.y;                                             //-- C
        vColHSL.x = vColHSL.x * 6.0;                                                                               //-- H'
        vColRGB.y = vColRGB.x * (1.0 - llFabs( (integer)vColHSL.x % 2 + (vColHSL.x - (integer)vColHSL.x) - 1.0 )); //-- X 
        vColRGB = llList2Vector( [<vColRGB.x, vColRGB.y, vColRGB.z>,
                                  <vColRGB.y, vColRGB.x, vColRGB.z>,
                                  <vColRGB.z, vColRGB.x, vColRGB.y>,
                                  <vColRGB.z, vColRGB.y, vColRGB.x>,
                                  <vColRGB.y, vColRGB.z, vColRGB.x>,
                                  <vColRGB.x, vColRGB.z, vColRGB.y>],
                                 (integer)vColHSL.x % 6 ) + (vColHSL.z - 0.5 * vColRGB.x) * <1.0, 1.0, 1.0>;
    }
    else
    {
        vColRGB.x = vColRGB.y = vColRGB.z = vColHSL.z; //-- greyscale
    }

    return vColRGB;
}
/*//--                       Anti-License Text                         --//*/
/*//     Contributed Freely to the Public Domain without limitation.     //*/
/*//   2011 (CC0) [ http://creativecommons.org/publicdomain/zero/1.0 ]   //*/
/*//  Void Singer [ https://wiki.secondlife.com/wiki/User:Void_Singer ]  //*/
/*//--                                                                 --//*/

vector HSV2RGB( vector hsv )
{
    integer i;
    float H = hsv.x * 360;
    float S = hsv.y;
    float V = hsv.z;

    float f; // variables for calculating base color mixing around the "spectrum circle"
    float p;
    float q;
    float t;

    vector rgb;

    if( S == 0 )  // achromatic (grey) simply set R,G, & B = Value
    {
        return <V,V,V>;
    }

    H /= 60;              // Hue factored into range 0 to 5
    i = llFloor(H);       // integer floor of Hue
    f = H - i;            // factorial part of H

    p = V * ( 1 - S );
    q = V * ( 1 - S * f );
    t = V * ( 1 - S * ( 1 - f ) );

    rgb = llList2Vector([
        <V,t,p>,<q,V,p>,<p,V,t>,<p,q,V>,<t,p,V>,<V,p,q>
    ], i);

    return rgb;
}

string bits2nybbles(integer bits, integer len)
{
    integer lsn; // least significant nybble
    string nybbles = "";
    do
    {
        nybbles = llGetSubString("0123456789ABCDEF", lsn = (bits & 0xF), lsn) + nybbles;
    }
    while (bits = (0xFFFFFFF & (bits >> 4)));

    while(len - llStringLength(nybbles) > 0)
    {
        nybbles = "0" + nybbles;
    }
    return nybbles;
}

string listColor2HEX(list colorSet)
{
    integer len = llGetListLength(colorSet);
    integer i = 0;
    vector color;
    while(i < len)
    {
        color = llList2Vector(colorSet, i);
        colorSet = llListReplaceList((colorSet = []) + colorSet, [
                "#" +
                bits2nybbles(llCeil(color.x * 255), 2) + 
                bits2nybbles(llCeil(color.y * 255), 2) +
                bits2nybbles(llCeil(color.z * 255), 2)
            ], i, i);
        i++;
    }

    return llList2CSV(colorSet);
}