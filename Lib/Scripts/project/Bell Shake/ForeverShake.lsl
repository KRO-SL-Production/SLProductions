float SPEED = 0.01;
integer LINK_NUM = 0;
integer FACE_D = 2;
list FACES = [0,1,2,3,4,5];
list FACE_ANIM = [2,1,0,1,2,3,4,3];
integer P = 0;
integer Q;
integer on_shaking = 0;

init()
{
    Q = llGetListLength(FACES);
    integer l = 0;
    while(l < Q)
    {
        llSetLinkAlpha(LINK_NUM, 0.0, llList2Integer(FACES, l));
        l++;
    }
    llSetLinkAlpha(LINK_NUM, 1.0, FACE_D);
}

default
{
    state_entry()
    {
        init();
        llSetTimerEvent(SPEED);
    }

    timer()
    {
        llSetLinkAlpha(LINK_NUM, 0.0, llList2Integer(FACE_ANIM, P));
        P++;
        if( P >= llGetListLength(FACE_ANIM) )
        {
            P = 0;
        }
        llSetLinkAlpha(LINK_NUM, 1.0, llList2Integer(FACE_ANIM, P));
    }

    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)         
        {
            init();
        }
    }
}