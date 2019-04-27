require "lib.slam"
vector = require "lib.hump.vector"
tlfres = require "lib.tlfres"

class = require "lib.middleclass"
Entity = require "entity"
DynamicEntity = require "DynamicEntity"
BreadCrumb = require "breadcrumb"
Wall = require "wall"
require "helpers"

CANVAS_WIDTH = 1920
CANVAS_HEIGHT = 1080

crumbRadius = 5
currentBreadCrumb = nil

breadCrumbs = {}
walls = {}


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
    love.physics.setMeter(100)
    world = love.physics.newWorld(0,0,true)
    -- TODO: this is the callback that gets called for handling collisions
    -- world:setCallback(handlingCollisions)

    playerLifePoints = 1000
    playerAcceleration = 50000
    playerPos = vector(CANVAS_WIDTH/2, CANVAS_HEIGHT/2)
    playerSpeed = CANVAS_WIDTH/5
    -- player = Entity:new(playerPos, playerSpeed, playerLifePoints)
    player = DynamicEntity:new(playerPos, playerSpeed, playerLifePoints)

    followerAcceleration = playerAcceleration / 2
    followerScaleFactor = 0.5
    followerPos = vector(CANVAS_WIDTH/4, CANVAS_HEIGHT/4)
    followerSpeed = CANVAS_WIDTH/(10)
    -- follower = Entity:new(followerPos, followerSpeed, followerScaleFactor)
    follower = DynamicEntity:new(followerPos, followerSpeed, followerScaleFactor)


    buildWalls()
end

function buildWalls()
    wall_pos = vector(CANVAS_WIDTH/2 + CANVAS_WIDTH/4, CANVAS_HEIGHT/2 + CANVAS_HEIGHT/4)
    wall = Wall:new(wall_pos, CANVAS_WIDTH/10, CANVAS_HEIGHT/10)
    table.insert(walls, wall)
end

function love.update(dt)
    world:update(dt)
    movePlayer(dt)
    target = mostAttractiveCrumb()
    if target then
        follow(follower, target, dt)
    end

    -- Deprecatation pending!
    collide(dt)

    if currentBreadCrumb then
        local lifeIncrease = 50*dt
        currentBreadCrumb.lifePoints = currentBreadCrumb.lifePoints + lifeIncrease
        player.lifePoints = player.lifePoints - lifeIncrease
    end
end

function collide(dt)
    for i,crumb in pairs(breadCrumbs) do
        diff = crumb.pos - follower.pos
        if diff:len() < crumbRadius then
            suckBreadCrumb(crumb, i, dt)
            -- table.remove(breadCrumbs, i)
        end
    end
end

function suckBreadCrumb(crumb, index, dt) 
    if crumb.lifePoints <= 0 then
        -- TODO: find sucking sounds
        -- sounds.meow:setPitch(0.5+math.random())
        -- sounds.meow:play();
        table.remove(breadCrumbs, index)
    else 
        crumb.lifePoints = crumb.lifePoints - (50 * dt)
    end
end

function nearestObject()
    diffToPlayer = (vector(player.body:getPosition()) - vector(follower.body:getPosition())):len()
    closeCrumb = nearestCrumb()

    if closeCrumb == nil then
        return player
    end

    diffToClosestCrumb = (vector(follower.body:getPosition()) - nearestCrumb().pos):len()
    if diffToPlayer < diffToClosestCrumb then
        return player
    end
    return nearestCrumb()
end

function nearestCrumb()
    currentSmallest = 100000
    closestCrumb = nil
    for i,crumb in pairs(breadCrumbs) do
        diff = crumb.pos - vector(follower.body:getPosition())
        if diff:len() < currentSmallest and crumb:radius() > diff:len() then
            currentSmallest = diff:len()
            closestCrumb = crumb
        end
    end
    return closestCrumb
end

function mostAttractiveCrumb()
    local currentHighestAttractiveness = 0
    local mostAttractiveCrumb = nil
    for i,crumb in pairs(breadCrumbs) do
        diff = crumb.pos - vector(follower.body:getPosition()) 
        attractiveness = crumb.lifePoints/diff:len()
        if attractiveness > currentHighestAttractiveness then
            currentHighestAttractiveness = attractiveness
            mostAttractiveCrumb = crumb
        end
    end
    return mostAttractiveCrumb
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
    player.body:applyForce(-70*x, -70*y)
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
    elseif key == "space" then
        currentBreadCrumb = BreadCrumb:new(vector(player.body:getPosition()))
        currentBreadCrumb.lifePoints = 0
    end
end

function love.keyreleased(key)
    if key == "space" then
        currentBreadCrumb.pos = currentBreadCrumb.pos:clone()
        table.insert(breadCrumbs, currentBreadCrumb)
        currentBreadCrumb = nil
    end
end

function love.mousepressed(x, y, button)
    sounds.meow:setPitch(0.5+math.random())
    sounds.meow:play()
end

function follow(follower, target, dt)
    diff = target.pos - vector(follower.body:getPosition())
    nDiff = diff:normalized()
    forceApplied = nDiff * followerAcceleration
    -- follower.pos = follower.pos + (follower.speed * nDiff * dt)
    follower.body:applyForce(forceApplied.x, forceApplied.y, 0, 0)
    local x, y = follower.body:getLinearVelocity()
    follower.body:applyForce(-70*x, -70*y)
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    tlfres.beginRendering(CANVAS_WIDTH, CANVAS_HEIGHT)

    -- draw wall
    for _, wall in pairs(walls) do
        love.graphics.setColor(0, 1, 0, 1) -- set color of walls
        love.graphics.rectangle("fill", wall.pos.x, wall.pos.y, wall.width, wall.height)
    end

    love.graphics.setColor(1, 1, 1, 1) -- set color of player
    local playerScale = math.sqrt(player.lifePoints/playerLifePoints)*2
    local playerX, playerY = player.body:getPosition()
    love.graphics.draw(images.child, playerX, playerY, 0, playerScale, playerScale, images.child:getWidth()/2, images.child:getHeight()/2)

    local followerScale = math.sqrt(follower.lifePoints)
    local followerX, followerY = follower.body:getPosition()
    love.graphics.draw(images.child, followerX, followerY, math.pi, followerScale, followerScale, images.child:getWidth()/2, images.child:getHeight()/2)

    -- draw crumbdrops
    for _, breadCrumb in pairs(breadCrumbs) do
        drawCrumb(breadCrumb)
    end
    if currentBreadCrumb then
        drawCrumb(currentBreadCrumb)
    end

    tlfres.endRendering()
end

function drawCrumb(crumb)
    love.graphics.setColor(crumb.color.r, crumb.color.g, crumb.color.b, 0.5) -- set color of crumb drop
    local crumbScale = crumb:radius()
    love.graphics.circle("fill", crumb.pos.x, crumb.pos.y, crumbScale)
end
