
struct Patroller
 
    private rect array nodes[10]
    private integer index = 0
    private integer currentNode = 0
    private unit patroller
    private integer patrollerType

    public static method create takes rect startNode, integer patrollerType returns thistype
        local thistype new = thistype.allocate()
        set new.patrollerType = patrollerType
        call new.addNode(startNode)
        return new
    endmethod
 
    public method addNode takes rect node returns nothing
        if(index < 10)then
            set nodes[index] = node
            set index = index + 1
        endif
    endmethod
 
    private static method onReachNode takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local thistype data = GetTimerData(t)
        call ReleaseTimer(t)
        call data.processNextNodeMovement()
    endmethod
 
    private method processNextNodeMovement takes nothing returns nothing
        local real distance
        local real time
        local real x0 = GetRectCenterX(nodes[currentNode])
        local real y0 = GetRectCenterY(nodes[currentNode])
        local real x1
        local real y1
        // find next node
        set currentNode = currentNode + 1
        if(currentNode >= index)then
            set currentNode = 0
        endif
        // calculate distance between this and next node
        set x1 = GetRectCenterX(nodes[currentNode])
        set y1 = GetRectCenterY(nodes[currentNode])
        set distance = DistanceBetweenCoords(x0,y0,x1,y1)
        // calculate time to reach point
        set time = distance / GetUnitMoveSpeed(patroller)
        // issue the move order and start timer to
        // determine when it is reached
        call IssuePointOrder(patroller,"move",x1,y1)
        call TimerStart(NewTimerEx(this),time,false,function thistype.onReachNode)
    endmethod
 
    public method start takes nothing returns nothing
        // begin at starting node
        set patroller = CreateUnit(ENEMY_PLAYER,patrollerType,GetRectCenterX(nodes[0]),GetRectCenterY(nodes[0]),0)
        call processNextNodeMovement()
    endmethod
 
endstruct
