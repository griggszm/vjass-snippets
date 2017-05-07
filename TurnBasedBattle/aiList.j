//  -- Getting an AI --
//  getAIOfUnitType(integer id)

library AIList initializer onInit
    globals
        public AI whichAI
        private AI array ais
        private integer count = 0
    endglobals
    
    private function createAI takes integer id, string behavior, string inspect returns nothing
        set ais[count] = AI.create(id,behavior,inspect)
        set count = count + 1
    endfunction
    
    private function onInit takes nothing returns nothing
    endfunction
    
    public function getAIOfUnitType takes integer id returns Action
        local integer i = 0
        local AI returnAI = 0
        local AI temp = 0
        loop
            exitwhen i>count
            set temp = ais[i]
            if(temp!=0)then
                if(temp.getId()==id)then
                    set returnAI = ais[i]    
                endif
            endif
            set i = i + 1
        endloop
        return returnAI
    endfunction
endlibrary
