--[[
-- inicializační funkce
]]
function love.load()
	sprites = {}
	sprites.player = love.graphics.newImage('sprites/player.png') -- nyní můžeme použít obrázky v draw
	sprites.bullet = love.graphics.newImage('sprites/bullet.png')
	sprites.zombie = love.graphics.newImage('sprites/zombie.png')
	sprites.background = love.graphics.newImage('sprites/background.png')

	player = {}
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
	player.movementSpeed = 300

	zombies = {}
	bullets = {}

	gameState = 1 -- připraveno ke startu
	maxTime = 2
	timer = maxTime
	score = 0

	myFont = love.graphics.newFont(40)
end

--[[
-- END OF INICIALIZA|TiON
]]

function love.update(dt)
	if gameState == 2 then
		if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
			player.y = player.y + player.movementSpeed * dt
		end
		if love.keyboard.isDown("w") and player.y > 0 then
			player.y = player.y - player.movementSpeed * dt
		end
		if love.keyboard.isDown("a") and player.x > 0 then
			player.x = player.x - player.movementSpeed * dt
		end
		if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
			player.x = player.x + player.movementSpeed * dt
		end
	end

	for i, z in ipairs(zombies) do 
		z.x = z.x + math.cos(zombieAngle(z)) * z.movementSpeed * dt
		z.y = z.y + math.sin(zombieAngle(z)) * z.movementSpeed * dt
		
		if distanceBetween(z.x, z.y, player.x, player.y) < 25 then
			for i, z in ipairs(zombies) do
				zombies[i] = nil
				gameState = 1
				player.x = love.graphics.getWidth()/2
				player.y = love.graphics.getHeight()/2
			end
		end
	end

	for i, b in ipairs(bullets) do
		b.x = b.x + math.cos(b.direction) * b.movementSpeed * dt
		b.y = b.y + math.sin(b.direction) * b.movementSpeed * dt		
	end

	for i = #bullets, 1, -1 do
		local b = bullets[i]
		if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
			table.remove(bullets, i)
		end
	end

	for i, z in ipairs(zombies) do
		for j, b in ipairs(bullets) do
			if distanceBetween(z.x, z.y, b.x, b.y) < 25 then
				z.dead = true
				b.dead = true 
				score = score + 1
			end
		end
	end

	for i = #zombies, 1, -1 do
		local z = zombies[i]
		if z.dead == true then
			table.remove(zombies, i)
		end
	end

	for i = #bullets, 1, -1 do
		local b = bullets[i]
		if b.dead == true then
			table.remove(bullets, i)
		end
	end

	if gameState == 2 then
		timer = timer - dt
		if timer <= 0 then
			spawnZombie()
			maxTime = maxTime * 0.95
			timer = maxTime
		end
	end

end

--[[
-- END OF UPDATING
]]
function love.draw()
	love.graphics.draw(sprites.background, 0, 0)

	if gameState == 1 then
		love.graphics.setFont(myFont)
		love.graphics.printf("Click to start!", 0, 50, love.graphics.getWidth(), "center")
	end

	love.graphics.printf("Score: " .. score, 0, 0, love.graphics.getWidth(), "center")

	love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)
	
	for i, z in ipairs(zombies) do
		love.graphics.draw(sprites.zombie, z.x, z.y, zombieAngle(z), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)
	end

	for i, b in ipairs(bullets) do
		love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, 0.5, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
	end
end

function playerMouseAngle()
	return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function zombieAngle(enemy)
	return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

function spawnZombie()
	zombie = {}
	zombie.x = 0
	zombie.y = 0
	zombie.movementSpeed = 150
	zombie.dead = false

	local side = math.random(1,4)
	if side == 1 then -- left screen
		zombie.x = -30
		zombie.y = math.random(0, love.graphics.getHeight())
	elseif side  == 2 then -- top screen
		zombie.x = math.random(0, love.graphics.getWidth())
		zombie.y = -30
	elseif side == 3 then -- right screen
		zombie.x = love.graphics.getWidth() + 30
		zombie.y = math.random(0, love.graphics.getHeight())
	elseif side == 4 then -- bottom screen
		zombie.x = math.random(0, love.graphics.getWidth())
		zombie.y = love.graphics.getHeight() +30
	end

	table.insert(zombies, zombie)
end

function spawnBullet()
	bullet = {}
	bullet.x = player.x
	bullet.y = player.y
	bullet.movementSpeed = 500
	bullet.direction = playerMouseAngle() 
	bullet.dead = false

	table.insert(bullets, bullet)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		spawnZombie()
	end
end

function love.mousepressed(x, y, b, istouch)
	if b == 1 and gameState == 2 then
		spawnBullet()
	end

	if gameState == 1 then 
		gameState = 2
		maxTime = 2
		timer = maxTime
		score = 0
	end
end

function distanceBetween(x1, y1, x2, y2)
	return math.sqrt((y2-y1)^2 + (x2-x1)^2)
end
