integer step = 0;
list sh = [1.2, -1.0];
integer status = 0;
list st = [0.0, 1.0, 0.2];

float length = 0;

initLength()
{
    vector wrap = llList2Vector(llGetLinkPrimitiveParams(LINK_ROOT, [
        PRIM_SIZE
    ]), 0);

    vector size = llList2Vector(llGetLinkPrimitiveParams(2, [
        PRIM_SIZE
    ]), 0);

    length = size.z - (wrap.x * 2);
}

default
{
    state_entry()
    {
        initLength();
    }

    touch_start(integer num)
    {
        status = (status + 1) % llGetListLength(st);
        llSetTimerEvent(llList2Float(st, status));

        if(status == 0)
        {
            step = 0;
            llSetLinkPrimitiveParamsFast(2, [
                PRIM_POSITION, <llList2Float(sh, step) * length, 0.0, 0.0>
            ]);
        }
    }

    timer()
    {
        llSetLinkPrimitiveParamsFast(2, [
            PRIM_POSITION, <llList2Float(sh, step) * length, 0.0, 0.0>
        ]);
        step = (step + 1) % llGetListLength(sh);
    }

    changed(integer change)
    {
        initLength();
    }
}