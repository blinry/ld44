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
require "helpers"
Hole = require "hole"
CANVAS_WIDTH = 1920
CANVAS_HEIGHT = 1080

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
    currentBreadCrumb = nil

    breadCrumbs = {}
    walls = {}
    pickups = {}
    holes = {}

    love.physics.setMeter(100)
    world = love.physics.newWorld(0,0,true)
    -- TODO: this is the callback that gets called for handling collisions
    world:setCallbacks(beginContact)

    playerLifePoints = 100
    playerAcceleration = 100000
    playerPos = vector(CANVAS_WIDTH/2, CANVAS_HEIGHT/2)
    playerSpeed = CANVAS_WIDTH/5
    -- player = Entity:new(playerPos, playerSpeed, playerLifePoints)
    player = DynamicEntity:new(playerPos, playerSpeed, playerLifePoints)

    followerAcceleration = playerAcceleration / 2
    followerLifePoints = 100


    followers = {}
    math.randomseed(os.time())
    for i = 1,3 do
        followerPos = vector(math.random(0, CANVAS_WIDTH), math.random(0, CANVAS_HEIGHT))
        variation = math.random(0, followerAcceleration/3)
        table.insert(followers, DynamicEntity:new(followerPos, followerAcceleration+variation, followerLifePoints))
    end

    buildWalls()
    key = Key:new(vector(CANVAS_WIDTH-100,100))
    table.insert(pickups, key)
    buildTraps()
    buildHoles()
end

function beginContact(a, b, collision)
    local aObject = a:getUserData()
    local bObject = b:getUserData()

    local aClass = a:getUserData().class.name
    local bClass = b:getUserData().class.name

    if aClass == "Door" and bClass == "DynamicEntity" and bObject.currentlyHeld
        then aObject.locked = false
    end
    if bClass == "Door" and aClass == "DynamicEntity" and aObject.currentlyHeld
        then aObject.locked = false
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
    buildWall(0, 0, CANVAS_WIDTH, 10)
    buildWall(0, 0, 10, CANVAS_HEIGHT)
    buildWall(0, CANVAS_HEIGHT-10, CANVAS_WIDTH, 10)
    buildWall(CANVAS_WIDTH-10, 0, 10, CANVAS_HEIGHT)

    buildWall(CANVAS_WIDTH/6, CANVAS_HEIGHT/2-5, CANVAS_WIDTH/6*4, 10)

    buildDoor(CANVAS_WIDTH/6, CANVAS_HEIGHT/2+5, 10, CANVAS_HEIGHT/2-5)
end

function buildWall(x, y, w, h)
    wall_pos = vector(x, y)
    wall = Wall:new(wall_pos, w, h)
    table.insert(walls, wall)
end

function buildTraps()
    trap_pos = vector(CANVAS_WIDTH*9/10, CANVAS_HEIGHT*9/10)
    trap = Trap:new(trap_pos, CANVAS_WIDTH/10)
end

function buildHoles()
    buildHole(CANVAS_WIDTH*1/10, CANVAS_HEIGHT*1/10, CANVAS_WIDTH/10, CANVAS_HEIGHT/10)
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
    world:update(dt)
    movePlayer(dt)

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
        local object = body:getFixtureList()[1]:getUserData()
        object:update()
    end
    player:update()

    -- Deprecatation pending!
    collide(dt)

    local lifeIncrease = 50*dt
    if currentBreadCrumb then
        currentBreadCrumb.pos.x, currentBreadCrumb.pos.y = player.body:getPosition()
        currentBreadCrumb.pos.y = currentBreadCrumb.pos.y - player:radius()*10
        currentBreadCrumb.lifePoints = currentBreadCrumb.lifePoints + lifeIncrease
        player.lifePoints = player.lifePoints - lifeIncrease
        if player.lifePoints <= 0 then
            die()
        end
    else
        if player.lifePoints < playerLifePoints then
            player.lifePoints = player.lifePoints + lifeIncrease/10
        end
    end

    processHoleCollisions()

end

function processHoleCollisions()
    follower_delete_list = nil
    for idx, follower in pairs(followers) do
        for _, hole in pairs(holes) do
            local pixelOverlap = calculateOverlapBetweenHoleAndEntity(hole, follower)
            if pixelOverlap > 0 then
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
        if pixelOverlap > 0 then
            die()
        end
    end

end





function die()
    currentBreadCrumb = nil
    initGame()
end

function overlapFollowers(pos, r)
    for _, follower in pairs(followers) do
        local diff = pos - vector(follower.body:getPosition())
        if diff:len() < r then
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
        local suckedLifePoints = 50 * dt
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
        attractiveness = target.lifePoints/diff:len()
        if attractiveness > currentHighestAttractiveness then
            currentHighestAttractiveness = attractiveness
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
    if key == "escape" then
        love.window.setFullscreen(false)
        love.event.quit()
    elseif key == "f" then
        isFullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not isFullscreen)
    elseif key == "lctrl" then
        currentBreadCrumb = BreadCrumb:new(vector(player.body:getPosition()))
        currentBreadCrumb.lifePoints = 0
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

    -- draw wall
    for _, wall in pairs(walls) do
        love.graphics.setColor(wall.color.r, wall.color.g, wall.color.b, wall.color.a) -- set color of walls
        love.graphics.rectangle("fill", wall.pos.x, wall.pos.y, wall.width, wall.height)
    end

    -- draw holes
    for _, hole in pairs(holes) do
        -- change color of holes later with fabrics
        love.graphics.setColor(0, 0, 255, 1) -- set color of holes
        love.graphics.rectangle("fill", hole.pos.x, hole.pos.y, hole.width, hole.height)
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
    local playerScale = math.sqrt(player.lifePoints/playerLifePoints)*2
    local playerX, playerY = player.body:getPosition()
    love.graphics.draw(images.piggy, playerX, playerY, 0, playerScale*player.flip, playerScale, images.piggy:getWidth()/2, images.piggy:getHeight()/2)

    for _, follower in pairs(followers) do
        local followerScale = math.sqrt(follower.lifePoints/playerLifePoints)
        local followerX, followerY = follower.body:getPosition()
        love.graphics.setColor(1, 0.5, 0.5, 1)
        if follower.currentlyHeld then
            love.graphics.setColor(0.5, 1, 0.5, 1)
        end
        love.graphics.draw(images.piggy, followerX, followerY, 0, followerScale*follower.flip, followerScale, images.piggy:getWidth()/2, images.piggy:getHeight()/2)
    end

    -- draw crumbdrops
    for _, breadCrumb in pairs(breadCrumbs) do
        drawCrumb(breadCrumb)
    end

    -- draw health bars
    love.graphics.setColor(0.3, 0.3, 0.7, 1)
    love.graphics.rectangle("fill", 0, 0, CANVAS_WIDTH*player.lifePoints/playerLifePoints, 30)

    -- draw pickups
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
