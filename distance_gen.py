# python because decimal library and easier IO

from decimal import getcontext, Decimal as D

PRECISION = 8
RANGE = 50
STEP = 0.5
INCLUSIVE = True



inc = 'inclusive'
if not INCLUSIVE :
    inc = 'exclusive'

getcontext().prec = PRECISION
D_STEP = D (STEP)
ceil = int (RANGE/STEP)
if INCLUSIVE :
    ceil += 1

with open ("distance-lookup.lua", 'w') as file :
    file.write ("-- for positive dx, dy: x=0..n, y=x..n\r\n")
    file.write ("-- intervals of {}, n={}, {}\r\n".format (STEP, RANGE, inc))
    file.write ("-- precision of {} decimal places\r\n".format (PRECISION))
    file.write ("distances = {}\r\n")
    for _x in range (ceil) :
        x = D (_x) * D_STEP
        file.write ("distances[{}] = {}\r\n".format (float (x), '{}'))
        for _y in range (_x+1) : # because range is ceiling-exclusive
            y = D (_y) * D_STEP
            r = (x**2 + y**2).sqrt () # cartesian distance
            file.write ("distances[{}][{}] = {}\r\n".format(float(x), 
                                                            float(y), 
                                                            float(r)))
    file.write ("return distances\r\n\r\n")

