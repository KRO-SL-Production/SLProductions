//Chibiusa lings shiz
string ProtocolSignature = "ENC"; // your own signature
float ProtocolVersion = 0.3; // can range from 0.0 to 255.255
string Password = "P@ssw0rd"; // change this to your own password
integer communicationsChannel = PUBLIC_CHANNEL;
integer Debug = TRUE; // Set this to false for production
integer listener;
 
init()
{
    if(listener != 0)
    {
        llListenRemove(listener);
        listener = 0;
    }
    listener = llListen(communicationsChannel, "", NULL_KEY, "");
}
string error(string message)
{
    if(Debug) llSay(DEBUG_CHANNEL, message);
    return "";
}
string decrypt(string password, string message)
{
    integer signatureLength = llStringLength(ProtocolSignature);
    integer headerLength = signatureLength + 12; // version = 4, nonce = 8
 
    // verify length of encrypted message
    if(llStringLength(message) < signatureLength + 44) // digest = 32 (base64 = 44) + at least one character
        return error("Too small for secret message.");
 
    // look for protocol signature in message header
    if(llSubStringIndex(message, ProtocolSignature) != 0)
        return error("Unknown protocol.");
 
    // Parse version information from header
    integer index = signatureLength; // determine where to start parsing
    string major = "0x" + llGetSubString(message, index, ++index);
    string minor = "0x" + llGetSubString(message, ++index, ++index);
    float version = (float)((string)((integer)major) + "." + (string)((integer)minor));
 
    // verify version is supported
    if(version != ProtocolVersion)
        return error("Unknown version.");
 
    // parse nonce from header
    integer nonce = (integer)("0x" + llGetSubString(message, ++index, index + 7));
 
    // remove header from message
    message = llGetSubString(message, headerLength, -1);
 
    // create one time pad from password and nonce
    string oneTimePad = llMD5String(password, nonce);
    // append pad until length matches or exceeds message
    while(llStringLength(oneTimePad) < (llStringLength(message) / 2 * 3))
        oneTimePad += llMD5String(oneTimePad, nonce);
 
    // decrypt message
    oneTimePad = llStringToBase64(oneTimePad);
    message = llXorBase64StringsCorrect(message, oneTimePad);
 
    // decode message
    message = llBase64ToString(message);
 
    // get digest
    string digest = llGetSubString(message, 0, 31);
 
    // remove digest from message
    message = llGetSubString(message, 32, -1);
 
    // verify digest is valid
    if(llMD5String(message, nonce) != digest)
        return error("Message digest was not valid.");
 
    // return decrypted message
    return message;
}
default
{
    state_entry()
    {
        init();
    }
    on_rez(integer start_param)
    {
        init();
    }
    listen(integer channel, string name, key id, string message)
    {
        string message = decrypt(Password, message);
        if(message != "")
            llSay(0, message);
    }
}