//Chibiusa lings shiz
string ProtocolSignature = "ENC"; // your own signature
float ProtocolVersion = 0.3; // can range from 0.0 to 255.255
string Password = "P@ssw0rd"; // change this to your own password
integer communicationsChannel = PUBLIC_CHANNEL;
string Header;
string strHex = "0123456789ABCDEF";
 
string hex(integer value)
{
    integer digit = value & 0xF;
    string text = llGetSubString(strHex, digit, digit);
    value = (value >> 4) & 0xfffFFFF;
    integer odd = TRUE;
    while(value)
    {
        digit = value & 0xF;
        text = llGetSubString(strHex, digit, digit) + text;
        odd = !odd;
        value = value >> 4;
    }
    if(odd)
        text = "0" + text;
    return text;
}
string encrypt(string password, string message)
{
    // get a random value
    integer nonce = (integer)llFrand(0x7FFFFFFF);
 
    // generate digest and prepend it to message
    message = llMD5String(message, nonce) + message;
 
    // generate one time pad
    string oneTimePad = llMD5String(password, nonce);
 
    // append pad until length matches or exceeds message
    integer count = (llStringLength(message) - 1) / 32;
    if(count)
        do
            oneTimePad += llMD5String(oneTimePad, nonce);
        while(--count);
 
    // return the header, nonce and encrypted message
    return Header + llGetSubString("00000000" + hex(nonce), -8, -1) + llXorBase64StringsCorrect(llStringToBase64(message), llStringToBase64(oneTimePad));
}
init()
{
    //build the header, it never changes.
    list versions = llParseString2List((string)ProtocolVersion, ["."], []);
    string minor = llList2String(versions, 1);
    integer p = 0;
    while(llGetSubString(minor, --p, p) == "0");
    Header = ProtocolSignature + hex(llList2Integer(versions, 0)) + hex((integer)llGetSubString(minor, 0xFF000000, p));    
}
 
default
{
    state_entry()
    {
        init();
        llOwnerSay(encrypt(Password, "Hello, Avatar!"));
        llOwnerSay(encrypt(Password, "This is a very long text that I hope to be able to create a long one time pad to decrypt for it."));
    }
 
    touch_start(integer total_number)
    {
        llOwnerSay(encrypt(Password, "Touched."));
    }
}