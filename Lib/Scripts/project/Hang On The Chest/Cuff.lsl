float age = 0.5;
string texturename = "chain";
integer CHANNEL = -94836;
integer CHANNEL_ADJUST = 999;
string NAME;

default
{
    state_entry()
    {
        NAME = llStringTrim(llGetObjectDesc(), STRING_TRIM);
        llSetText("", <0, 0, 0>, 0.0);
        if ( NAME == "" )
        {
            llSetText("The name is not set", <1, 0.255, 0.212>, 1.0);
        }
        else
        {
            llOwnerSay("Type in public chat \"/999 show\" OR \"/999 hide\" toggle display");
            llListen(CHANNEL, "", NULL_KEY, "");
            llListen(CHANNEL_ADJUST, "", NULL_KEY, "");
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        if ( channel == CHANNEL )
        {
            // llOwnerSay(name + " " + (string)id + " " + message);

            list commands = llParseString2List(message, [":"], []);
            string N = llList2String(commands, 0);
            string C = llList2String(commands, 1);

            if ( N == NAME )
            {
                if ( C == "CONNECT" )
                {
                    llParticleSystem([
                        // Appearance Settings
                        PSYS_PART_START_SCALE,(vector) <0.065,0.065,0>,// Start Size, (minimum .04, max 10.0?)
                        PSYS_PART_END_SCALE,(vector) <1,1,0>,     // End Size,  requires *_INTERP_SCALE_MASK
                        PSYS_PART_START_COLOR,(vector) <1,1,1>,   // Start Color, (RGB, 0 to 1)
                        PSYS_PART_END_COLOR,(vector) <1,1,1>,     // EndC olor, requires *_INTERP_COLOR_MASK
                        PSYS_PART_START_ALPHA,(float) 1.0,        // startAlpha (0 to 1),
                        PSYS_PART_END_ALPHA,(float) 1.0,          // endAlpha (0 to 1)
                        PSYS_SRC_TEXTURE,(string) texturename,    // name of a 'texture' in emitters inventory
                        // Flow Settings, keep (age/rate)*count well below 4096 !!!
                        PSYS_SRC_BURST_PART_COUNT,(integer) 1,    // # of particles per burst
                        PSYS_SRC_BURST_RATE,(float) 0.0,          // delay between bursts
                        PSYS_PART_MAX_AGE,(float) age,              // how long particles live
                        PSYS_SRC_MAX_AGE,(float) 0.0,             // turns emitter off after 15 minutes. (0.0 =never)
                        // Placement Settings
                        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP,
                        // _PATTERN can be: *_EXPLODE, *_DROP, *_ANGLE, *ANGLE_CONE or *_ANGLE_CONE_EMPTY
                        PSYS_SRC_BURST_RADIUS,(float) 0.5,        // How far from emitter new particles start,
                        PSYS_SRC_INNERANGLE,(float) 0.0,          // aka 'spread' (0 to 2*PI),
                        PSYS_SRC_OUTERANGLE,(float) 0.0,          // aka 'tilt' (0(up), PI(down) to 2*PI),
                        PSYS_SRC_OMEGA,(vector) <0,0,0>,          // how much to rotate around x,y,z per burst,
                        // Movement Settings
                        PSYS_SRC_ACCEL,(vector) <0,0,0>,          // aka gravity or push, ie <0,0,-1.0> = down
                        PSYS_SRC_BURST_SPEED_MIN,(float) 1000.0,  // Minimum velocity for new particles
                        PSYS_SRC_BURST_SPEED_MAX,(float) 1000.0,  // Maximum velocity for new particles
                        PSYS_SRC_TARGET_KEY,(key) id,    // key of a target, requires *_TARGET_POS_MASK
                        // for *_TARGET try llGetKey(), or llGetOwner(), or llDetectedKey(0) even. :)
                        PSYS_PART_FLAGS,      // Remove the leading // from the options you want enabled:
                        //PSYS_PART_EMISSIVE_MASK |           // particles glow
                        //PSYS_PART_BOUNCE_MASK |             // particles bounce up from emitter's 'Z' altitude
                        //PSYS_PART_WIND_MASK |               // particles get blown around by wind
                        PSYS_PART_FOLLOW_VELOCITY_MASK |    // particles rotate towards where they're going
                        PSYS_PART_FOLLOW_SRC_MASK |         // particles move as the emitter moves
                        //PSYS_PART_INTERP_COLOR_MASK |       // particles change color depending on *_END_COLOR
                        //PSYS_PART_INTERP_SCALE_MASK |       // particles change size using *_END_SCALE
                        PSYS_PART_TARGET_POS_MASK |         // particles home on *_TARGET key
                        0 // Unless you understand binary arithmetic, leave this 0 here. :)
                    ]);
                }
                else
                {
                    llParticleSystem([]);
                }
            }
        }
        else if ( channel == CHANNEL_ADJUST )
        {
            if ( id == llGetOwner() )
            {
                if ( message == "hide" )
                {
                    llSetAlpha(0.0, ALL_SIDES);
                }
                else if ( message == "show" )
                {
                    llSetAlpha(1.0, ALL_SIDES);
                }
            }
        }
    }

    changed(integer change)
    {
        if ( change == CHANGED_INVENTORY )
        {
            llResetScript();
        }
    }
}
