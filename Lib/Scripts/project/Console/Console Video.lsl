// This script would be used in the prim that will show the video on surface zero.
// Touching the prim will start or stop the video display set in Land Media: Video.
 
// Global Variable declarations
key DefTexture;
vector DefColor;
list data;
key texture;
integer IsPlaying;
 
default {
    state_entry() {
        DefTexture = llGetTexture(0);                   // Save default texture set on prim surface zero.
        DefColor = llGetColor(0);                       // Save default color of prim surface zero
        IsPlaying = FALSE;                              // Set playing flag to FALSE.
    }

    touch_start(integer total_number) {
        // Read land parcel media settings
        data = llParcelMediaQuery([PARCEL_MEDIA_COMMAND_TEXTURE, "http://unite.codante.org/media/sing_test.mp4"]);
        texture = (key) llList2String(data, 0);         // Get texture for parcel to display
        if (IsPlaying) {                                // Player has video active
            llParcelMediaCommandList([PARCEL_MEDIA_COMMAND_STOP]);     // Stop streaming to the device.
            llSetPrimitiveParams([PRIM_TEXTURE,0,DefTexture,<1,1,0>,ZERO_VECTOR,0.0,PRIM_COLOR,0,DefColor,1.0,PRIM_FULLBRIGHT,0,TRUE]);
            IsPlaying = FALSE;
        }
        else {                                          // Check if Parcel Video is available
            if (llList2String(data, 0) == "") {         // Not a landowner or land group member error display
                key ErrTexture = llGetInventoryKey("ErrMsg");         // Get texture by name from inventory
                llSetPrimitiveParams([PRIM_TEXTURE,0,ErrTexture,<1,1,0>,ZERO_VECTOR,0.0,PRIM_COLOR,0,<1,1,1>,1.0,PRIM_FULLBRIGHT,0,TRUE]);
            }
            else {                                      // Set texture
                llSetPrimitiveParams([PRIM_TEXTURE,0,texture,<1,1,0>,ZERO_VECTOR,0.0,PRIM_COLOR,0,<1,1,1>,1.0,PRIM_FULLBRIGHT,0,TRUE]);
                llParcelMediaCommandList([PARCEL_MEDIA_COMMAND_PLAY]); // Start media playing to this device
                IsPlaying = TRUE;
            }
        }
    }
}