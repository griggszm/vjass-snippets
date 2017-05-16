library Context
    globals
        private constant boolean DEBUG_MODE = false
        
        Battle battleContext
        unit aiContext
        unit srcContext
        unit targetContext
    endglobals
    
    function DebugMsg takes string s returns nothing
        if(DEBUG_MODE)then
            call BJDebugMsg(s)
        endif
    endfunction
    
endlibrary
