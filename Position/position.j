/**
*   Helper library to modify location coordinates
*   Implemented functions:
*
*   function PolarProjectX takes real x, real dist, real angle returns real
*   function PolarProjectY takes real y, real dist, real angle returns real
*   function PolarProjectUnit takes unit u, real dist, real angle, boolean blocking returns boolean
*   function DistanceBetweenCoords takes real xA, real yA, real xB, real yB returns real
*   function AngleBetweenCoords takes real xA, real yA, real xB, real yB returns real
*/
library Location

    globals
        //Counts destructibles nearby for blocking
        private integer count = 0
    endglobals
    
    /**
    *   Polar projects the selected X by the
    *   specified angle/dist
    */
    function PolarProjectX takes real x, real dist, real angle returns real
        return x + dist * Cos(angle * bj_DEGTORAD)
    endfunction
    
    /**
    *   Polar projects the selected Y by the
    *   specified angle/dist
    */
    function PolarProjectY takes real y, real dist, real angle returns real
        return y + dist * Sin(angle * bj_DEGTORAD)
    endfunction
    
    /**
    *   Helper function to increment destructible count
    */
    private function addOne takes nothing returns nothing
        set count = count + 1
    endfunction
    
    /**
    *   Helper function to see whether the unit is
    *   blocked by any destructibles. Returns true
    *   if blocked, false if not.
    */
    private function block takes unit u, real rad returns boolean
        local location loc = Location(GetUnitX(u),GetUnitY(u))
        set count = 0
        call EnumDestructablesInCircleBJ(rad,loc,function addOne)
        call RemoveLocation(loc)
        set loc = null
        if(count > 0)then
            return true
        endif
        return false
    endfunction
    
    /**
    *   Moves the unit using a polar projection
    *   u is the unit to be projected. Dist is the
    *   distance to move character by. Angle is angle
    *   to project by. 
    */
    function PolarProjectUnit takes unit u, real dist, real angle, boolean blocking returns boolean
        local real x = PolarProjectX(GetUnitX(u),dist,angle)
        local real y = PolarProjectY(GetUnitY(u),dist,angle)
        local boolean moved = false
        if(blocking==false or block(u,dist)==false)then
            call SetUnitPosition(u,x,y)
            set moved = true
        else
        endif
        return moved
    endfunction
    
    /**
    *   Calculates the distance between points
    *   xA and yA are x/y of first point.
    *   xB and yB are x/y of second point
    */
    function DistanceBetweenCoords takes real xA, real yA, real xB, real yB returns real
        local real dx =xB - xA
        local real dy = yB - yA
        return SquareRoot(dx * dx + dy * dy)
    endfunction
    
    /**
    *   Calculates angle between points
    *   xA and yA are x/y of first point.
    *   xB and yB are x/y of second point
    *   Returns angle in degrees
    */
    function AngleBetweenCoords takes real xA, real yA, real xB, real yB returns real
        return bj_RADTODEG * Atan2(yB - yA, xB - xA)
    endfunction
    
endlibrary
