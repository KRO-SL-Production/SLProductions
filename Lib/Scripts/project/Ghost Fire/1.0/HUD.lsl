// LSL: Ghost Fire HUD
// shinate

integer CHANNEL = -984917989;
integer CONTROL_CHANNEL = -2872;
list COLOR_SETS;
string COLOR_SETS_CONF_FILE = "COLOR_SETS";

integer DIALOG_CHANNEL;
integer DIALOG_HANDLE;

// For dataserver
key notecard_query_id;
integer notecard_line;

// HUD Color selector ===============================
list COLOR_DISP_SETS;
list COLOR_DISP_B;
list COLOR_TRIG_SETS;

// Plus =============================================
list HUD_PLUS_ELES;
list HUD_PLUS_ELES_POSIZE = [<-0.117104, -0.098267, -0.025818>, <0.128000, 0.124180, 0.100000>, <-0.293602, -0.098145, -0.060425>, <0.482188, 0.124183, 0.100000>, <-0.321503, -0.098389, 0.070358>, <0.403553, 0.103150, 0.010000>, <-0.496300, -0.098877, 0.039154>, <0.010000, 0.010000, 0.010000>, <-0.396500, -0.122925, 0.039154>, <0.042000, 0.042000, 0.010000>, <-0.347199, -0.122925, 0.039154>, <0.042000, 0.042000, 0.010000>, <-0.296997, -0.122925, 0.039154>, <0.042000, 0.042000, 0.010000>];
list HUD_PLUS_ELES_POS;
list HUD_PLUS_ELES_SIZE;

integer STATUS_SHOW_PLUS = 0;
integer STATUS_TAIL = 0;
integer STATUS_NUTS = 0;
integer STATUS_FLOAT = 0;

list ADJUST_STEP_LIST = [0.01, 0.05, 0.25];
float ADJUST_STEP = 0.01;

// Color picker =====================================
list HUD_CP_ELES;
list HUD_CP_ELES_POSIZE = [<-0.158131, 0.055300, -0.025800>, <0.126960, 0.158898, 0.100000>, <-0.315903, 0.178101, -0.060425>, <0.337324, 0.404789, 0.100000>, <-0.340797, 0.237671, -0.082184>, <0.247371, 0.247371, 0.100000>, <-0.188698, 0.237671, 0.070358>, <0.042089, 0.247370, 0.010000>, <-0.340698, 0.237671, 0.070358>, <0.247371, 0.247371, 0.010000>, <-0.438400, 0.043945, 0.039139>, <0.051723, 0.097449, 0.010000>, <-0.394501, 0.044434, 0.070358>, <0.033123, 0.097449, 0.010000>, <-0.352097, 0.040283, 0.019196>, <0.010000, 0.071162, 0.095020>, <-0.352097, 0.040283, 0.039200>, <0.010000, 0.071162, 0.095020>, <-0.238602, 0.043945, 0.070358>, <0.140487, 0.097449, 0.010000>];
list HUD_CP_ELES_POS;
list HUD_CP_ELES_SIZE;

integer STATUS_SHOW_CP = 0;

vector CP_HSV = <0.0,0.0,1.0>;
list CP_FIRE_COLOR = [<1.0,1.0,1.0>, <1.0,1.0,1.0>];

integer DEBUG = 1;

Debug(string msg)
{
    if(DEBUG == 1)
    {
        Info(msg);
    }
}

Info(string msg)
{
    llOwnerSay(msg);
}

Send(string msg){
    llSay(CHANNEL, msg);
}

vector color_from_hex(string str)
{
    return <(integer)("0x" + llGetSubString(str,1,2)),
            (integer)("0x" + llGetSubString(str,3,4)),
            (integer)("0x" + llGetSubString(str,5,6))> / 255;
}

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

set_link_alpha(integer prim_key, float alpha)
{
    llSetLinkPrimitiveParamsFast(prim_key, [
        PRIM_COLOR,
        ALL_SIDES,
        llList2Vector(llGetLinkPrimitiveParams(prim_key, [PRIM_COLOR, ALL_SIDES]), 0), // get current color
        alpha
    ]);
}

plus_platform_toggle()
{
    if(STATUS_SHOW_PLUS == 0)
    {
        check_status_btns();
    }

    integer len = llGetListLength(HUD_PLUS_ELES);
    integer i = 0;
    integer sw = 0;

    while(i < len)
    {

        if(i == 0)
        {
            sw = 1;
        }
        else
        {
            sw = 0;
        }

        if(STATUS_SHOW_PLUS == sw)
        {
            llSetLinkPrimitiveParamsFast(llList2Integer(HUD_PLUS_ELES, i), [
                PRIM_POS_LOCAL, <0,0,0>,
                PRIM_SIZE, <0,0,0>
            ]);
            Debug("PLUS HIDE: " + (string)i);
        }
        else
        {
            llSetLinkPrimitiveParamsFast(llList2Integer(HUD_PLUS_ELES, i), [
                PRIM_POS_LOCAL, llList2Vector(HUD_PLUS_ELES_POSIZE, i * 2),
                PRIM_SIZE, llList2Vector(HUD_PLUS_ELES_POSIZE, i * 2 + 1)
            ]);
            Debug("PLUS SHOW: " + (string)i);
        }
        i++;
    }

    if(STATUS_SHOW_PLUS == 1)
    {
        check_status_btns();
    }
}

check_status_btns()
{
    if(STATUS_SHOW_PLUS == 1)
    {
        if(STATUS_FLOAT == 1)
        {
            set_link_alpha(llList2Integer(HUD_PLUS_ELES, 4) , 0.3);
        }
        if(STATUS_TAIL == 1)
        {
            set_link_alpha(llList2Integer(HUD_PLUS_ELES, 5) , 0.3);
        }
        if(STATUS_NUTS == 1)
        {
            set_link_alpha(llList2Integer(HUD_PLUS_ELES, 6) , 0.3);
        }
        adjust_step_display(1);
    }
    else
    {
        set_link_alpha(llList2Integer(HUD_PLUS_ELES, 4) , 0.0);
        set_link_alpha(llList2Integer(HUD_PLUS_ELES, 5) , 0.0);
        set_link_alpha(llList2Integer(HUD_PLUS_ELES, 6) , 0.0);
        adjust_step_display(0);
    }
}

adjust_step_display(integer is_shown)
{
    if( is_shown == 1 )
    {
        llSetLinkPrimitiveParamsFast(llList2Integer(HUD_PLUS_ELES, 3), [PRIM_TEXT, llGetSubString((string)ADJUST_STEP, 0, 3), <1, 1, 1>, 0.7]);
    }
    else
    {
        llSetLinkPrimitiveParamsFast(llList2Integer(HUD_PLUS_ELES, 3), [PRIM_TEXT, "", ZERO_VECTOR, 0.0]);
    }
}

cp_platform_toggle()
{
    integer len = llGetListLength(HUD_CP_ELES);
    integer i = 0;
    integer sw = 0;

    while(i < len)
    {

        if(i == 0)
        {
            sw = 1;
        }
        else
        {
            sw = 0;
        }

        if(STATUS_SHOW_CP == sw)
        {
            llSetLinkPrimitiveParamsFast(llList2Integer(HUD_CP_ELES, i), [
                PRIM_POS_LOCAL, <0,0,0>,
                PRIM_SIZE, <0,0,0>
            ]);
            Debug("CP HIDE: " + (string)i);
        }
        else
        {
            llSetLinkPrimitiveParamsFast(llList2Integer(HUD_CP_ELES, i), [
                PRIM_POS_LOCAL, llList2Vector(HUD_CP_ELES_POSIZE, i * 2),
                PRIM_SIZE, llList2Vector(HUD_CP_ELES_POSIZE, i * 2 + 1)
            ]);
            Debug("CP SHOW: " + (string)i);
        }
        i++;
    }

    if(STATUS_SHOW_CP == 1)
    {
        CP_HSV = <0.0, 0.0, 1.0>;

        set_cp_H_pointer();
        set_cp_SV_pointer();
        set_cp_disp(0);
        set_cp_disp(1);
    }

    main_triggers_toggle();
}

set_cp_H_pointer()
{
    list textureParam = llGetLinkPrimitiveParams(llList2Integer(HUD_CP_ELES, 3), [PRIM_TEXTURE, 0]);
    // Debug("set_cp_H_pointer " + llDumpList2String(textureParam, ","));
    textureParam = llListReplaceList((textureParam = []) + textureParam, ["e9182b92-ff58-e1ac-0c92-224ab03620ad"], 0, 0);
    textureParam = llListReplaceList((textureParam = []) + textureParam, [<0, (1 - CP_HSV.x) * 0.95, 0>], 2, 2);
    llSetLinkPrimitiveParamsFast(llList2Integer(HUD_CP_ELES, 3), [PRIM_TEXTURE, 0] + textureParam);
    llSetLinkPrimitiveParamsFast(llList2Integer(HUD_CP_ELES, 2), [PRIM_COLOR, ALL_SIDES, HSV2RGB(<CP_HSV.x,1.0,1.0>), 1.0]);
    llSetLinkPrimitiveParamsFast(llList2Integer(HUD_CP_ELES, 5), [PRIM_COLOR, ALL_SIDES, HSV2RGB(CP_HSV), 1.0]);
}

set_cp_SV_pointer()
{
    list textureParam = llGetLinkPrimitiveParams(llList2Integer(HUD_CP_ELES, 4), [PRIM_TEXTURE, 0]);
    // Debug("set_cp_SV_pointer " + llDumpList2String(textureParam, ","));
    textureParam = llListReplaceList((textureParam = []) + textureParam, ["13584511-3904-d750-6697-b4d58f4d085e"], 0, 0);
    textureParam = llListReplaceList((textureParam = []) + textureParam, [<(0 - CP_HSV.y) * 0.9375, (1 - CP_HSV.z) * 0.9375, 0>], 2, 2);

    list colorParam = [PRIM_COLOR, 0, <1.0,1.0,1.0>, 1.0];
    if ( CP_HSV.z > 0.618 )
    {
        colorParam = llListReplaceList((colorParam = []) + colorParam, [<0.0, 0.0, 0.0>], 2, 2);
    }

    llSetLinkPrimitiveParamsFast(llList2Integer(HUD_CP_ELES, 4), [PRIM_TEXTURE, 0] + textureParam + colorParam);
    llSetLinkPrimitiveParamsFast(llList2Integer(HUD_CP_ELES, 5), [PRIM_COLOR, ALL_SIDES, HSV2RGB(CP_HSV), 1.0]);
}

set_cp_disp(integer type)
{   
    vector color = HSV2RGB(CP_HSV);
    CP_FIRE_COLOR = llListReplaceList((CP_FIRE_COLOR = []) + CP_FIRE_COLOR, [color], type, type);
    llSetLinkPrimitiveParamsFast(llList2Integer(HUD_CP_ELES, type + 7), [PRIM_COLOR, ALL_SIDES, color, 1.0]);
}

main_triggers_toggle()
{
    integer len = llGetListLength(COLOR_TRIG_SETS);
    integer i = 0;

    while(i < len)
    {
        set_link_alpha(llList2Integer(COLOR_TRIG_SETS, i++), STATUS_SHOW_CP);
    }
}

set_disp_fire_color(integer i)
{
    list colors = get_index_color(i);
    llSetLinkPrimitiveParamsFast(llList2Integer(COLOR_DISP_SETS, i), [PRIM_COLOR, ALL_SIDES, llList2Vector(colors, 0), 1.0]);
    llSetLinkPrimitiveParamsFast(llList2Integer(COLOR_DISP_SETS, i + 10), [PRIM_COLOR, ALL_SIDES, llList2Vector(colors, 1), 1.0]);
    Debug("SET_DISP " + (string)i + ":" + (string)llList2Integer(COLOR_DISP_SETS, i) + ":" + (string)llList2Vector(colors, 0) + ", " + (string)(i + 10) + ":" + (string)llList2Integer(COLOR_DISP_SETS, i + 10) + ":" + (string)llList2Vector(colors, 1));
}

// INIT
init_hud_units()
{

    // NAMES ======================

    COLOR_DISP_B = [
        "Display_0",
        "Display_1"
    ];

    HUD_PLUS_ELES = [
        "Plus_platform_0",
        "Plus_platform_1",
        "Plus_btns",
        "Plus_adjust_step_display",
        "Plus_float_display",
        "Plus_tail_display",
        "Plus_nut_display"
    ];

    HUD_CP_ELES = [
        "CP_platform_0",
        "CP_platform_1",
        "CP_SV_display",
        "CP_H_picker",
        "CP_SV_picker",
        "CP_color_display",
        "CP_save_fire",
        "CP_fire_0",
        "CP_fire_1",
        "CP_save_to"
    ];

    integer i;

    list disp_0;
    list disp_1;
    // FIRE
    i = 0;
    while(i < 10)
    {
        disp_0 = (disp_0 = []) + disp_0 + ["Display_" + (string)i + "_0"];
        disp_1 = (disp_1 = []) + disp_1 + ["Display_" + (string)i + "_1"];
        COLOR_TRIG_SETS = (COLOR_TRIG_SETS = []) + COLOR_TRIG_SETS + ["Trigger_" + (string)i];
        i++;
    }
    COLOR_DISP_SETS = (disp_0 = []) + disp_0 + (disp_1 = []) + disp_1;

    Debug("DISPLAY_NAMES: " + llDumpList2String(COLOR_DISP_SETS, ", "));
    Debug("DISPLAY_NAMES_B: " + llDumpList2String(COLOR_DISP_B, ", "));
    Debug("TRIGGER_NAMES: " + llDumpList2String(COLOR_TRIG_SETS, ", "));
    Debug("HUD_PLUS_ELES: " + llDumpList2String(HUD_PLUS_ELES, ", "));
    Debug("HUD_CP_ELES: " + llDumpList2String(HUD_CP_ELES, ", "));


    // KEYS ======================

    i = 0;
    integer len = llGetNumberOfPrims();
    integer prim_index;
    string linked_prim_name;

    while ( i <= len )
    {
        linked_prim_name = llGetLinkName(i);

        prim_index = llListFindList(COLOR_DISP_SETS, [linked_prim_name]);
        if( ~prim_index )
        {
            COLOR_DISP_SETS = llListReplaceList((COLOR_DISP_SETS = []) + COLOR_DISP_SETS, [i], prim_index, prim_index);
        }

        prim_index = llListFindList(COLOR_TRIG_SETS, [linked_prim_name]);
        if( ~prim_index )
        {
            COLOR_TRIG_SETS = llListReplaceList((COLOR_TRIG_SETS = []) + COLOR_TRIG_SETS, [i], prim_index, prim_index);
        }

        prim_index = llListFindList(COLOR_DISP_B, [linked_prim_name]);
        if( ~prim_index )
        {
            COLOR_DISP_B = llListReplaceList((COLOR_DISP_B = []) + COLOR_DISP_B, [i], prim_index, prim_index);
        }

        prim_index = llListFindList(HUD_PLUS_ELES, [linked_prim_name]);
        if( ~prim_index )
        {
            HUD_PLUS_ELES = llListReplaceList((HUD_PLUS_ELES = []) + HUD_PLUS_ELES, [i], prim_index, prim_index);
        }

        prim_index = llListFindList(HUD_CP_ELES, [linked_prim_name]);
        if( ~prim_index )
        {
            HUD_CP_ELES = llListReplaceList((HUD_CP_ELES = []) + HUD_CP_ELES, [i], prim_index, prim_index);
        }

        i++;
    }

    Debug("DISPLAY_KEYS: " + llDumpList2String(COLOR_DISP_SETS, ", "));
    Debug("DISPLAY_KEYS_B: " + llDumpList2String(COLOR_DISP_B, ", "));
    Debug("TRIGGER_KEYS: " + llDumpList2String(COLOR_TRIG_SETS, ", "));
    Debug("HUD_PLUS_ELES_KEY: " + llDumpList2String(HUD_PLUS_ELES, ", "));
    Debug("HUD_CP_ELES_KEY: " + llDumpList2String(HUD_CP_ELES, ", "));
    
    // DISP ======================

    plus_platform_toggle();
    cp_platform_toggle();
}

list get_index_color(integer index)
{
    list colors = llCSV2List(llList2String(COLOR_SETS, index));
    return [
        color_from_hex(llList2String(colors, 0)),
        color_from_hex(llList2String(colors, 1))
    ];
}

open_menu(key inputKey, string inputString, list inputList)
{
    DIALOG_CHANNEL = (integer)llFrand(DEBUG_CHANNEL) * -1;
    DIALOG_HANDLE = llListen(DIALOG_CHANNEL, "", inputKey, "");
    llDialog(inputKey, inputString, inputList, DIALOG_CHANNEL);
    llSetTimerEvent(30.0);
}

close_menu()
{
    llSetTimerEvent(0.0);
    llListenRemove(DIALOG_HANDLE);
}

reset()
{
    STATUS_SHOW_PLUS = 0;
    STATUS_TAIL = 0;
    STATUS_NUTS = 0;
    STATUS_FLOAT = 0;
    STATUS_SHOW_CP = 0;

    ADJUST_STEP = 0.01;

    CP_HSV = <0.0,1.0,1.0>;

    plus_platform_toggle();
    cp_platform_toggle();

    set_cp_H_pointer();
    set_cp_SV_pointer();
    set_cp_disp(0);
    set_cp_disp(1);
}

default
{
    state_entry()
    {

        Info("Loading color sets ...");

        integer type = llGetInventoryType(COLOR_SETS_CONF_FILE);
        if ( type == INVENTORY_NONE )
        {
            integer i = 0;
            while (i <= 9)
            {
                COLOR_SETS = (COLOR_SETS = []) + COLOR_SETS + ["#FFFFFF,#FFFFFF"];
                i++;
            }
            state Main;
        }
        else if( type == INVENTORY_NOTECARD )
        {
            notecard_query_id = llGetNotecardLine(COLOR_SETS_CONF_FILE, notecard_line);
        }
    }

    dataserver(key query_id, string data)
    {
        if (query_id == notecard_query_id)
        {
            if (data == EOF)
            {
                state Main;
            }
            else
            {
                COLOR_SETS = (COLOR_SETS = []) + COLOR_SETS + [data];
                ++notecard_line;
                Debug("Line " + (string) notecard_line + ": " + data);
                notecard_query_id = llGetNotecardLine(COLOR_SETS_CONF_FILE, notecard_line);
            }
        }
    }

    changed(integer change){
        if( change == CHANGED_INVENTORY)
        {
            llResetScript();
        }
    }
}

state Main
{
    state_entry(){

        
        Info("Load complete! " + (string)llGetListLength(COLOR_SETS) + " color configurations have been read.");
        Debug("COLOR_SETS " + "[" + llDumpList2String(COLOR_SETS, "], [") + "]");

        init_hud_units();

        integer i = 0;
        while ( i < 10 ){
            set_disp_fire_color(i++);
        }

        llListen(CONTROL_CHANNEL, "", NULL_KEY, "");
    }
    
    link_message(integer sender_num, integer num, string msg, key id)
    {
        integer i = (integer)msg * 2;
        Debug(llList2CSV([sender_num, num, msg, id]));
    }

    touch_start(integer num_detected)
    {
        integer index;
        integer touch_key = llDetectedLinkNumber(0);

        index = llListFindList(COLOR_TRIG_SETS, [touch_key]);
        if( ~index )
        {
            list colors = get_index_color(index);
            llSetLinkPrimitiveParamsFast(llList2Integer(COLOR_DISP_B, 0), [PRIM_COLOR, ALL_SIDES, llList2Vector(colors, 0), 1.0]);
            llSetLinkPrimitiveParamsFast(llList2Integer(COLOR_DISP_B, 1), [PRIM_COLOR, ALL_SIDES, llList2Vector(colors, 1), 1.0]);
            // send channl message
            Send(llList2Json(JSON_OBJECT, ["COLOR"] + [llList2String(COLOR_SETS, index)]));
        }


        index = llListFindList(HUD_PLUS_ELES, [touch_key]);
        if( ~index )
        {
            Debug("TOUCH HUD_PLUS_ELES " + (string)index + ":" + (string)llList2Integer(HUD_PLUS_ELES, index));

            integer touchFace = llDetectedTouchFace(0);
            vector touchST = llDetectedTouchST(0);

            if(index == 0 && STATUS_SHOW_PLUS == 0)
            {
                STATUS_SHOW_PLUS = 1;
                plus_platform_toggle();
            }
            else if(index == 2 && touchFace == 0 && STATUS_SHOW_PLUS == 1)
            {
                integer touched = llFloor((1 - touchST.y) * 2) * 8 + llFloor(touchST.x * 8);
                Debug((string)touchST + ", " + (string)touched);

                if(touched == 15)
                {
                    STATUS_SHOW_PLUS = 0;
                    plus_platform_toggle();
                }
                else if(touched == 13)
                {
                    close_menu();
                    open_menu(llGetOwner(), "\nHUD OPERSTION\n", ["RESET HUD", "RESET FIRE"]);
                }
                else if(touched == 14)
                {
                    Debug("AUTO ROUTE");
                }
                else if(touched == 12)
                {
                    STATUS_NUTS = (STATUS_NUTS + 1) % 2;
                    Send(llList2Json(JSON_OBJECT, ["NUTS"] + [(string)STATUS_NUTS]));
                    set_link_alpha(llList2Integer(HUD_PLUS_ELES, 6), STATUS_NUTS * 0.3);
                }
                else if(touched == 11)
                {
                    STATUS_TAIL = (STATUS_TAIL + 1) % 2;
                    Send(llList2Json(JSON_OBJECT, ["TAIL"] + [(string)STATUS_TAIL]));
                    set_link_alpha(llList2Integer(HUD_PLUS_ELES, 5), STATUS_TAIL * 0.3);
                }
                else if(touched == 10)
                {
                    STATUS_FLOAT = (STATUS_FLOAT + 1) % 2;
                    Send(llList2Json(JSON_OBJECT, ["FLOAT"] + [(string)STATUS_FLOAT]));
                    set_link_alpha(llList2Integer(HUD_PLUS_ELES, 4), STATUS_FLOAT * 0.3);
                }
                else if(touched == 9)
                {
                    Send(llList2Json(JSON_OBJECT, ["NUT"] + ["-"]));
                }  
                else if(touched == 8)
                {
                    Send(llList2Json(JSON_OBJECT, ["NUT"] + ["+"]));
                }
                else if(touched == 6)
                {
                    Send(llList2Json(JSON_OBJECT, ["POS"] + [-ADJUST_STEP]));
                }
                else if(touched == 5)
                {
                    Send(llList2Json(JSON_OBJECT, ["POS"] + [ADJUST_STEP]));
                }
                else if(touched == 4)
                {
                    Send(llList2Json(JSON_OBJECT, ["ROTATE"] + [-ADJUST_STEP]));
                }
                else if(touched == 3)
                {
                    Send(llList2Json(JSON_OBJECT, ["ROTATE"] + [ADJUST_STEP]));
                }
                else if(touched == 2)
                {
                    Send(llList2Json(JSON_OBJECT, ["RADIUS"] + [-ADJUST_STEP]));
                }
                else if(touched == 1)
                {
                    Send(llList2Json(JSON_OBJECT, ["RADIUS"] + [ADJUST_STEP]));
                }
                else if(touched == 0)
                {
                    integer len = llGetListLength(ADJUST_STEP_LIST);
                    integer si = llListFindList(ADJUST_STEP_LIST, [ADJUST_STEP]);
                    si ++;
                    if( si == len )
                    {
                        si = 0;
                    }
                    ADJUST_STEP = llList2Float(ADJUST_STEP_LIST, si);
                    adjust_step_display(1);
                }
            }
        }

        index = llListFindList(HUD_CP_ELES, [touch_key]);
        if( ~index )
        {
            Debug("TOUCH HUD_CP_ELES " + (string)index + ":" + (string)llList2Integer(HUD_CP_ELES, index));

            integer touchFace = llDetectedTouchFace(0);
            vector touchST = llDetectedTouchST(0);

            if( index == 0 && STATUS_SHOW_CP == 0 )
            {
                STATUS_SHOW_CP = 1;
                cp_platform_toggle();
            }
            else if( index == 3 && touchFace == 0 && STATUS_SHOW_CP == 1 )
            {
                // H picker
                CP_HSV.x = touchST.y;
                set_cp_H_pointer();
            }
            else if( index == 4 && touchFace == 0 && STATUS_SHOW_CP == 1 )
            {
                // SV Picker
                CP_HSV.y = touchST.x;
                CP_HSV.z = touchST.y;
                set_cp_SV_pointer();
            }
            else if( index == 6 && touchFace == 0 && STATUS_SHOW_CP == 1 )
            {
                // Save fire
                integer touched = llFloor((1 - touchST.y) * 2);
                Debug((string)touched);
                set_cp_disp(touched);
            }
            else if( index == 9 && touchFace == 0 && STATUS_SHOW_CP == 1 )
            {
                // Save to
                integer touched = llFloor((1 - touchST.y) * 3) * 4 + llFloor(touchST.x * 4);

                Debug((string)touched);

                if( touched < 10 )
                {
                    COLOR_SETS = llListReplaceList((COLOR_SETS = []) + COLOR_SETS, [listColor2HEX(CP_FIRE_COLOR)], touched, touched);
                    set_disp_fire_color(touched);
                }
                else if( touched == 11 )
                {
                    STATUS_SHOW_CP = 0;
                    cp_platform_toggle();
                }
            }
        }

    }

    listen(integer channel, string name, key id, string message)
    {
        Debug((string)channel + " " + name + " " + (string)id + " " + message);

        if( llGetOwnerKey(id) == llGetOwner() )
        {
            if( channel == DIALOG_CHANNEL )
            {
                close_menu();

                if( message == "RESET" )
                {
                    Send(llList2Json(JSON_OBJECT, ["ACTION"] + ["RESET"]));
                }
                else if( message == "RESET HUD" )
                {
                    open_menu(llGetOwner(), "\nResetting the HUD will clear all custom color settings.\nAre you sure?\n", ["CANCEL","YES RESET"]);
                }
                else if( message == "YES RESET" )
                {
                    llResetScript();
                }
                else if( message == "RESET FIRE")
                {
                    open_menu(llGetOwner(), "\nRESET FIRE AROUND BODY:\n\n* Fire nuts reset to 3\n* Postition\n* Rotation\n", ["CANCEL","RESET"]);
                }
            }

            if( channel == CONTROL_CHANNEL )
            {
                if( message == "DEBUG" )
                {
                    if ( DEBUG == 1 )
                    {
                        DEBUG = 0;
                        Info("DEBUG MODE: OFF");
                    }
                    else if( DEBUG == 0 )
                    {
                        DEBUG = 1;
                        Info("DEBUG MODE: ON");
                    }
                }
                else if( message == "POSIZE" )
                {
                    integer len;
                    integer i;
                    list L;

                    len = llGetListLength(HUD_PLUS_ELES);
                    i = 0;
                    L = [];
                    while(i < len)
                    {
                        L = (L = []) + L + llGetLinkPrimitiveParams(llList2Integer(HUD_PLUS_ELES, i), [PRIM_POS_LOCAL, PRIM_SIZE]);
                        i++;
                    }
                    Debug("HUD_PLUS_ELES_POSIZE: " + llDumpList2String(L, ", "));

                    len = llGetListLength(HUD_CP_ELES);
                    i = 0;
                    L = [];
                    while(i < len)
                    {
                        L = (L = []) + L + llGetLinkPrimitiveParams(llList2Integer(HUD_CP_ELES, i), [PRIM_POS_LOCAL, PRIM_SIZE]);
                        i++;
                    }
                    Debug("HUD_CP_ELES_POSIZE: " + llDumpList2String(L, ", "));
                }
                else if( message == "SHOWALL" )
                {
                    integer len = llGetListLength(HUD_PLUS_ELES);
                    integer i = 0;

                    while(i < len)
                    {
                        llSetLinkPrimitiveParamsFast(llList2Integer(HUD_PLUS_ELES, i), [
                            PRIM_POS_LOCAL, llList2Vector(HUD_PLUS_ELES_POSIZE, i * 2),
                            PRIM_SIZE, llList2Vector(HUD_PLUS_ELES_POSIZE, i * 2 + 1)
                        ]);
                        i++;
                    }

                    len = llGetListLength(HUD_CP_ELES);
                    i = 0;

                    while(i < len)
                    {
                        llSetLinkPrimitiveParamsFast(llList2Integer(HUD_CP_ELES, i), [
                            PRIM_POS_LOCAL, llList2Vector(HUD_CP_ELES_POSIZE, i * 2),
                            PRIM_SIZE, llList2Vector(HUD_CP_ELES_POSIZE, i * 2 + 1)
                        ]);
                        i++;
                    }
                }
            }
        }
    }

    timer()
    {
        close_menu();
    }

    changed(integer change){
        if( change == CHANGED_INVENTORY)
        {
            llResetScript();
        }
    }
}
