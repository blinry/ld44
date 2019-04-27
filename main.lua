require "lib.slam"
vector = require "lib.hump.vector"
tlfres = require "lib.tlfres"

class = require "lib.middleclass"
Entity = require "entity"
BreadCrumb = require "breadcrumb"
Wall = require "wall"
require "helpers"

CANVAS_WIDTH = 1920
CANVAS_HEIGHT = 1080

crumbRadius = 50

playerScaleFactor = 1
playerPos = vector(CANVAS_WIDTH/2, CANVAS_HEIGHT/2)
playerSpeed = CANVAS_WIDTH/10
player = Entity:new(playerPos, playerSpeed, playerScaleFactor)

followerScaleFactor = 0.5
followerPos = vector(CANVAS_WIDTH/4, CANVAS_HEIGHT/4)
followerSpeed = CANVAS_WIDTH/(20)
follower = Entity:new(followerPos, followerSpeed, followerScaleFactor)

breadCrumbs = {}
walls = {}
function love.load()
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

    wall_pos = vector(CANVAS_WIDTH/2 + CANVAS_WIDTH/4, CANVAS_HEIGHT/2 + CANVAS_HEIGHT/4)
    wall = Wall:new(wall_pos, CANVAS_WIDTH/10, CANVAS_HEIGHT/10)
    table.insert(walls, wall)
end

function love.update(dt)
    movePlayer(dt)
    target = nearestObject()
    follow(follower, target, dt)
    -- player:resize(0.999)
    collide()
end

function collide()
    for i,crumb in pairs(breadCrumbs) do
        diff = crumb.pos - follower.pos
        if diff:len() < crumbRadius then
            table.remove(breadCrumbs, i)
        end
    end
end

function nearestObject()
    diffToPlayer = (player.pos - follower.pos):len()
    closeCrumb = nearestCrumb()

    if closeCrumb == nil then
        return player
    end

    diffToClosestCrumb = (follower.pos - nearestCrumb().pos):len()
    if diffToPlayer < diffToClosestCrumb then
        return player
    end
    return nearestCrumb()
end

function nearestCrumb()
    currentSmallest = 100000
    closestCrumb = nil
    for i,crumb in pairs(breadCrumbs) do
        diff = crumb.pos - follower.pos
        if diff:len() < currentSmallest then
            currentSmallest = diff:len()
            closestCrumb = crumb
        end
        print(currentSmallest)
    end
    print("----")
    return closestCrumb
end

function movePlayer(dt)
    if love.keyboard.isDown("left") then
        player.pos.x = player.pos.x - dt*playerSpeed
    end
    if love.keyboard.isDown("right") then
        player.pos.x = player.pos.x + dt*playerSpeed
    end
    if love.keyboard.isDown("up") then
        player.pos.y = player.pos.y - dt*playerSpeed
    end
    if love.keyboard.isDown("down") then
        player.pos.y = player.pos.y + dt*playerSpeed
    end
end

function love.mouse.getPosition()
    return tlfres.getMousePosition(CANVAS_WIDTH, CANVAS_HEIGHT)
end

function createBreadCrumb()
    -- circlex, circley = love.mouse.getPosition()
    table.insert(breadCrumbs, BreadCrumb:new(player.pos:clone()))
end

function love.keypressed(key)
    if key == "escape" then
        love.window.setFullscreen(false)
        love.event.quit()
    elseif key == "f" then
        isFullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not isFullscreen)
    elseif key == "space" then
        createBreadCrumb()
    end
end

function love.keyreleased(key)
end

function love.mousepressed(x, y, button)
    sounds.meow:setPitch(0.5+math.random())
    sounds.meow:play()
end

function follow(follower, target, dt)
    diff = target.pos - follower.pos
    nDiff = diff:normalized()
    follower.pos = follower.pos + (follower.speed * nDiff * dt)
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    tlfres.beginRendering(CANVAS_WIDTH, CANVAS_HEIGHT)

    -- draw crumbdrops
    for _, breadCrumb in pairs(breadCrumbs) do
        love.graphics.setColor(255, 255, 255, 255) -- set color of crumb drop
        love.graphics.circle("fill", breadCrumb.pos.x, breadCrumb.pos.y, crumbRadius)
    end
    -- draw wall
    for _, wall in pairs(walls) do
        love.graphics.setColor(0, 255, 0, 255) -- set color of walls
        love.graphics.rectangle("fill", wall.pos.x, wall.pos.y, wall.width, wall.height)
    end
    
    love.graphics.setColor(255,2555,255,255)
    love.graphics.draw(images.child, player.pos.x, player.pos.y, 0, player.scaleFactor, player.scaleFactor, images.child:getWidth()/2, images.child:getHeight()/2)

    love.graphics.draw(images.child, follower.pos.x, follower.pos.y, math.pi, follower.scaleFactor, follower.scaleFactor, images.child:getWidth()/2, images.child:getHeight()/2)

    tlfres.endRendering()
end
