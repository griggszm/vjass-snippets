This is a simple, efficient system to make maze patrollers with up to 10 waypoints.
Requires TimerUtils.

Some example consumer code:

```
scope FirelordPatrol initializer onInit
    
    private function makeTwoNodeFirelord takes rect r1, rect r2 returns nothing
        local Patroller p = Patroller.create(r1,FIRELORD)
        call p.addNode(r2)
        call p.start()
    endfunction

    private function onInit takes nothing returns nothing
        call makeTwoNodeFirelord(gg_rct_FNode1,gg_rct_FNode2)
        call makeTwoNodeFirelord(gg_rct_FNode3,gg_rct_FNode4)
        call makeTwoNodeFirelord(gg_rct_FNode5,gg_rct_FNode6)
        call makeTwoNodeFirelord(gg_rct_FNode7,gg_rct_FNode8)
    endfunction
endscope
```
