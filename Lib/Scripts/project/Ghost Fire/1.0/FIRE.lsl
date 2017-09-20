// LSL: Ghost Fire
// shinate

//Listen channel
integer CHANNEL = -984917989;
integer CONTROL_CHANNEL = -2873;

// LINKED PRIMS
list NUTS;
integer nut_num = 10;
integer default_nut_num = 3;
integer actived_nut_num = 0;

// Status
float R = 1.0;
float RO = 0.0;
float P = 0.0;

// STATUS ===========================

// NUTS
integer STATUS_NUTS = 0;
float NUTS_ALPHA = 1.0;

// Float
integer STATUS_FLOAT = 0;
float FLOAT_AMP = 0.05;
float FLOAT_SPEED = 0.1;
integer FLOAT_ACCURACY = 40;
integer FLOAT_CURRENT_PROGRESS = 0;
list NUTS_FLOAT_PROGRESS;

// Fire
integer glow = TRUE;
integer bounce = FALSE;
integer interpColor = TRUE;
integer interpSize = TRUE;
integer wind = FALSE;
integer followSource = TRUE;
integer followVel = TRUE;

integer pattern = PSYS_SRC_PATTERN_EXPLODE;

key target = "";

float age = 1.5;
float maxSpeed = 0.1;
float minSpeed = 0.0;
string texture;
float startAlpha = 10.6;
float endAlpha = 0.05;
vector startColor = <1,1,1>;
vector endColor = <1,1,1>;
vector startSize = <0.4,0.4,0>;
vector endSize = <0,0,2>;
vector push = <0,0,1>;

float rate = 0.0;
float radius = 0.01;
integer count = 20;
float outerAngle = 0;
float innerAngle = 1.55;
vector omega = <0,0,0>;
float life = 0;

integer flags;

integer DEBUG = 0;

Debug(string msg)
{
    if(DEBUG == 1)
    {
        llOwnerSay(msg);
    }
}

vector color_from_hex(string str) {
    return <(integer)("0x" + llGetSubString(str,1,2)),
            (integer)("0x" + llGetSubString(str,3,4)),
            (integer)("0x" + llGetSubString(str,5,6))> / 255;
}

vector get_nut_pos(integer total, integer num)
{
    return <R * llCos(TWO_PI / total * num),
            R * llSin(TWO_PI / total * num),
            0.0>;
}

rotation get_nut_rot(float deg)
{
    return llEuler2Rot(<0,0,deg> * DEG_TO_RAD);
}

// set float status
set_actived_nut_float()
{
    integer i = 0;
    integer prim_key;
    vector currentPOS;
    vector newPos;
    integer progress;

    while (i < actived_nut_num)
    {
        prim_key = llList2Integer(NUTS, i);
        currentPOS = llList2Vector(llGetLinkPrimitiveParams(prim_key, [PRIM_POS_LOCAL]), 0);
        if(STATUS_FLOAT == 1)
        {
            progress = (integer)llFrand(FLOAT_ACCURACY);
            newPos = <currentPOS.x, currentPOS.y, FLOAT_AMP * llSin(TWO_PI * progress / FLOAT_ACCURACY)>;
            NUTS_FLOAT_PROGRESS = llListReplaceList((NUTS_FLOAT_PROGRESS = []) + NUTS_FLOAT_PROGRESS, [progress], i, i);
        }
        else
        {
            newPos = <currentPOS.x, currentPOS.y, 0>;
        }
        Debug("set_actived_nut_float " + (string)currentPOS + " " + (string)newPos);
        llSetLinkPrimitiveParamsFast(prim_key, [
            PRIM_POS_LOCAL, newPos
        ]);
        i++;
    }

    if(STATUS_FLOAT == 1)
    {
        llSetTimerEvent(FLOAT_SPEED);
    }
    else
    {
        llSetTimerEvent(0.0);
    }
}

// On timer
update_actived_nut_float()
{
    integer i = 0;
    integer prim_key;
    vector currentPOS;

    while (i < actived_nut_num)
    {
        prim_key = llList2Integer(NUTS, i);
        currentPOS = llList2Vector(llGetLinkPrimitiveParams(prim_key, [PRIM_POS_LOCAL]), 0);
        llSetLinkPrimitiveParamsFast(prim_key, [
            PRIM_POS_LOCAL, <currentPOS.x, currentPOS.y, FLOAT_AMP * llSin(TWO_PI * ((FLOAT_CURRENT_PROGRESS + llList2Integer(NUTS_FLOAT_PROGRESS, i)) % FLOAT_ACCURACY) / FLOAT_ACCURACY)>
        ]);
        i++;
    }

    FLOAT_CURRENT_PROGRESS++;

    if(FLOAT_CURRENT_PROGRESS == FLOAT_ACCURACY){
        FLOAT_CURRENT_PROGRESS = 0;
    };
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

set_actived_nut_alpha()
{
    integer i = 0;
    integer prim_key;
    float nuts_default_alpha = 0.0;

    while(i < actived_nut_num)
    {
        prim_key = llList2Integer(NUTS, i);
        if(STATUS_NUTS == 1)
        {
            nuts_default_alpha = NUTS_ALPHA;
        }
        set_link_alpha(prim_key, nuts_default_alpha);
        i++;
    }
}

init_nuts()
{
    integer i;

    i = 0;
    while(i < nut_num)
    {
        NUTS = (NUTS = []) + NUTS + ["Nut_" + (string)i];
        i++;
    }
    Debug("NUT_NAMES: " + llDumpList2String(NUTS, ", "));

    i = 0;
    integer len = llGetNumberOfPrims();
    integer prim_index;
    string linked_prim_name;
    while (i <= len)
    {
        linked_prim_name = llGetLinkName(i);

        prim_index = llListFindList(NUTS, [linked_prim_name]);
        if( ~prim_index )
        {
            NUTS = llListReplaceList((NUTS = []) + NUTS, [i], prim_index, prim_index);
            NUTS_FLOAT_PROGRESS = (NUTS_FLOAT_PROGRESS = []) + NUTS_FLOAT_PROGRESS + [0];
        }
        i++;
    }

    actived_nut_num = default_nut_num;

    Debug("NUT_KEYS: " + llDumpList2String(NUTS, ", "));
    Debug("ACTIVED_NUT: " + (string)actived_nut_num);
}

ActiveParticles() {
    flags = 0;
    if (target == "owner") target = llGetOwner();
    if (target == "self") target = llGetKey();
    if (glow) flags = flags | PSYS_PART_EMISSIVE_MASK;
    if (bounce) flags = flags | PSYS_PART_BOUNCE_MASK;
    if (interpColor) flags = flags | PSYS_PART_INTERP_COLOR_MASK;
    if (interpSize) flags = flags | PSYS_PART_INTERP_SCALE_MASK;
    if (wind) flags = flags | PSYS_PART_WIND_MASK;
    if (followSource) flags = flags | PSYS_PART_FOLLOW_SRC_MASK;
    if (followVel) flags = flags | PSYS_PART_FOLLOW_VELOCITY_MASK;
    if (target != "") flags = flags | PSYS_PART_TARGET_POS_MASK;

    llLinkParticleSystem(LINK_SET, []);

    integer i = 0;
    integer prim_key;
    float nuts_default_alpha = 0.0;

    while(i < actived_nut_num)
    {
        prim_key = llList2Integer(NUTS, i);

        llLinkParticleSystem(prim_key, [
            PSYS_PART_MAX_AGE, age,
            PSYS_PART_FLAGS, flags,
            PSYS_PART_START_COLOR, startColor,
            PSYS_PART_END_COLOR, endColor,
            PSYS_PART_START_SCALE, startSize,
            PSYS_PART_END_SCALE, endSize,
            PSYS_SRC_PATTERN, pattern,
            PSYS_SRC_BURST_RATE, rate,
            PSYS_SRC_ACCEL, push,
            PSYS_SRC_BURST_PART_COUNT, count,
            PSYS_SRC_BURST_RADIUS, radius,
            PSYS_SRC_BURST_SPEED_MIN, minSpeed,
            PSYS_SRC_BURST_SPEED_MAX, maxSpeed,
            PSYS_SRC_TARGET_KEY, target,
            PSYS_SRC_ANGLE_BEGIN, innerAngle,
            PSYS_SRC_ANGLE_END, outerAngle,
            PSYS_SRC_OMEGA, omega,
            PSYS_SRC_MAX_AGE, life,
            PSYS_SRC_TEXTURE, texture,
            PSYS_PART_START_ALPHA, startAlpha,
            PSYS_PART_END_ALPHA, endAlpha
        ]);
        
        if(STATUS_NUTS == 1)
        {
            nuts_default_alpha = NUTS_ALPHA;
        }
        llSetLinkPrimitiveParamsFast(prim_key, [PRIM_COLOR, ALL_SIDES, startColor, nuts_default_alpha]);

        i++;
    }
}

ActiveNuts()
{
    integer len = llGetListLength(NUTS);
    integer i = 0;
    integer prim_key;
    float nuts_default_alpha;

    while( i < len )
    {
        prim_key = llList2Integer(NUTS, i);

        if( prim_key )
        {

            if (i < actived_nut_num)
            {
                if(STATUS_NUTS == 1)
                {
                    nuts_default_alpha = NUTS_ALPHA;
                }
                else
                {
                    nuts_default_alpha = 0.0;
                }

                llSetLinkPrimitiveParamsFast(prim_key, [
                    PRIM_POS_LOCAL, get_nut_pos(actived_nut_num, i),
                    PRIM_GLOW, ALL_SIDES, 0.5
                ]);

                Debug("SHOW " + (string)prim_key + " " + (string)get_nut_pos(actived_nut_num, i));
            }
            else
            {
                nuts_default_alpha = 0.0;
                llSetLinkPrimitiveParamsFast(prim_key, [
                    PRIM_POS_LOCAL, <0,0,0>,
                    PRIM_GLOW, ALL_SIDES, 0.0
                ]);

                Debug("HIDE " + (string)prim_key + " " + (string)<0,0,0>);
            }

            set_link_alpha(prim_key, nuts_default_alpha);

        }
        i++;
    }

    ActiveParticles();
}

default {

    state_entry() {

        llSetLinkPrimitiveParamsFast(LINK_ROOT, [
            PRIM_COLOR, ALL_SIDES, <0,0,0>, 0.0
        ]);

        init_nuts();

        ActiveNuts();

        llListen(CHANNEL, "", NULL_KEY, "");
        llListen(CONTROL_CHANNEL, "", NULL_KEY, "");
    }
    
    // change color
    listen(integer channel, string name, key id, string message) {

        Debug(message);

        if( llGetOwnerKey(id) == llGetOwner() )
        {

            if( channel == CHANNEL )
            {
                list msg = llJson2List(message);

                string command = llList2String(msg, 0);
                string content = llList2String(msg, 1);

                if( command == "COLOR" )
                {
                    list color = llCSV2List(content);

                    startColor = color_from_hex(llList2String(color, 0));
                    endColor = color_from_hex(llList2String(color, 1));

                    ActiveParticles();
                }
                else if( command == "NUT" )
                {
                    integer len = llGetListLength(NUTS);
                    if ( content == "+" )
                    {
                        actived_nut_num += 1;
                        if(actived_nut_num > len)
                        {
                            actived_nut_num = len;
                        }
                    }
                    else if( content == "-" )
                    {
                        actived_nut_num -= 1;
                        if(actived_nut_num < 0)
                        {
                            actived_nut_num = 0;
                        }
                    }
                    
                    ActiveNuts();
                }
                else if( command == "ROTATE" )
                {
                    float step = (float)content;
                    RO += 360 * step;
                    if(RO > 360)
                    {
                        RO -= 360;
                    }
                    else if(RO < 0)
                    {
                        RO += 360;
                    }

                    rotation rot = get_nut_rot(RO);

                    llSetLinkPrimitiveParamsFast(LINK_ROOT, [
                        PRIM_ROT_LOCAL, rot
                    ]);

                    Debug("CURRENT ROTATE: " + (string)rot);
                }
                else if( command == "RADIUS" )
                {
                    float step = (float)content;
                    R += step;
                    if( R < 0 )
                    {
                        R = 0.0;
                    }
                    ActiveNuts();

                    Debug("CURRENT RADIUS: " + (string)R);
                }
                else if( command == "POS" )
                {
                    float step = (float)content;
                    P += step;

                    vector pos = <0,0,P>;

                    llSetLinkPrimitiveParamsFast(LINK_ROOT, [
                        PRIM_POS_LOCAL, pos
                    ]);

                    Debug("CURRENT POS: " + (string)pos);
                }
                else if( command == "NUTS" )
                {
                    if ( content == "0" )
                    {
                        STATUS_NUTS = 0;
                    }
                    else if( content == "1" )
                    {
                        STATUS_NUTS = 1;
                    }
                    set_actived_nut_alpha();
                }
                else if( command == "TAIL" )
                {
                    if ( content == "0" )
                    {
                        followSource = TRUE;
                    }
                    else if( content == "1" )
                    {
                        followSource = FALSE;
                    }

                    ActiveParticles();
                }
                else if( command == "FLOAT" )
                {
                    if ( content == "0" )
                    {
                        STATUS_FLOAT = 0;
                    }
                    else if( content == "1" )
                    {
                        STATUS_FLOAT = 1;
                    }
                    set_actived_nut_float();
                }
                else if( command == "ACTION" )
                {
                    if( content == "RESET" )
                    {
                        RO = 0.0;
                        P = 0.0;
                        R = 1.0;
                        actived_nut_num = default_nut_num;

                        llSetLinkPrimitiveParamsFast(LINK_ROOT, [
                            PRIM_ROT_LOCAL, get_nut_rot(RO),
                            PRIM_POS_LOCAL, <0,0,P>
                        ]);
                        
                        ActiveNuts();
                    }
                }
            }

            if( channel == CONTROL_CHANNEL )
            {
                if( message == "DEBUG" )
                {
                    if ( DEBUG == 1 )
                    {
                        DEBUG = 0;
                        llOwnerSay("DEBUG MODE: OFF");
                    }
                    else if( DEBUG == 0 )
                    {
                        DEBUG = 1;
                        llOwnerSay("DEBUG MODE: ON");
                    }
                }
            }
        }
    }

    attach(key id)
    {
        STATUS_FLOAT = 0;
    }
    
    timer()
    {
        update_actived_nut_float();
    }
}