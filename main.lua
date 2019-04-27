require "lib.slam"
vector = require "lib.hump.vector"
tlfres = require "lib.tlfres"

local class = require "lib.middleclass"
Entity = require "entity"

require "helpers"

CANVAS_WIDTH = 1920
CANVAS_HEIGHT = 1080

playerPos = vector(CANVAS_WIDTH/2, CANVAS_HEIGHT/2)
playerSpeed = CANVAS_WIDTH/10
player = Entity:new(playerPos, playerSpeed)

followerPos = vector(CANVAS_WIDTH/4, CANVAS_HEIGHT/4)
followerSpeed = CANVAS_WIDTH/20
follower = Entity:new(followerPos, followerSpeed)

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
end

function love.update(dt)
    movePlayer(dt)
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


crumbDrops = {}
-- circlex = 0
-- circley = 0
function dropCircle()
    circlex, circley = love.mouse.getPosition()
    table.insert(crumbDrops, {
        x = circlex,
        y = circley
    })
end

function love.keypressed(key)
    if key == "escape" then
        love.window.setFullscreen(false)
        love.event.quit()
    elseif key == "f" then
        isFullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not isFullscreen)
    elseif key == "space" then
        dropCircle()
    end
end

function love.keyreleased(key)
end

function love.mousepressed(x, y, button)
    sounds.meow:setPitch(0.5+math.random())
    sounds.meow:play()
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    tlfres.beginRendering(CANVAS_WIDTH, CANVAS_HEIGHT)

    -- Draw the game here!
    -- love.graphics.circle("fill", circlex, circley, 50, 100)
    for _, crumbDrop in pairs(crumbDrops) do
        love.graphics.setColor(255, 255, 255, 255) -- set color of crumb drop
        love.graphics.circle("fill", crumbDrop.x, crumbDrop.y, 50)
    end

    love.graphics.draw(images.child, player.pos.x, player.pos.y, 0, 1, 1, images.child:getWidth()/2, images.child:getHeight()/2)

    love.graphics.draw(images.child, follower.pos.x, follower.pos.y, math.pi, 1, 1, images.child:getWidth()/2, images.child:getHeight()/2)

    tlfres.endRendering()
end
