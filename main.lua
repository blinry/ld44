require "lib.slam"
vector = require "lib.hump.vector"
tlfres = require "lib.tlfres"

class = require "lib.middleclass"
Entity = require "entity"
DynamicEntity = require "dynamicentity"
BreadCrumb = require "breadcrumb"
Wall = require "wall"
Trap = require "trap"
Door = require "door"
Key = require "key"
Player = require "player"
Follower = require "follower"
require "helpers"
Hole = require "hole"
Bush = require "bush"
CANVAS_WIDTH = 1920
CANVAS_HEIGHT = 1080

currentLevel = 1

function love.load()
    math.randomseed(os.time())

    -- set up default drawing options
    love.graphics.setBackgroundColor(0, 0, 0)

    -- load assets
    images = {}
    for i,filename in pairs(love.filesystem.getDirectoryItems("images")) do
        if filename ~= ".gitkeep" then
            images[filename:sub(1,-5)] = love.graphics.newImage("images/"..filename)
        end
    end

    sounds = {}
    for i,filename in pairs(love.filesystem.getDirectoryItems("sounds")) do
        if filename ~= ".gitkeep" then
            sounds[filename:sub(1,-5)] = love.audio.newSource("sounds/"..filename, "static")
        end
    end

    music = {}
    for i,filename in pairs(love.filesystem.getDirectoryItems("music")) do
        if filename ~= ".gitkeep" then
            music[filename:sub(1,-5)] = love.audio.newSource("music/"..filename, "stream")
            music[filename:sub(1,-5)]:setLooping(true)
        end
    end

    fonts = {}
    for i,filename in pairs(love.filesystem.getDirectoryItems("fonts")) do
        if filename ~= ".gitkeep" then
            fonts[filename:sub(1,-5)] = {}
            for fontsize=50,100 do
                fonts[filename:sub(1,-5)][fontsize] = love.graphics.newFont("fonts/"..filename, fontsize)
            end
        end
    end

    initGame()
end

function initGame()
    resetGame()
    initLevel(1)
end

function resetGame()
    currentBreadCrumb = nil

    breadCrumbs = {}
    walls = {}
    pickups = {}
    holes = {}
    bushes = {}

    love.physics.setMeter(100)
    world = love.physics.newWorld(0,0,true)
    -- TODO: this is the callback that gets called for handling collisions
    world:setCallbacks(beginContact, endContact)

    playerLifePoints = 50
    playerAcceleration = 100000
    playerSpeed = CANVAS_WIDTH/5
    -- player = Entity:new(playerPos, playerSpeed, playerLifePoints)

    followerAcceleration = playerAcceleration / 2
    followerLifePoints = playerLifePoints

    math.randomseed(os.time())

    followers = {}
    --for i = 1,3 do
    --    followerPos = vector(math.random(0, CANVAS_WIDTH), math.random(0, CANVAS_HEIGHT))
    --    variation = math.random(0, followerAcceleration/3)
    --    table.insert(followers, Follower:new(followerPos, followerAcceleration+variation, followerLifePoints/2))
    --end

    -- buildWalls()
    -- key = Key:new(vector(CANVAS_WIDTH-100,100))
    -- table.insert(pickups, key)
    -- buildTraps()
    -- buildHoles()
    -- buildBushes()

    -- -- this line needs to be customized depending on bush
    -- for _, bush in pairs(bushes) do 
    --     placeFollowersInBush(bush)
    -- end
end

function initLevel(n)
    resetGame()

    gamePaused = true
    currentLevel = n

    local levelInitializers = {
        initLevel1,
        initLevel2,
    }

    if levelInitializers[n] then
        levelInitializers[n]()
    end
end

function initLevel1()
    playerPos = vector(CANVAS_WIDTH/10, CANVAS_HEIGHT*8/10)
    player = Player:new(playerPos, playerSpeed, playerLifePoints)

    buildOuterWalls()

    buildWall(CANVAS_WIDTH/5, CANVAS_HEIGHT/2, 40, CANVAS_HEIGHT/2)
    buildWall(CANVAS_WIDTH*4/5+50, 0, 40, CANVAS_HEIGHT/2)
    buildWall(CANVAS_WIDTH*3/5, CANVAS_HEIGHT/2, CANVAS_WIDTH*1/5+40+50, 40)

    buildDoor(CANVAS_WIDTH*3/5, CANVAS_HEIGHT/2+40, 40, CANVAS_HEIGHT/2)

    buildHole(CANVAS_WIDTH*1.8/5, CANVAS_HEIGHT*1/7, CANVAS_WIDTH/8, CANVAS_HEIGHT/5)

    trap_pos = vector(CANVAS_WIDTH*9.2/10, CANVAS_HEIGHT*1/10)
    trap = Trap:new(trap_pos, CANVAS_WIDTH/15)

    buildKey(CANVAS_WIDTH*3/5, CANVAS_HEIGHT*1/4)

    buildFollower(CANVAS_WIDTH/4, CANVAS_HEIGHT*5/6, playerAcceleration/2)
end

function initLevel2()
    trap_pos = vector(CANVAS_WIDTH*9.2/10, CANVAS_HEIGHT*1/10)
    trap = Trap:new(trap_pos, CANVAS_WIDTH/15)
end

function buildOuterWalls()
    buildWall(0, 0, CANVAS_WIDTH, 10)
    buildWall(0, 0, 10, CANVAS_HEIGHT)
    buildWall(0, CANVAS_HEIGHT-10, CANVAS_WIDTH, 10)
    buildWall(CANVAS_WIDTH-10, 0, 10, CANVAS_HEIGHT)
end

function endContact(a, b, collision)
    local aObject = a:getUserData()
    local bObject = b:getUserData()

    local aClass = a:getUserData().class.name
    local bClass = b:getUserData().class.name

    if bClass == "Follower" and aClass == "Player" then
        aObject.beingDamaged = aObject.beingDamaged - 1
    end
    if aClass == "Follower" and bClass == "Player" then
        bObject.beingDamaged = bObject.beingDamaged - 1
    end

end

function beginContact(a, b, collision)
    local aObject = a:getUserData()
    local bObject = b:getUserData()

    local aClass = a:getUserData().class.name
    local bClass = b:getUserData().class.name

    if aClass == "Door" and bClass == "Follower" and bObject.currentlyHeld
        then aObject.locked = false
    end
    if bClass == "Door" and aClass == "Follower" and aObject.currentlyHeld
        then bObject.locked = false
    end


    if bClass == "Follower" and aClass == "Player" then
        aObject.beingDamaged = aObject.beingDamaged + 1
    end
    if aClass == "Follower" and bClass == "Player" then
        bObject.beingDamaged = bObject.beingDamaged + 1
    end

    -- if a:getUserData() and b:getUserData() then
    --     if a:getUserData().typ == "bubble" and b:getUserData().typ == "red" then
    --         pickUp(b:getUserData().object, a:getUserData().object)
    --     elseif a:getUserData().typ == "red" and b:getUserData().typ == "bubble" then
    --         pickUp(a:getUserData().object, b:getUserData().object)
    --     end
    -- end
end

function buildWalls()

    buildWall(CANVAS_WIDTH/6, CANVAS_HEIGHT/2-5, CANVAS_WIDTH/6*4, 40)
    buildDoor(CANVAS_WIDTH/6, CANVAS_HEIGHT/2+5, 40, CANVAS_HEIGHT/2-5)
end

function buildWall(x, y, w, h)
    wall_pos = vector(x, y)
    wall = Wall:new(wall_pos, w, h)
    table.insert(walls, wall)
end

function buildKey(x, y)
    key = Key:new(vector(x, y))
    table.insert(pickups, key)
end

function buildFollower(x, y, acceleration)
   followerPos = vector(x, y)
   table.insert(followers, Follower:new(followerPos, acceleration, followerLifePoints/2))
end

function buildTraps()
    trap_pos = vector(CANVAS_WIDTH*9/10, CANVAS_HEIGHT*9/10)
    trap = Trap:new(trap_pos, CANVAS_WIDTH/10)
end

function buildHoles()
    buildHole(CANVAS_WIDTH*1/10, CANVAS_HEIGHT*1/10, CANVAS_WIDTH/10, CANVAS_HEIGHT/10)
end

function buildBushes()
    buildBush()
end

function buildBush()
    bush_pos = vector(CANVAS_WIDTH*3/10, CANVAS_HEIGHT*9/10)
    height = CANVAS_HEIGHT/10
    width = CANVAS_WIDTH/5
    bush = Bush:new(bush_pos, width, height)
    table.insert(bushes, bush)
end

function placeFollowersInBush(bush)
   
    
    for i = 1,5 do
        followerAcceleration = playerAcceleration / 2
        variation = math.random(0, followerAcceleration/3)
        followerLifePoints = 50
        followerSpeed = 50
        local bush_x = bush.pos.x +  bush.width/2 + math.random(0, bush.width/5)
        local bush_y = bush.pos.y + bush.height/2 + math.random(0, bush.height/5)
        followerPos = vector(bush_x, bush_y)
        follower = Follower:new(followerPos, followerAcceleration+variation, followerLifePoints/2)
        follower.mobility = false
        table.insert(followers, follower)
        table.insert(bush.hiding_entities, follower)
    end


end


function calculateOverlapBetweenHoleAndEntity(hole, movingObject)
    -- model entity and hole as square
    -- right now the assumption is that the moving thing is a circle

    holeTopLeftX = hole.pos.x
    holeTopLeftY = hole.pos.y
    holeBotRightX = holeTopLeftX + hole.width
    holeBotRightY = holeTopLeftY + hole.height
    movingObjectMidX, movingObjectMidY = movingObject:position().x, movingObject:position().y
    movingObjectTopLeftX = movingObjectMidX - movingObject:radius()
    movingObjectTopLeftY = movingObjectMidY - movingObject:radius()
    movingObjectBottomRightX = movingObjectMidX + movingObject:radius()
    movingObjectBottomRightY = movingObjectMidY + movingObject:radius()


    xOverlap = math.max(0, math.min(holeBotRightX, movingObjectBottomRightX) - math.max(holeTopLeftX, movingObjectTopLeftX));
    yOverlap = math.max(0, math.min(holeBotRightY, movingObjectBottomRightY) - math.max(holeTopLeftY, movingObjectTopLeftY));
    overlapArea = xOverlap * yOverlap
    return overlapArea
    -- return (area1 + area2 - areaI);
end


function buildHole(x, y, w, h)
    hole_pos = vector(x, y)
    hole = Hole:new(hole_pos, w, h)
    table.insert(holes, hole)
end

function buildDoor(x, y, w, h)
    wall_pos = vector(x, y)
    wall = Door:new(wall_pos, w, h)
    table.insert(walls, wall)
end

function love.update(dt)
    if gamePaused then
        return
    end

    world:update(dt)
    movePlayer(dt)
    local lifeIncrease = 50*dt

    for _, follower in pairs(followers) do
        target = findTarget(follower)
        if follower.mobility == false then
            --- If the pig has been immobilized, then don't move them
            follower.body:setLinearVelocity(0,0)
        else
            if target then
                follow(follower, target, dt)
            end

            -- dampen follower
            local x, y = follower.body:getLinearVelocity()
            follower.body:applyForce(-200*x, -200*y)
        end

    end

    for _, body in pairs(world:getBodies()) do
        local object = body:getFixtures()[1]:getUserData()
        object:update()
    end
    player:update()
    if player.beingDamaged > 0 then
        player.lifePoints = player.lifePoints - lifeIncrease * 1.75
    end

    -- Deprecatation pending!
    collide(dt)

    if currentBreadCrumb then
        currentBreadCrumb.pos.x, currentBreadCrumb.pos.y = player.body:getPosition()
        currentBreadCrumb.pos.y = currentBreadCrumb.pos.y - player:radius()
        currentBreadCrumb.lifePoints = currentBreadCrumb.lifePoints + lifeIncrease/2
        player.lifePoints = player.lifePoints - lifeIncrease/2
    else
        if player.lifePoints < playerLifePoints then
            player.lifePoints = player.lifePoints + lifeIncrease/20
        end
    end

    processHoleCollisions()
    -- technically a misnomer - needs to be fully covered in bush
    triggerHidingPigsInBushes()
end

function triggerHidingPigsInBushes()

    for _, bush in pairs(bushes) do 
        local dx = player:position().x - bush.pos.x
        local dy = player:position().y - bush.pos.y
        dist = math.sqrt ( dx * dx + dy * dy )
        if dist < bush.detectionRadius then
            -- careful with this line - implicit casting
            for _, entity in pairs(bush.hiding_entities) do 
                entity.mobility = true
            end

        end

    end

end



function processHoleCollisions()
    follower_delete_list = nil

    for idx, follower in pairs(followers) do
        for _, hole in pairs(holes) do
            local pixelOverlap = calculateOverlapBetweenHoleAndEntity(hole, follower)

            local area = 4*follower:radius()^2

            if pixelOverlap > area/2 then
                follower_delete_list = {next = follower_delete_list, value = idx}
                break
            end
        end
    end

    local l = follower_delete_list
    while l do
        follower = followers[l.value]
        follower.body:destroy()
        table.remove(followers, l.value)
        l = l.next
    end

    for _, hole in pairs(holes) do
        local pixelOverlap = calculateOverlapBetweenHoleAndEntity(hole, player)

        local area = 4*player:radius()^2

        if pixelOverlap > area/2 then
            die()
        end
    end

end

function die()
    currentBreadCrumb = nil
    initLevel(currentLevel)
end

function overlapFollowers(pos, r)
    for _, follower in pairs(followers) do
        local diff = pos - vector(follower.body:getPosition())
        if diff:len() < r+follower:radius() then
            return follower
        end
    end
end

function collide(dt)
    for i,crumb in pairs(breadCrumbs) do
        -- for _, follower in pairs(followers) do
            -- diff = crumb.pos - vector(follower.body:getPosition())
            -- if diff:len() < crumb:radius() then
                -- suckBreadCrumb(crumb, i, dt, follower)
                -- table.remove(breadCrumbs, i)
            -- end
        collided = overlapFollowers(crumb.pos, crumb:radius())
        if collided then
            suckBreadCrumb(crumb, i, dt, collided)
        end
    end

    -- This is the code to trigger traps and followers
    for _, follower in pairs(followers) do
        local followerX, followerY = follower.body:getPosition()
        local dx = trap.pos.x - followerX
        local dy = trap.pos.y - followerY
        dist = math.sqrt ( dx * dx + dy * dy )
        follower_radius = 0 -- placeholder
        if trap.radius > ( dist  + follower_radius) then
            follower.mobility = false
            trap.gotFollower = true
        end
    end

    for i, pickup in pairs(pickups) do
        collided = overlapFollowers(pickup.pos, pickup:radius())
        if collided then
            table.remove(pickups, i)
            collided.currentlyHeld = pickup
        end
    end
end

function suckBreadCrumb(crumb, index, dt, follower)
    if crumb.lifePoints <= 0 then
        -- TODO: find sucking sounds
        -- sounds.meow:setPitch(0.5+math.random())
        -- sounds.meow:play();
        table.remove(breadCrumbs, index)
    else
        local suckedLifePoints = 10 * dt
        crumb.lifePoints = crumb.lifePoints - suckedLifePoints
        follower.lifePoints = follower.lifePoints + suckedLifePoints
    end
end

function findTarget(follower)
    local currentHighestAttractiveness = 0
    local mostAttractiveTarget = nil
    local targets = table.shallow_copy(breadCrumbs)
    table.insert(targets, player)
    for i,target in pairs(targets) do
        diff = target:position() - follower:position()
        a = target:attractiveness()/diff:len()
        if a > currentHighestAttractiveness then
            currentHighestAttractiveness = a
            mostAttractiveTarget = target
        end
    end
    return mostAttractiveTarget
end

function movePlayer(dt)
    if love.keyboard.isDown("left") then
        player.body:applyForce(-playerAcceleration, 0, 0 ,0)
    end
    if love.keyboard.isDown("right") then
        player.body:applyForce(playerAcceleration, 0, 0 ,0)
    end
    if love.keyboard.isDown("up") then
        player.body:applyForce(0, -playerAcceleration, 0 ,0)
    end
    if love.keyboard.isDown("down") then
        player.body:applyForce(0, playerAcceleration, 0 ,0)
    end

    local x,y = player.body:getLinearVelocity()
    player.body:applyForce(-200*x, -200*y)
end

function love.mouse.getPosition()
    return tlfres.getMousePosition(CANVAS_WIDTH, CANVAS_HEIGHT)
end

function love.keypressed(key)
    gamePaused = false

    if key == "escape" then
        love.window.setFullscreen(false)
        love.event.quit()
    elseif key == "f" then
        isFullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not isFullscreen)
    elseif key == "r" then
        die()
    elseif string.find(key, "%d") then
        initLevel(tonumber(key))
    elseif key == "lctrl" then
        currentBreadCrumb = BreadCrumb:new(vector(player.body:getPosition()), 0)
        table.insert(breadCrumbs, currentBreadCrumb)
    end
end

function love.keyreleased(key)
    if key == "lctrl" then
        if currentBreadCrumb then
            currentBreadCrumb.pos = currentBreadCrumb.pos:clone()
            currentBreadCrumb = nil
        end
    end
end

function love.mousepressed(x, y, button)
end

function follow(follower, target, dt)
    diff = target:position() - vector(follower.body:getPosition())
    nDiff = diff:normalized()
    forceApplied = nDiff * follower.acceleration
    follower.body:applyForce(forceApplied.x, forceApplied.y, 0, 0)
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    tlfres.beginRendering(CANVAS_WIDTH, CANVAS_HEIGHT)
    love.graphics.clear(0.8, 0.8, 0.7)

    -- draw wall
    for _, wall in pairs(walls) do
        love.graphics.setColor(wall.color.r, wall.color.g, wall.color.b, wall.color.a) -- set color of walls
        love.graphics.rectangle("fill", wall.pos.x, wall.pos.y, wall.width, wall.height)
    end

    -- draw holes
    for _, hole in pairs(holes) do
        -- change color of holes later with fabrics
        love.graphics.setColor(1, 1, 1, 1) -- set color of holes
        -- love.graphics.rectangle("fill", hole.pos.x, hole.pos.y, hole.width, hole.height)
        love.graphics.draw(images.hole, hole.pos.x, hole.pos.y, 0, hole.width/images.hole:getWidth(), hole.height/images.hole:getHeight())
    end


    if trap.gotFollower == true then
        -- change color to red
        love.graphics.setColor(0,255,0,255)
    else
        -- change color to green
        love.graphics.setColor(255, 0, 0, 255)
    end
    love.graphics.circle("fill", trap.pos.x, trap.pos.y, trap.radius)

    -- draw player
    love.graphics.setColor(1, 1, 1, 1) -- set color of player
    local playerScale = player:radius()/50
    local playerX, playerY = player.body:getPosition()
    love.graphics.draw(images.piggy, playerX, playerY, 0, playerScale*player.flip, playerScale, images.piggy:getWidth()/2, images.piggy:getHeight()/2)
    -- love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
    -- love.graphics.circle("fill", playerX, playerY, player.shape:getRadius())

    -- draw followers
    for _, follower in pairs(followers) do
        local followerScale = follower:radius()/50
        local followerX, followerY = follower.body:getPosition()
        love.graphics.setColor(follower.color.r, follower.color.g, follower.color.b, 1)
        if follower.currentlyHeld then
            love.graphics.setColor(0.5, 1, 0.5, 1)
        end
        love.graphics.draw(images.piggy, followerX, followerY, 0, followerScale*follower.flip, followerScale, images.piggy:getWidth()/2, images.piggy:getHeight()/2)
        -- love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        -- love.graphics.circle("fill", followerX, followerY, follower.shape:getRadius())
    end

    -- draw crumbdrops
    for _, breadCrumb in pairs(breadCrumbs) do
        drawCrumb(breadCrumb)
    end

    -- draw health bars
    love.graphics.setColor(0.3, 0.3, 0.7, 1)
    love.graphics.rectangle("fill", 0, 0, CANVAS_WIDTH*player.lifePoints/playerLifePoints, 30)

    -- draw bushes
    for _, bush in pairs(bushes) do
        drawBush(bush)
    end

    -- draw pickups
    love.graphics.setColor(1, 1, 1, 1)
    for _, pickup in pairs(pickups) do
        love.graphics.draw(images.key, pickup.pos.x, pickup.pos.y, 0, 1, 1, images.key:getWidth()/2, images.key:getHeight()/2)
    end

    tlfres.endRendering()
end

function drawCrumb(crumb)
    local crumbScale = crumb:radius()/100
    -- love.graphics.circle("fill", crumb.pos.x, crumb.pos.y, crumbScale)

    love.graphics.setColor(1, 1, 1, 0.8) -- set color of crumb drop
    love.graphics.draw(images.coin, crumb.pos.x, crumb.pos.y, 0, crumbScale, crumbScale, images.coin:getWidth()/2, images.coin:getHeight()/2)
end

function drawBush(bush)
    love.graphics.setColor(0, 166, 0, 200) -- set color of crumb drop
    love.graphics.rectangle("fill", bush.pos.x, bush.pos.y, bush.width, bush.height)
    width_circles = width/bush.widthRadius - 1
    height_circles = height/bush.heightRadius - 1
    for i = 1,width_circles,1
    do 
       love.graphics.circle("fill", bush.pos.x + i * bush.widthRadius, bush.pos.y + bush.widthRadius/5, bush.widthRadius)
       love.graphics.circle("fill", bush.pos.x + i * bush.widthRadius, bush.pos.y + bush.height + bush.widthRadius/5, bush.widthRadius)

    end
    for i = 1,height_circles,1
    do 
        love.graphics.circle("fill", bush.pos.x + bush.heightRadius/5, bush.pos.y + i* bush.heightRadius, bush.heightRadius)
        love.graphics.circle("fill", bush.pos.x + bush.width + bush.heightRadius/5, bush.pos.y + i* bush.heightRadius, bush.heightRadius)
   
    end





end
