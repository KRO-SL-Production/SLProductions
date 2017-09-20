integer listenid;
 
default
{
    touch_start(integer i)
    {
        if(llDetectedKey(0) == llGetOwner())
        {
            llOwnerSay("Please type: /65 (Youtube video id) Example: Video URL: http://youtube.com/video?v=blablabla Video ID: blablabla");
            listenid = llListen(65, "", llGetOwner(),"");
        }
    }
    listen(integer c, string n, key k, string m)
    {
        llListenRemove(listenid);
        if(k == llGetOwner())
        {
            llHTTPRequest("http://unite.codante.org/media/sing_test.mp4",[],"");
        }
    }
    http_response(key requestid, integer status, list metadata, string body)
    {
        llOwnerSay("Connecting...");
        llParcelMediaCommandList([PARCEL_MEDIA_COMMAND_URL,body]);
    }
}