
integer DEBUG = 0;
string CONFIG_FILE = "config";

float SPEED_MOVE = 5;
float SPEED_ROTATE = 2;

string ANIMS = "{}";

integer MASTER_PRIM;
integer SLAVE_PRIM;

// For dataserver
key notecard_query_id;
integer notecard_line;

integer CHANNEL_CHAIN = -94835;

// Functions =============================================================================

Debug(string msg)
{
    if(DEBUG == 1)
    {
        Info(msg);
    }
}

Text(string msg)
{
    llSetText(msg, <1, 1, 1>, 1.0);
}

Info(string msg)
{
    llOwnerSay(msg);
}

Rotate(vector g)
{
    llSetRot(llEuler2Rot(llRot2Euler(llGetRot()) + g * DEG_TO_RAD));
}

unsetVehicle()
{
    llSetStatus(STATUS_PHYSICS, FALSE);
}

setVehicle()
{
    llSetStatus(STATUS_PHYSICS, TRUE);
    llSetPrimitiveParams([PRIM_MATERIAL, PRIM_MATERIAL_GLASS]);
    //car
    llSetVehicleType(VEHICLE_TYPE_CAR);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0.2);     // was 0.2
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0.80);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 0.10);
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 0.10);
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, 1.0);
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, 0.1);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, 0.1);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 0.1);
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.50);
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 0.50);
    llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <10.0, 2.0, 1000.0>);
    llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <0.1, 0.1, 0.1>);
}

default
{
    state_entry()
    {
        Text("");

        integer num = llGetNumberOfPrims();
        string name;
        while (num)
        {
            name = llGetLinkName(num);
            if (name == "MASTER")
            {
                MASTER_PRIM = num;
            }

            if (name == "SLAVE")
            {
                SLAVE_PRIM = num;
            }

            num--;
        }

        Debug("MASTER_PRIM:" + (string) MASTER_PRIM + ", SLAVE_PRIM:" + (string) SLAVE_PRIM);

        llSetLinkAlpha(MASTER_PRIM, 0.75, ALL_SIDES);
        llSetLinkAlpha(SLAVE_PRIM, 0.75, ALL_SIDES);

        Text("Loading configuration ...");

        integer type = llGetInventoryType(CONFIG_FILE);

        if ( type == INVENTORY_NONE )
        {
            Text("Config file is not exists!");
        }
        else if( type == INVENTORY_NOTECARD )
        {
            notecard_query_id = llGetNotecardLine(CONFIG_FILE, notecard_line);
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
                data = llStringTrim(data, STRING_TRIM);

                if ( data != "" && llSubStringIndex(data, "#") != 0 )
                {
                    Debug("Line " + (string) notecard_line + ": " + data);
                    list option = llParseString2List(data, [":"], []);
                    string _k = llStringTrim(llList2String(option, 0), STRING_TRIM);
                    string _v = llStringTrim(llList2String(option, 1), STRING_TRIM);
                    if( _v != "")
                    {
                        Debug(llList2String(option, 0) + " " + llList2String(option, 1));
                        ANIMS = llJsonSetValue(ANIMS, [_k], _v);
                    }
                }
                ++notecard_line;
                notecard_query_id = llGetNotecardLine(CONFIG_FILE, notecard_line);
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
    state_entry()
    {
        Debug(ANIMS);
        Text("");
        // Sit target 1 is your sit target on the root prim
        llLinkSitTarget(MASTER_PRIM, <0.0,0.0,1.25>, ZERO_ROTATION);
        // Sit target 2 is the target on child prim 2, a small transparent prim inside the object
        llLinkSitTarget(SLAVE_PRIM, <-0.05,0.0,1.5>, ZERO_ROTATION);
    }
 
    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            // Now pay attention to the avatar on the root prim.
            if (llAvatarOnLinkSitTarget(MASTER_PRIM) != NULL_KEY)
            {
                // llSay(PUBLIC_CHANNEL, "Hello Master");
                llRequestPermissions(llAvatarOnLinkSitTarget(MASTER_PRIM), PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS);
                llSetLinkAlpha(MASTER_PRIM, 0.0, ALL_SIDES);
            }
            else
            {
                llSetLinkAlpha(MASTER_PRIM, 0.75, ALL_SIDES);
            }

            // An avatar on child prim 2, whether seated by choice or by redirection after sit target 1 is occupied, will be unseated.
            if (llAvatarOnLinkSitTarget(SLAVE_PRIM) != NULL_KEY)
            {
                // llSay(PUBLIC_CHANNEL, "Hello Slave");
                llMessageLinked(LINK_THIS, 0, llJsonGetValue(ANIMS, ["HANGUP"]), llAvatarOnLinkSitTarget(SLAVE_PRIM));
                llSetLinkAlpha(SLAVE_PRIM, 0.0, ALL_SIDES);
            }
            else
            {
                llSetLinkAlpha(SLAVE_PRIM, 0.75, ALL_SIDES);
            }

            if (llAvatarOnLinkSitTarget(MASTER_PRIM) != NULL_KEY && llAvatarOnLinkSitTarget(SLAVE_PRIM) != NULL_KEY)
            {
                llSay(CHANNEL_CHAIN, "CONNECT");
                setVehicle();
            }
            else
            {
                llSay(CHANNEL_CHAIN, "DISCONNECT");
                unsetVehicle();
            }
        }
    }

    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {
            llStopAnimation("sit");
            llStartAnimation(llJsonGetValue(ANIMS, ["STANDING"]));
        }

        if (perm & PERMISSION_TAKE_CONTROLS)
        {
            llTakeControls(
                CONTROL_FWD |
                CONTROL_BACK |
                CONTROL_LEFT |
                CONTROL_RIGHT |
                CONTROL_ROT_LEFT |
                CONTROL_ROT_RIGHT |
                CONTROL_UP |
                CONTROL_DOWN |
                CONTROL_LBUTTON |
                CONTROL_ML_LBUTTON |
                0, TRUE, FALSE
            );
        }
    }

    control(key id, integer level, integer edge)
    {
        // Debug((string)id + "," + (string)level + "," + (string)edge);
        
        integer reverse = 1;
        vector angular_motor;
 
        //get current speed
        vector vel = llGetVel();
        float speed = llVecMag(vel);
 
        if( level & CONTROL_FWD )
        {
            reverse = 1;
            llStartAnimation(llJsonGetValue(ANIMS, ["WALKING"]));
            llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <10.0, 2.0, 1000.0>);
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <SPEED_MOVE, 0, 0>);
        }

        if( edge & CONTROL_FWD )
        {
            llStopAnimation(llJsonGetValue(ANIMS, ["WALKING"]));
        }

        if( level & CONTROL_BACK )
        {
            reverse = -1;
            llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <10.0, 2.0, 1000.0>);
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <SPEED_MOVE * reverse, 0, 0>);
        }

        if( level & (CONTROL_LEFT|CONTROL_ROT_LEFT) )
        {
            llStartAnimation(llJsonGetValue(ANIMS, ["WALKING"]));
            //llStartAnimation(llJsonGetValue(ANIMS, ["TURNING_LEFT"]));
            angular_motor.z += SPEED_ROTATE;
        }

        if( edge & (CONTROL_LEFT|CONTROL_ROT_LEFT) )
        {
            llStopAnimation(llJsonGetValue(ANIMS, ["WALKING"]));
            //llStopAnimation(llJsonGetValue(ANIMS, ["TURNING_LEFT"]));
        }

        if( level & (CONTROL_RIGHT|CONTROL_ROT_RIGHT) )
        {
            llStartAnimation(llJsonGetValue(ANIMS, ["WALKING"]));
            //llStartAnimation(llJsonGetValue(ANIMS, ["TURNING_RIGHT"]));
            angular_motor.z -= SPEED_ROTATE;
        }

        if( edge & (CONTROL_RIGHT|CONTROL_ROT_RIGHT) )
        {
            llStopAnimation(llJsonGetValue(ANIMS, ["WALKING"]));
            //llStopAnimation(llJsonGetValue(ANIMS, ["TURNING_RIGHT"]));
        }

        if( level & CONTROL_UP )
        {
            //llSetRegionPos(llGetPos() + (<0,0,SPEED_MOVE>) * llGetRot());
        }

        if( level & CONTROL_DOWN )
        {
            //llSetRegionPos(llGetPos() + (<0,0,-SPEED_MOVE>) * llGetRot());
        }

        llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_motor);
    }
}