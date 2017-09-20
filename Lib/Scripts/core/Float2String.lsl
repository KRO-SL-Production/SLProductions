//Returns a string that contains the float num in a tidy text format, with optional rounding.
//• float     num     –     number to be formatted    
//• integer     places     –     number of places to use during formatting    
//• integer     rnd     –     boolean, enables/disables rounding    
//Negative floats are fine (i.e. negative signs will be preserved.)
//If you say 1 place, you will get 7.0 instead of 7.0000000
//If you say 3 places, you get 7.14 instead of 7.1400000
//7.1373699 will come out as 7.13 or 7.14, depending on whether you specify rounding
//rnd (rounding) should be set to TRUE for Rounding, FALSE for no rounded
//Example:
//string myFormattedFloat = Float2String(-7.1373699, 3, TRUE);
//rounded returns -7.14
//string myFormattedFloat = Float2String(-7.1373699, 3, FALSE);
//not rounded returns -7.13
string Float2String(float num, integer places, integer rnd) {
    if (rnd) {
        float f = llPow( 10.0, places );
        integer i = llRound(llFabs(num) * f);
        string s = "00000" + (string)i; // number of 0s is (value of max places - 1 )
        if(num < 0.0)
            return "-" + (string)( (integer)(i / f) ) + "." + llGetSubString( s, -places, -1);
        return (string)( (integer)(i / f) ) + "." + llGetSubString( s, -places, -1);
    }
    if (!places)
        return (string)((integer)num );
    if ( (places = (places - 7 - (places < 1) ) ) & 0x80000000)
        return llGetSubString((string)num, 0, places);
    return (string)num;
}