-- mordor.lua
-- Digs corridors underground to expose ores
-- Don't forget to follow it so its chunk doesn't get unloaded
-- By mal, mal@sec.gd
-- Licensed under the GPLv3


depth=32 -- 0=mine straight forward
skipdistance=0
horizontaloffset=0
maxdistance=32
advance="h" -- h, v for horiz, vert when maxdistance hit


-- stop configuring here

t=turtle
distance=0

function must(fn)
    while not fn() do end
end

function tunnelmine()
    print("TunnelMine")
    -- FORWARD --
    if t.detect() then -- solid
        while t.detect() do
            t.dig()
        end
    else -- liquid/air
        if t.place() then -- could bucket it
            if not t.refuel() then -- couldn't refuel (non-lava)
                t.place() -- put back
            else
                print("Refueled")
                print("Fuel level is "..t.getFuelLevel())
            end -- couldn't refuel
        end -- could bucket
    end -- solid / liquid/air
    -- DOWN -- -- no need to detect/dig loop
    if t.detectDown() then -- solid
        t.digDown()
    else -- liquid/air
        if t.placeDown() then -- could bucket it
            if not t.refuel() then -- couldn't refuel (non-lava)
                t.placeDown() -- put back
            else
                print("Refueled")
                print("Fuel level is "..t.getFuelLevel())
            end -- couldn't refuel
        end -- could bucket
    end -- solid / liquid/air
    -- UP --
    if t.detectUp() then -- solid
        while t.detectUp() do
            t.digUp()
        end
    else -- liquid/air
        if t.placeUp() then -- could bucket it
            if not t.refuel() then -- couldn't refuel (non-lava)
                t.placeUp() -- put back
            else
                print("Refueled")
                print("Fuel level is "..t.getFuelLevel())
            end -- couldn't refuel
        end -- could bucket
    end -- solid / liquid/air
    if distance % 16 == 15 then
        print("Poking holes")
        t.turnRight()
        t.dig()
        t.turnLeft()
        t.turnLeft()
        t.dig()
        t.turnRight()
    end
end -- function

function battlestations()
    print("Battlestations")
    t.select(1)
    print("Fuel level is "..turtle.getFuelLevel())
    if t.getFuelLevel() < depth * 2 then
        print("Insufficient fuel")
        exit()
    end
    print("Descending "..depth.." before mining")
    for i=depth,1,-1 do
        if t.detectDown() and not t.digDown() then
            print("Hit bedrock?")
            for j=i-depth,1,-1 do
                must(t.up)
            end
            exit()
        end
        must(t.down)
    end
    print("Moving "..horizontaloffset.." before mining")
    t.turnRight()
    for i=horizontaloffset,1,-1 do
        tunnelmine()
        must(t.forward)
    end
    t.turnLeft()
    print("Advancing "..skipdistance.." before mining")
    for i=skipdistance,1,-1 do
        must(t.forward)
        distance=distance+1
    end
    print("Arrived at battlestation")
end

battlestations()
while true do
    tunnelmine()

    -- Mining/fueling done --
    if t.getItemCount(16) > 0 or distance > maxdistance or t.getFuelLevel() <= (distance + depth + horizontaloffset + 2) then
        print("GoHome")
        print("Distance is "..distance)
        print("Fuel level is "..t.getFuelLevel())
        t.turnRight()
        t.turnRight()
        for i=distance,1,-1 do
            must(t.forward)
        end
        -- go back to the vertical tunnel
        t.turnRight()
        for i=horizontaloffset,1,-1 do
            while not t.forward() do
                t.dig()
            end
        end
        t.turnLeft()
        -- Go back up
        for i=depth,1,-1 do
            must(t.up)
        end
        -- Notify
        print("Arrived at home")
        print("Fuel level is "..t.getFuelLevel())
        -- Empty to chest
        t.turnLeft()
        while not t.detect() do
            print("No chest? Waiting...")
            sleep(10)
        end
        for i=16,2,-1 do
            t.select(i)
            while t.getItemCount(i) > 0 and not (t.drop() and t.getItemCount(i) == 0) do
                print("Chest full? Waiting...")
                sleep(10)
            end
        end
        t.select(1) -- back to the bucket
        t.turnLeft() -- pointing back starting direction
        print("Sleeping")
        sleep(10)
        skipdistance = 0
        if distance >= maxdistance then
            if advance == "h" and horizontaloffset < maxdistance then
                horizontaloffset = horizontaloffset + 3
            elseif advance == "v" then
                depth = depth + 4
            else
                print("Can't advance")
                exit()
            end
        else
            skipdistance = distance
        end
        distance = 0
        battlestations()
    else
        must(t.forward)
        distance=distance+1
    end
end

