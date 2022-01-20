player2 = {}

function player2:load()
	self.name = "Ross"
	self.x = 200
	self.y = 136
	self.width = 64
	self.height = 64
	self.speed = 30
	self.xvel = 0
	self.yvel = 0
	self.friction = 3.5
	self.images = {	
					idle = love.graphics.newImage("assets/player2/idle.png"),
					attack = love.graphics.newImage("assets/player2/attack.png"),
					block = love.graphics.newImage("assets/player2/block.png"),
					swordbreak_a = love.graphics.newImage("assets/player2/swordbreakattack.png"),
					swordbreak_i = love.graphics.newImage("assets/player2/swordbreakidle.png")
				   }
	self.current_image = self.images.idle
	self.states = {	
					idle = "idle",
					attacking = "attacking",
					block = "block",
					sword_bi = "breakidle",
					sword_ba = "breakattack"
				   }
	self.current_state = self.states.idle
	self.a_cooldown = 40
	self.b_cooldown = 20
	self.a_timer = 100
	self.b_timer = 100
	self.weapon = {	x = self.x,
					y = self.y,
					width = 15,
					height = 5,
					swordbreak = false,
					healthbar = { x = 160,
								  y = 20,
								  width = 30,
								  height = 10
								 }
				   }
	self.healthbar = { x = 163,
					   y = 3,
					   width = 100,
					   height = 12
					  }
	self.win = false
	self.health = 100
	self.rage = { timer = 40,
				  raging = false}
	self.fireball = {}

	self.fire_img = love.graphics.newImage("assets/player1/bob_fireball.png")
	self.fire_img:setFilter("nearest", "nearest")
	self.projectiles = {}
	self.remaining_projectiles = 5

	_projectile_img_1 = self.fire_img

	self.slash_img = love.graphics.newImage("assets/player2/ross_slash.png")
	self.slash_img:setFilter("nearest", "nearest")
--Damages

	self.damage = 10
	self.damage_sb = 1.5
	self.damage_fb = 2.5
	self.damage_fireb = 5

--Animation related	
	
	self.fps = 5
	self.anim_timer = 1 / self.fps

	self.xoff = 0
	self.yoff = 0

	self.walk_spritesheet = love.graphics.newImage("assets/player2/ross_walk.png")

	self.walk_spritesheet:setFilter("nearest", "nearest")
	
	_weapon2 = self.weapon
	_healthbar2 = self.healthbar
	_rage2 = self.rage
end

-- Parent functions Ross
function player2:update(dt)
	if (player1.win ~= true) and draw ~= true then
		player2:movement(dt)
		player2:boundary()
		player2:attack(dt)
		player2:block(dt)
		player2:rage_u(dt)
		player2:win_u()
		player2:swordbreak_u()
	end
	player2:healthbar_u()
end

function player2:draw()
	love.graphics.scale(3, 3)
	love.graphics.setColor(255, 255, 255)
	player2:healthbar_d()
	if player1.win ~= true and self.current_state ~= self.states.walk then
		player2:rage_d()
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.current_image, self.x, self.y)
		player2:hitbox()
		player2:win_d()
	end
end

-- movement Ross
function player2:movement(dt)
	self.xvel = self.xvel * (1 - math.min(dt * self.friction, 1))	

	if love.keyboard.isDown("left", "kp4") and self.xvel > -100 
	and self.current_state ~= self.states.block then
		self.xvel = self.xvel - self.speed * dt
		self.current_state = self.states.walk
	elseif love.keyboard.isDown("right", "kp6") and self.xvel < 100 
	and self.current_state ~= self.states.block then
		self.xvel = self.xvel + self.speed * dt
		self.current_state = self.states.walk
	end

	self.x = self.x + self.xvel
	
	_weapon2.x = self.x + 2
	_weapon2.y = self.y + 35
end

-- Healthbar Ross
function player2:healthbar_d()
	if self.health <= 20 then
		love.graphics.setColor(255, 100, 100)
	else
		love.graphics.setColor(144, 238, 144)
	end
	love.graphics.rectangle("fill", _healthbar2.x, _healthbar2.y, _healthbar2.width, _healthbar2.height)
	if self.health <= 20 then
		love.graphics.setColor(255, 100, 160)
	else
		love.graphics.setColor(144, 238, 200)
	end
	love.graphics.rectangle("line", _healthbar2.x, _healthbar2.y, _healthbar2.width, _healthbar2.height)
	love.graphics.setColor(155, 135, 12)
	love.graphics.print(self.name.." : "..self.health, _healthbar2.x, 2)

	love.graphics.setColor(255, 200, 144)
	love.graphics.rectangle("fill", _weapon2.healthbar.x, _weapon2.healthbar.y, _weapon2.healthbar.width, _weapon2.healthbar.height)
	love.graphics.setColor(255, 220, 144)
	love.graphics.rectangle("line", _weapon2.healthbar.x, _weapon2.healthbar.y, _weapon2.healthbar.width, _weapon2.healthbar.height)
end

function player2:healthbar_u()
	if self.healthbar.width < 0 then
		self.healthbar.width = 0
		self.health = 0
	end

	if _weapon2.healthbar.width < 0 then
		_weapon2.healthbar.width = 0
	end
end
-- Boundary Ross
function player2:boundary()
	if self.x < 0 then
		self.xvel = 0
		self.x = 0
	end

	if self.x + self.width > love.graphics.getWidth() / 3 then
		self.xvel = 0
		self.x = love.graphics.getWidth() / 3 - self.width
	end
end

-- Actions Ross(attack and block)
function player2:attack(dt)
	self.a_cooldown = self.a_cooldown - self.a_timer * dt

-- weapon not broken :)	
	
	if _weapon2.swordbreak ~= true then
		if love.keyboard.isDown("kp+", "rctrl") and self.a_cooldown < 0 and self.current_state ~= self.states.block
		and self.current_state == self.states.idle and self.current_state ~= self.states.walk then
			love.audio.play(music.slash)
			self.a_cooldown = 40
			self.current_state = self.states.attacking
			self.current_image = self.images.attack
			player2:Collision()
		end
		if self.a_cooldown < 0 and self.current_state == self.states.attacking then 
			self.current_state = self.states.idle
			self.current_image = self.images.idle
		end
	end

-- weapon broken :(
	
	if _weapon2.swordbreak == true then
		if love.keyboard.isDown("kp+", "rctrl") and self.a_cooldown <= 0 and self.current_state ~= self.states.block 
			and self.current_state == self.states.sword_bi then
			love.audio.play(music.slash)
			self.a_cooldown = 40
			self.current_state = self.states.sword_ba
			self.current_image = self.images.swordbreak_a
			player2:Collision()
		end
		if self.a_cooldown <= 0 and self.current_state == self.states.sword_ba then
			self.current_state = self.states.sword_bi 
			self.current_image = self.images.swordbreak_i
		end
	end
end

function player2:hitbox()
	if self.current_state == self.states.attacking then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.slash_img, _weapon2.x - 12, _weapon2.y - 3)
	end
end

function player2:block(dt)
	self.b_cooldown = self.b_cooldown - self.b_timer * dt

	if love.keyboard.isDown("kpenter", "rshift") and self.b_cooldown <= 0 
		and self.current_state ~= self.states.attacking and _weapon2.swordbreak ~= true then
		self.b_cooldown = 20
		self.current_state = self.states.block
		self.current_image = self.images.block
	end

	if self.b_cooldown < 0 and self.current_state == self.states.block then
		self.current_state = self.states.idle
		self.current_image = self.images.idle
	end
end

-- Collissions with Ross
function player2:Collision()
	if CheckCollisions(_weapon2, player1) and player1.current_state ~= player1.states.block then
		love.audio.play(music.hurt)
		player1.health = player1.health - self.damage
		player1.healthbar.width = player1.healthbar.width - self.damage
	end

	if CheckCollisions(_weapon2, player1) and player1.current_state == player1.states.block then
		love.audio.play(music.clash)
		_weapon.healthbar.width = _weapon.healthbar.width - self.damage_sb
	end
end

-- rage functionality Ross :)
function player2:rage_u(dt)
	if self.health <= 20 then
		_rage2.raging = true
	end

	if _rage2.raging == true then
		_rage2.timer = _rage2.timer - 50 * dt
	end

	if _rage2.timer <= 0 then
		_rage2.raging = false
	end
	if love.keyboard.isDown("kp5", "return") and _rage2.raging == true then
		love.audio.play(music.rage)
		fire = {}
		fire.x = self.x - 30
		fire.y = self.y + 25
		fire.width = 5
		fire.height = 5
		table.insert(self.fireball, fire)
	end

	for i, f in ipairs(self.fireball) do
		if f.x < 0 or (self.win == true or player1.win == true or draw == true or _rage2.raging == false) then
			table.remove(self.fireball, i)
		end

		if CheckCollisions(f, player1) and player1.current_state ~= player1.states.block then
			table.remove(self.fireball, i)
			player1.health = player1.health - self.damage_fireb
			_healthbar.width = _healthbar.width - self.damage_fireb 
		end

		if CheckCollisions(f, player1) and player1.current_state == player1.states.block then
			table.remove(self.fireball, i)
			_weapon.healthbar.width = _weapon.healthbar.width - 1
		end
		f.x = f.x - 100 * dt
	end

end

function player2:rage_d()
	for i, f in pairs(self.fireball) do
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(_projectile_img_1, f.x, f.y)
	end

	if _rage2.raging == true then
		love.graphics.setColor(255, 104, 203)
		love.graphics.print("Rage time :"..math.floor(_rage2.timer), 150, 40)
		love.graphics.setColor(255, 0, 0, 100)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth() / 3, love.graphics.getHeight() / 3)
	end
end

-- win Ross
function player2:win_u()
	if player1.health <= 0 then
		self.win = true
	end
end

function player2:win_d()
	if self.win == true then
		love.graphics.setColor(255, 104, 203)
		love.graphics.print(self.name.." Wins \n \n"..self.name.."ality", 80, 50)
		love.graphics.print("'R to restart'", 75, 120)
	end
end

-- Ross sword break :(
function player2:swordbreak_u()
	if _weapon2.healthbar.width <= 0 then
		_weapon2.swordbreak = true
	end 

	if self.current_state == self.states.block and _weapon2.swordbreak == true then
		love.audio.play(music.s_break)
		self.current_state = self.states.sword_bi
		self.current_image = self.images.swordbreak_i
	end
end

function player2:fireball_launch(key)
	if (key == "kp7" or key == "down") and self.remaining_projectiles >= 0 then
		love.audio.play(music.fireball_launch)
		self.remaining_projectiles = self.remaining_projectiles - 1
		projectile1 = {}
		projectile1.x = self.x + 20
		projectile1.y = self.y + 10
		projectile1.width = 16
		projectile1.height = 16
		projectile1.speed = -200
		projectile1.xoff = 0
		projectile1.yoff = 0
		projectile1.img = _projectile_img_1
		projectile1.current_sprite = love.graphics.newQuad(projectile1.xoff, projectile1.yoff, 16, 15, projectile1.img:getDimensions())
		table.insert(self.projectiles, projectile1)
	end
end