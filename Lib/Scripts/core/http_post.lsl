// send post request
key post(string url, list params)
{
    integer i;
    string body;
    integer len = llGetListLength(params) & 0xFFFE; // make it even
    for (i = 0; i < len; i += 2)
    {
        string varname = llList2String(params, i);
        string varvalue = llList2String(params, i + 1);
        if (i > 0)
        {
            body += "&";
        }
        body += llEscapeURL(varname) + "=" + llEscapeURL(varvalue);
    }
    string hash = llMD5String(body + llEscapeURL(SECRET_STRING), SECRET_NUMBER);
    return llHTTPRequest(url + "?hash=" + hash, [
            HTTP_METHOD, "POST",
            HTTP_MIMETYPE, "application/x-www-form-urlencoded"
        ], body);
}

string get_post_value(string content, string returns)
{
//  this parses application/x-www-form-urlencoded POST data
 
//  for instance if the webserver posts 'data1=hi&data2=blah' then
//  calling get_post_value("data1=hi&data2=blah","data1"); would return "hi"
//  written by MichaelRyan Allen, Unrevoked Clarity
 
    list params =  llParseString2List(content,["&"],[]);
    integer index = ~llGetListLength(params);
 
    list keys;// = [];
    list values;// = [];
 
    // start with -length and end with -1
    while (++index)
    {
        list parsedParams =  llParseString2List(llList2String(params, index), ["="], []);
        keys += llUnescapeURL(llList2String(parsedParams, 0));
        values += llUnescapeURL(llList2String(parsedParams, 1));
    }
 
    integer found = llListFindList(keys, [returns]);
    if(~found)
    {
        return llList2String(values, found);
    }

    return "";
}