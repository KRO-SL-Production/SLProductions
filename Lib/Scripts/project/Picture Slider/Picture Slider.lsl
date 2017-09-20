list slides;

integer index;

newSlide()
{
    integer len = llGetListLength(slides);
    if(len > 0)
    {
        string texture = llList2String(slides, index++);
        llSetTexture(texture, 0);
        if(index>=llGetListLength(slides) )
            index = 0;
    }
}



default
{
    state_entry()
    {
        integer count = llGetInventoryNumber(INVENTORY_TEXTURE);  // Count of all items in prim's contents
        while (count--)
        {
            slides += llGetInventoryName(INVENTORY_TEXTURE, count);   // add all contents except this script, to a list
        }
        
        index = 0;
        newSlide();
        llSetTimerEvent(30);
    }

    touch_start(integer num)
    {
        newSlide();
    }

    timer()
    {
        newSlide();
    }
    
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)         
        {
            llResetScript();
        }
    }
}