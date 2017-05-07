library InternalFunctions requires SetMax

    globals
        private constant real BATTLE_SPEED = 1.20
    endglobals
    
    function purge takes unit u returns nothing
        local integer i = GetUnitUserData(u)
        //remove effects here
    endfunction
    
    private function text takes string s, unit u, integer r, integer g, integer b, integer z returns nothing
        local texttag display = CreateTextTag()
        local real textHeight = 9 * 0.023 / 10
        local real vel = 64 * 0.071 / 128
        local real xvel = vel * Cos(90 * bj_DEGTORAD)
        local real yvel = vel * Sin(90 * bj_DEGTORAD)
        call SetTextTagText(display, s , textHeight)
        call SetTextTagPosUnit(display, u, z)
        call SetTextTagColor(display, r, g, b, 255)
        call SetTextTagVelocity(display, xvel, yvel)
        call SetTextTagPermanent( display, false )
        call SetTextTagLifespan( display, 1.50 )
        call SetTextTagFadepoint(display,1.50)
        set display = null
    endfunction
    
    function redText takes string s, unit u, integer z returns nothing
        call text(s,u,255,85,85,z)
    endfunction
    
    function blueText takes string s, unit u, integer z returns nothing
        call text(s,u,85,85,255,z)
    endfunction
    
    function greenText takes string s, unit u, integer z returns nothing
        call text(s,u,85,255,85,z)
    endfunction
    
    function plainText takes string s, unit u, integer z returns nothing
        call text(s,u,255,255,255,z)
    endfunction
    
    function darkText takes string s, unit u, integer z returns nothing
        call text(s,u,127,127,127,z)
    endfunction
    
    //Magnitudes:
    //1-2: weak
    //2-4: medium
    //4-6: heavy
    //6-8: extreme
    //8-10: ultimate
    function damageTarget takes DataStorage d, real magnitude, boolean magic returns real
        local real damage = 0
        local real random = 0
        local unit source = d.src
        local unit target = d.target
        
        if(IsUnitDeadBJ(target))then
            set source = null
            set target = null
            return 0
        endif
        
        set random = GetRandomReal(magnitude * -0.1,magnitude * 0.1)
        if(magic)then
            set damage = GetHeroInt(source,true) * (magnitude+random)
        else
            set damage = GetHeroAgi(source,true) * (magnitude+random)
        endif
        
        set random = GetRandomReal(damage * -0.1, damage * 0.1)
        set damage = damage + random
        
        set damage = damage - GetHeroStr(target,true)/(Pow(GetHeroStr(target,true)/4,(0.334)))
        
        set random = GetRandomReal(damage * -0.1, damage * 0.1)
        set damage = damage + random
        
        if((d.effective and d.reduced)==false)then
            if(d.effective)then
                set damage = damage * 1.5
            elseif(d.reduced)then
                set damage = damage / 1.5
            endif
        endif
        
        if(damage < 0 or d.zeroed)then
            set damage = 0
        endif
        
        set damage = damage * BATTLE_SPEED
        
        if(GetOwningPlayer(target)!=Player(11))then
            set damage = damage * 0.90
        endif
        if(GetOwningPlayer(source)!=Player(11))then
            set damage = damage * 1.10
        endif
        
        call UnitDamageTarget(source, target, damage, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_ENHANCED, WEAPON_TYPE_WHOKNOWS)
        
        if(d.effective)then
            call redText(I2S(R2I(damage)),target,90)
        elseif(d.reduced or d.zeroed)then
            call darkText(I2S(R2I(damage)),target,90)
        else
            call plainText(I2S(R2I(damage)),target,90)
        endif
        
        return damage
    endfunction
    
    function addLevels takes unit u, integer count returns nothing
        local integer i = 0
        if(count>0)then
            call UnitAddMaxLife(u,R2I(GetUnitState(u,UNIT_STATE_MAX_LIFE)*0.05*count))
            call UnitAddMaxMana(u,R2I(GetUnitState(u,UNIT_STATE_MAX_MANA)*0.05*count))
        endif
    endfunction
    
    function playerHasUnitType takes player p, integer i returns boolean
        local group g = CreateGroup()
        local unit fog = null
        call GroupEnumUnitsInRect(g,GetPlayableMapRect(),null)
        loop
            set fog = FirstOfGroup(g)
            exitwhen fog == null
            if(GetUnitTypeId(fog)==i and GetOwningPlayer(fog)==p)then
                call DestroyGroup(g)
                set g = null
                return true
            endif
            call GroupRemoveUnit(g,fog)
        endloop
        call DestroyGroup(g)
        set g = null
        return false
    endfunction

endlibrary
