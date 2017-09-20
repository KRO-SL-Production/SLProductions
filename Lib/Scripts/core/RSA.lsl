//
// Linden Scripting Language RSA Cryptography Library V1.0
//
// Scott Guthery, November 3, 2006
// sbg at acw.com
//
// "It's not how well the dog sings, it's that the dog sings at all."

// A BigNum is a list: [ LeastSignificantDigit ... MostSignificantDigit... Width ]
//                      <===================== DIGITS+1=========================>

integer DIGITS = 8;

integer DIGITLOGBITS = 4;
integer DIGITLOGMASK = 0x0F;
integer DIGITBITS    = 16;
integer DIGITMASK    = 0xFFFF;
integer OVERFLOWMASK = 0xFFFF0000;
integer DIGITMSBIT   = 0x00008000;
integer SIGNBIT      = 0x80000000;

integer shiftLength;
list ZEROS;

// list SetDigit(list a, integer n, integer value);
// integer GetDigit(list a, integer n);
// list SetWidth(list a, integer width);
// integer GetWidth(list a);

// list BigNumZero(integer width);
// list BigNumFromInt(integer value);
// list BigNumFromList(list value, integer length);
// integer BigNumBitIsSet(list a, integer bitIndex);
// list BigNumCopy(list a);
// integer BigNumNumSignificantDigits(list a);
// integer BigNumUCompare(list a, list b);
// list BigNumUShiftRight(list operand, integer shiftSize, integer operandLength);
// list BigNumUShiftLeft(list operand, integer shiftSize, integer operandLength);
// list BigNumMod(list a, list p);
// list BigNumSub(list a, list b);
// integer BigNumEstimateQuotientDigit(integer u2, integer u1, integer u0, integer v1, integer v0);
// list BigNumDivide(list a, list p, integer qorr);
// integer BigNumNi0(integer n);
// list BigNumMod(list a, list p);
// list BigNumModMult(list a, list b1, list n, integer ni0);
// list BigNumModExp(list a, list b, list n, integer ni0);

// integer unsigned_divide(integer dividend, integer divisor);
// integer greater_than(integer a, integer b);

// list encrypt(list plaintext, list privateKey, list modulus);
// list decrypt(list cryptogram, list publicKey, list modulus);

list encrypt(list plaintext, list privateKey, list modulus)
{
    return BigNumModExp(plaintext, privateKey, modulus,
        BigNumNi0(GetDigit(modulus,0)));
}

list decrypt(list cryptogram, list publicKey, list modulus)
{
    return BigNumModExp(cryptogram, publicKey, modulus,
        BigNumNi0(GetDigit(modulus,0)));
}

list SetDigit(list a, integer n, integer value)
{
    return llListReplaceList(a, [ value & DIGITMASK ], n, n);
}

list SetDigit2(list a, integer n, integer value1, integer value2)
{
    return llListReplaceList(a, [ value1 & DIGITMASK, value2 & DIGITMASK
        ], n, n + 1);
}

integer GetDigit(list a, integer n)
{
    return (llList2Integer(a, n) & DIGITMASK);
}

list SetWidth(list a, integer width)
{
    return llListReplaceList(a, [ width & DIGITMASK ], DIGITS, DIGITS);
}

integer GetWidth(list a)
{
    return llList2Integer(a, DIGITS);
}

list BigNumModExp(list a, list b, list n, integer ni0)
{
    integer w;
    integer counter = 0;
    integer stage = 0;
    list t;

    while (TRUE)
    {
        if (stage == 0)
        {
            // Set counter to the most significant exponent bit that is
            non-zero.
            w = GetWidth(b);
            for (counter = (w * DIGITBITS) - 1;
                counter >= 0;
                --counter)
            {
                if (BigNumBitIsSet(b, counter))
                jump break;
            }

            @break;
            if (!BigNumBitIsSet(b, counter))
            {
                return BigNumFromInteger(1);
            }
            // Initialize t to the input a.
            t = a;
            if (counter == 0)
            {
                stage = 2;
            }
            else
            {
                --counter;
                ++stage;
            }
        }
        else if (stage == 1)
        {
            t = BigNumModMult(t, t, n, ni0);
            if (BigNumBitIsSet(b, counter))
            {
                // Exponent bit is set, multiply in a
                t = BigNumModMult(t, a, n, ni0);
            }
            if ( counter > 0 )
            --counter;
            else
            ++stage;
        }
        else if (stage == 2)
        {
            jump done;
        }
    }

    @done;
    return t;
}

integer BigNumNi0(integer n)
{
    integer temp;
    integer y;
    integer x;
    integer ti;
    integer mmi;
    integer i;

    x = n;
    y = 1;
    ti = 2;
    mmi = 3;
    for (i = 1; i < DIGITBITS; i++)
    {
        temp = (x * y) & DIGITMASK;
        temp = temp & mmi;
        if (ti < temp)
        {
            y = (y + ti) & DIGITMASK;
        }
        ti = (ti << 1) & DIGITMASK;
        mmi = (( mmi << 1 ) | 0x1) & DIGITMASK;
    }

    // ni0 = -y mod 2**w
    y = (y ^ DIGITMASK);
    y = (y + 1) & DIGITMASK;

    return y;
}

// Koc, C.K., T. Acar, B. S. Kaliski, "Analyzing and Comparing Montgomery
// Multiplication Algorithms," IEEE Micro, 16 (3), June, 1996, pp. 26-33.
// Algorithm is the Coarse Operand Integration Scanning (COIS)

list BigNumModMult(list a, list b1, list n, integer ni0)
{
    integer temp;
    integer carry = 0;
    integer m;
    integer s;
    integer i;
    integer j;
    integer w;
    list amNum;
    list tNum;
    list bNum;

    w = GetWidth(n);

    amNum = llListReplaceList(BigNumZero(2 * w), llList2List(a, 0, w - 1),
        w, 2 * w - 1);

    amNum = BigNumMod(amNum, n);

    s = GetWidth(amNum);

    tNum = BigNumZero(s);

    w = GetWidth(b1) - 1;
    bNum = llListReplaceList(BigNumZero(s), llList2List(b1, 0, w), 0, w);

    for (i = 0; i < s; i++)
    {
        carry = 0;
        m = GetDigit(bNum, i);
        for (j = 0; j < s; j++)
        {
            temp = GetDigit(tNum, j) + GetDigit(amNum, j) * m + carry;
            tNum = SetDigit(tNum, j, temp);
            carry = (temp>>DIGITBITS) & DIGITMASK;
        }

        temp = GetDigit(tNum, s) + carry;
        carry = (temp>>DIGITBITS) & DIGITMASK;
        tNum = SetDigit2(tNum, s, temp, carry);

        carry = 0;
        m = (GetDigit(tNum, 0) * ni0) & DIGITMASK;

        temp = GetDigit(tNum, 0) + m * GetDigit(n, 0) + carry;
        carry = (temp>>DIGITBITS) & DIGITMASK;
        for (j = 1; j < s; j++)
        {
            temp = GetDigit(tNum, j) + m * GetDigit(n, j) + carry;
            tNum = SetDigit(tNum, j - 1, temp);
            carry = (temp>>DIGITBITS) & DIGITMASK;
        }
        temp = GetDigit(tNum, s) + carry;
        tNum = SetDigit(tNum, s - 1, temp);
        carry = (temp>>DIGITBITS) & DIGITMASK;
        tNum = SetDigit(tNum, s, GetDigit(tNum, s + 1) + carry);
    }

    carry = 0;
    for (j = 0; j <= s; j++)
    {
        temp = GetDigit(tNum, j) - GetDigit(n, j) - carry;
        amNum = SetDigit(amNum, j, temp);
        carry = (temp>>DIGITBITS) & DIGITMASK;
        if (carry != 0)
        carry = 1;
    }

    if (carry == 0)
    return amNum;
    else
    return tNum;
}

list BigNumMod(list a, list p)
{
    return BigNumDivide(a, p, FALSE);
}

// Knuth, D., The Art of Computer Programming, VOLUME 2, Seminumerical Algorithms, 2nd Edition
// Algorithm D, Section 4.3.1 p272-273.

list BigNumDivide(list dividend1, list divisor1, integer qorr)
{
    integer i;
    integer temp;
    integer overflow;
    integer shiftSize = 0;
    integer divisorLen;
    integer dividendLen;
    integer counter;
    integer numDigitsLeft;
    integer msword;
    integer q;
    integer dsor0;
    integer dsor1;
    integer remainderLen;
    integer quotientLen;
    integer negative_remainder;
    integer w;
    list quotient;
    list remainder;
    list dividend;
    list divisor;

    if ((BigNumNumSignificantDigits(divisor1) == 1) && (GetDigit(divisor1,
        0) == 0))
    {
        // Divide by zero error.
        return dividend;
    }

    if (BigNumUCompare(divisor1, dividend1) > 0)
    {
        if(qorr)
        return BigNumFromInteger(0);
        else
        return dividend;
    }

    dividend = dividend1;
    divisor  = divisor1;

    divisorLen  = BigNumNumSignificantDigits(divisor);
    dividendLen = BigNumNumSignificantDigits(dividend);

    quotient  = BigNumZero(GetWidth(dividend));
    remainder = BigNumZero(GetWidth(divisor));

    //Normalize the divisor so that the most significant bit of most significant digit is set.
    msword = GetDigit(divisor, divisorLen - 1);
    while ((msword & DIGITMSBIT) == 0)
    {
        msword = msword << 1;
        shiftSize++;
    }

    // Ensure that divisor is at least 2 digits
    if (divisorLen == 1)
    shiftSize += DIGITBITS;

    if (shiftSize > 0)
    {
        divisor  = BigNumUShiftLeft(divisor, shiftSize, divisorLen);
        divisorLen = shiftLength;
        dividend = BigNumUShiftLeft(dividend, shiftSize, dividendLen);
        dividendLen = shiftLength;
    }

    remainderLen = divisorLen;

    numDigitsLeft = dividendLen - divisorLen;

    remainder = SetWidth(remainder, GetWidth(divisor1));

    remainder = llListReplaceList(remainder,
      llList2List(dividend, numDigitsLeft, numDigitsLeft +
        divisorLen - 1), 0, divisorLen - 1);
    remainderLen = divisorLen;

    quotient = SetWidth(quotient, GetWidth(dividend1));

    quotientLen = 1;

    dsor0 = GetDigit(divisor, divisorLen - 2);
    dsor1 = GetDigit(divisor, divisorLen - 1);
    while(TRUE)
    {
        while ((remainderLen < divisorLen) && numDigitsLeft > 0)
        {
            quotient = BigNumUShiftLeft(quotient, DIGITBITS, quotientLen);
            quotientLen = shiftLength;
            remainder = BigNumUShiftLeft(remainder, DIGITBITS, remainderLen);
            remainderLen = shiftLength;
            // Insert new least significant digit.
            remainder = SetDigit(remainder, 0, GetDigit(dividend,
                numDigitsLeft - 1));
            numDigitsLeft--;
        }

        // Ensure that the remainder < divisor.
        if (BigNumUCompare(divisor, remainder) <= 0)
        {
            remainder = BigNumSub(remainder, divisor);
            remainderLen = BigNumNumSignificantDigits(remainder);
            quotient = SetDigit(quotient, 0, GetDigit(quotient, 0)+1);
            jump continue;
        }

        if (numDigitsLeft == 0)
        jump done;

        quotient  = BigNumUShiftLeft(quotient, DIGITBITS, quotientLen);
        quotientLen = shiftLength;
        remainder = BigNumUShiftLeft(remainder, DIGITBITS, remainderLen);
        remainderLen = shiftLength;

        // Insert new least significant digit.
        remainder = SetDigit(remainder, 0, GetDigit(dividend,
            numDigitsLeft - 1));
        numDigitsLeft--;

        // Estimate the next term of the quotient
        q = BigNumEstimateQuotientDigit(GetDigit(remainder, remainderLen -
            1),
        GetDigit(remainder, remainderLen -
            2),
        GetDigit(remainder, remainderLen -
            3), dsor1, dsor0);
        overflow = 0;
        w = GetWidth(remainder)+1;
        for (i = 0; i <= w; i++)
        {
            temp = q * GetDigit(divisor, i) + overflow;
            overflow = ((temp & OVERFLOWMASK)>>DIGITBITS) & DIGITMASK;
            if (GetDigit(remainder, i) < (temp & DIGITMASK))
            ++overflow;
            remainder = SetDigit(remainder, i, (GetDigit(remainder, i) -
                (temp & DIGITMASK))& DIGITMASK);
        }

        if(overflow != 0)
        negative_remainder = TRUE;
        else
        negative_remainder = FALSE;
        counter = 2;
        while (negative_remainder && counter > 0)
        {
            --counter;
            --q;
            overflow = 0;
            for (i = 0; i <= GetWidth(remainder)+1; ++i)
            {
                temp = GetDigit(remainder, i) + GetDigit(divisor, i) +
                overflow;
                remainder = SetDigit(remainder, i, temp);
                overflow = ((temp & OVERFLOWMASK)>>DIGITBITS) & DIGITMASK;
            }
            if(overflow != 0)
            negative_remainder = FALSE;
        }
        remainderLen = BigNumNumSignificantDigits(remainder);
        quotient = SetDigit(quotient, 0, q);

        @continue;
    }

    @done;
    if (shiftSize > 0)
    {
        remainder = BigNumUShiftRight(remainder, shiftSize, remainderLen);
    }

    if(qorr)
    return quotient;
    else
    return remainder;
}

integer BigNumEstimateQuotientDigit(integer u2, integer u1, integer u0,
    integer v1, integer v0)
{
    integer  r0;
    integer u;
    integer r;
    integer p;
    integer q0v0;
    integer U1;
    integer q0;

    u = (u2 << (DIGITBITS)) | u1;

    if(u >= 0)
    {
        q0 = u / v1;
    }
    else
    {
        q0 = unsigned_divide(u, v1);
    }

    p = q0 * v1;

    if (q0 > DIGITMASK)
    {
        return DIGITMASK;
    }

    r = u - p;

    r0 = (r & DIGITMASK);
    U1 = (r0 << DIGITBITS) | u0;
    q0v0 = q0 * v0;

    while (greater_than(q0v0, U1))
    {
        q0--;
        r += v1;
        if ( r > DIGITMASK )
        jump done;
        r0 = (r & DIGITMASK);
        U1 = (r0 << DIGITBITS) | u0;
        q0v0 = q0 * v0;
    }

    @done;
    return (q0 & DIGITMASK);
}

// Special case of subtraction for BigNumDivide
//   a and b non-negative and a > b
list BigNumSub(list a, list b)
{
    integer temp;
    integer overflow;
    integer i;
    integer w;
    integer length;
    list t;

    t = BigNumFromInteger(0);

    length = GetWidth(a) - GetWidth(b);
    overflow = 0;
    if (length == 0)
    {
        w = GetWidth(a);
        for (i = 0; i <= w; i++)
        {
            temp = GetDigit(a,i) - GetDigit(b, i) - overflow;
            t = SetDigit(t, i, temp);
            if(temp & OVERFLOWMASK)
            overflow = 1;
            else
            overflow = 0;
        }
    }
    else if (length > 0)
    {
        w = GetWidth(b);
        for (i = 0; i <= w; i++)
        {
            temp = GetDigit(a,i) - GetDigit(b, i) - overflow;
            t = SetDigit(t, i, temp);
            if(temp & OVERFLOWMASK)
            overflow = 1;
            else
            overflow = 0;
        }
    }

    return t;
}

list BigNumUShiftRight(list operand, integer shiftSize, integer
    operandLength)
{
    integer i;
    integer v;
    integer length;
    integer w;
    integer wordShifts;
    integer carry;
    integer temp;
    list value;

    shiftLength = operandLength;

    if (shiftSize == 0)
    return operand;

    wordShifts = (shiftSize / DIGITBITS);

    length = (operandLength - wordShifts);
    shiftSize %= DIGITBITS;

    value = operand;

    // Do word shifts
    if (wordShifts > 0)
    value = llListReplaceList(value, llList2List(operand, wordShifts,
        wordShifts + length - 1), 0, length - 1);

    // Zero out the digits above the new most significant digit
    w = GetWidth(operand);
    value = llListReplaceList(value, llList2List(ZEROS, 0, w - 1), length,
        length + w - 1);

    // Do bit shifts
    if (shiftSize > 0)
    {
        carry = 0;
        for (i = (length - 1); i >= 0; i--)
        {
            v = GetDigit(value, i);
            temp = (carry | (v >> shiftSize)) & DIGITMASK;
            carry = (v << (DIGITBITS - shiftSize));
            value = SetDigit(value, i, temp);
        }
    }

    if(GetDigit(value, length - 1) > 0)
    shiftLength = length;
    else
    shiftLength = length - 1;

    return value;
}

list BigNumUShiftLeft(list operand, integer shiftSize, integer operandLength)
{
    integer wordShifts;
    integer i;
    integer v;
    integer length;
    integer carry;
    integer temp;
    list value;

    shiftLength = operandLength;

    if (shiftSize == 0 || (operandLength == 1 && GetDigit(operand, 0) == 0))
    return operand;

    wordShifts = (shiftSize / DIGITBITS);
    length = (operandLength + wordShifts);
    shiftSize %= DIGITBITS;

    value = operand;

    // Do word shifts
    if (wordShifts > 0)
    {
        value = llListReplaceList(value, llList2List(value, 0, length -
            wordShifts - 1), wordShifts, length - 1);
        value = llListReplaceList(value, llList2List(ZEROS, 0, wordShifts
            - 1), 0, wordShifts - 1);
    }

    // Do bit shifts
    if (shiftSize > 0)
    {
        carry = 0;
        for (i = wordShifts; i < length; i++)
        {
            v = GetDigit(value, i);
            temp = (carry | (v << shiftSize)) & DIGITMASK;
            carry = (v >> (DIGITBITS - shiftSize)) & DIGITMASK;
            value = SetDigit(value, i, temp);
        }

        value = SetDigit(value, i, carry);
        if(carry > 0)
        shiftLength = i + 1;
        else
        shiftLength  = i;
    }
    else
    shiftLength = length;

    return value;
}

integer BigNumUCompare(list a, list b)
{
    integer i;
    integer aLen;
    integer bLen;
    integer aD;
    integer bD;

    aLen = BigNumNumSignificantDigits(a);
    bLen = BigNumNumSignificantDigits(b);

    if (aLen != bLen)
    {
        if(aLen > bLen)
        return 1;
        else
        return -1;
    }

    for (i = aLen - 1; i >= 0; i--)
    {
        aD = GetDigit(a, i);
        bD = GetDigit(b, i);
        if (aD == bD)
        jump continue;
        else
        {
            if(aD > bD)
            return 1;
            else
            return -1;
        }
        @continue;
    }

    return 0;
}

integer BigNumNumSignificantDigits(list a)
{
    integer i;

    for (i = GetWidth(a) - 1; i > 0; i--)
    {
        if (GetDigit(a, i) > 0)
        {
            return(i + 1);
        }
    }

    return 1;
}

integer BigNumBitIsSet(list a, integer bitIndex)
{
    integer temp;
    integer value;

    if (bitIndex >= (DIGITBITS * (1 + GetWidth(a))) )
    return FALSE;

    temp = (bitIndex >> DIGITLOGBITS);
    value = GetDigit(a,temp);
    temp = (bitIndex & DIGITLOGMASK);

    if ((value & (1 << temp)) != 0)
    return TRUE;
    else
    return FALSE;
}

list BigNumFromList(list value, integer length)
{
    integer i;
    integer j;
    integer v;
    list bignum;

    bignum = BigNumZero(DIGITS/2);

    for(i = length - 1, j = 0; i >= 0; i--, j++)
    {
        v = GetDigit(value, i);
        bignum = SetDigit2(bignum, 2 * j, v, ((v &
            OVERFLOWMASK)>>DIGITBITS));
    }

    return bignum;
}

list BigNumFromInteger(integer value)
{
    return SetDigit2(BigNumZero(DIGITS/2), 0, value, ((value &
        OVERFLOWMASK)>>DIGITBITS));
}

list BigNumZero(integer width)
{
    return SetWidth(ZEROS, width);
}

integer unsigned_divide(integer dividend, integer divisor)
{
    integer t;
    integer num_bits;
    integer q;
    integer bit;
    integer d;
    integer i;
    integer remainder;
    integer quotient;

    remainder = 0;
    quotient = 0;

    if (divisor == 0)
    return quotient;

    if (divisor == dividend)
    {
        quotient = 1;
        return quotient;
    }

    num_bits = 32;

    while (remainder < divisor)
    {
        bit = ((dividend & 0x80000000) >> 31) & 0x00000001;
        remainder = (remainder << 1) | bit;
        d = dividend;
        dividend = dividend << 1;
        num_bits--;
    }

    dividend = d;
    remainder = remainder >> 1;
    num_bits++;

    for (i = 0; i < num_bits; i++)
    {
        bit = ((dividend & 0x80000000) >> 31);
        remainder = (remainder << 1) | bit;
        t = remainder - divisor;
        q = !((t & 0x80000000) >> 31);
        dividend = dividend << 1;
        quotient = (quotient << 1) | q;
        if (q)
        remainder = t;
    }

    return quotient;
}

integer greater_than(integer a, integer b)
{
    integer sign = 0x80000000;

    if((a & sign) != (b & sign))
    {
        if(a & sign)
        return 1;
        else
        return 0;
    }

    a = a & ~sign;
    b = b & ~sign;

    return (a > b);
}

// Public:  1000 =>  8762
// Private: 1000 => 40366
//integer p=167;
//integer q=347;
integer modulus    = 57949;
integer publickey  = 40097;
integer privatekey = 25533;

// Public:  1000 => 15308
// Private: 1000 =>  7443
//integer p=5483;
//integer q=2819;
//integer modulus    = 15456577;
//integer publickey  =  4780727;
//integer privatekey = 12951387;

default
{
    state_entry()
    {
        integer i;
        list m;
        list c;
        list mx;

        if(llGetListLength(ZEROS) == 0)
        {
            for(i = 0; i <= DIGITS; i++)
            ZEROS = ZEROS + [0];
        }

        m = BigNumFromInteger(1000);

        c = encrypt(m, BigNumFromInteger(publickey),
            BigNumFromInteger(modulus));
        llSay(0, "The encryption of "+llList2String(m,0)+" is
            "+llList2String(c,0));
        mx = decrypt(c, BigNumFromInteger(privatekey),
            BigNumFromInteger(modulus));
        llSay(0, "The decryption of "+llList2String(c,0)+" is
            "+llList2String(mx,0));
    }
}
