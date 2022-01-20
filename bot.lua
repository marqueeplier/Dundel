bot = {}

function bot:load()
	self.name = "Steve"
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
	self._movement = 50
	self._speed = 500

--Damages
	
	self.damage = 10
	self.damage_sb = 1.5
	self.damage_fb = 2.5
	self.damage_fireb = 5

--Animation related	
	
	self.fps = 6
	self.anim_timer = 1 / self.fps

	self.walk_spritesheet = love.graphics.newImage("assets/player1/bob_walk.png")

	self.xoff = 0
	self.yoff = 0
	self.current_sprite = love.graphics.newQuad(self.xoff, self.yoff, 64, 64, self.walk_spritesheet:getDimensions())
	
	_weapon3 = self.weapon
	_healthbar3 = self.healthbar
	_rage3 = self.rage
end

-- Parent functions Bot
function bot:update(dt)
	if (player1.win ~= true) and draw ~= true then
		bot:movement(dt)
		bot:boundary()
		bot:attack(dt)
		bot:block(dt)
		bot:rage_u(dt)
		bot:win_u()
		bot:swordbreak_u()
	end
	bot:healthbar_u()
end

function bot:draw()
	love.graphics.scale(3, 3)
	love.graphics.setColor(255, 255, 255)
	bot:healthbar_d()
	if player1.win ~= true and draw ~= true then
		bot:rage_d()
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.current_image, self.x, self.y)
		bot:hitbox()
		bot:win_d()
	end
end

-- movement Bot
function bot:movement(dt)
	self.xvel = self.xvel * (1 - math.min(dt * self.friction, 1))	
	self._movement = self._movement - self._speed * dt

	if self._movement <= 0 and self.xvel > -100 
	and self.current_state ~= self.states.block then
		self._movement = 100
		self.xvel = self.xvel - self.speed * dt
	end
	if self.x < player1.x + 30 and self.xvel < 100 
	and self.current_state ~= self.states.block then
		self.xvel = self.xvel + self.speed * dt
	end

	self.x = self.x + self.xvel
	
	_weapon3.x = self.x + 2
	_weapon3.y = self.y + 35
end

-- Healthbar Bot
function bot:healthbar_d()
	if self.health <= 20 then
		love.graphics.setColor(255, 100, 100)
	else
		love.graphics.setColor(144, 238, 144)
	end
	love.graphics.rectangle("fill", _healthbar3.x, _healthbar3.y, _healthbar3.width, _healthbar3.height)
	if self.health <= 20 then
		love.graphics.setColor(255, 100, 160)
	else
		love.graphics.setColor(144, 238, 200)
	end
	love.graphics.rectangle("line", _healthbar3.x, _healthbar3.y, _healthbar3.width, _healthbar3.height)
	love.graphics.setColor(155, 135, 12)
	love.graphics.print(self.name.." : "..self.health, _healthbar3.x, 2)

	love.graphics.setColor(255, 200, 144)
	love.graphics.rectangle("fill", _weapon3.healthbar.x, _weapon3.healthbar.y, _weapon3.healthbar.width, _weapon3.healthbar.height)
	love.graphics.setColor(255, 220, 144)
	love.graphics.rectangle("line", _weapon3.healthbar.x, _weapon3.healthbar.y, _weapon3.healthbar.width, _weapon3.healthbar.height)
end

function bot:healthbar_u()
	if self.healthbar.width < 0 then
		self.healthbar.width = 0
		self.health = 0
	end

	if _weapon3.healthbar.width < 0 then
		_weapon3.healthbar.width = 0
	end
end
-- Boundary Bot
function bot:boundary()
	if self.x < 0 then
		self.xvel = 0
		self.x = 0
	end

	if self.x + self.width > love.graphics.getWidth() / 3 then
		self.xvel = 0
		self.x = love.graphics.getWidth() / 3 - self.width
	end
end

-- Actions Bot(attack and block)
function bot:attack(dt)
	self.a_cooldown = self.a_cooldown - self.a_timer * dt

-- weapon not broken :)	
	
	if _weapon3.swordbreak ~= true then
		if true and self.a_cooldown < 0 and self.current_state ~= self.states.block
		and self.current_state == self.states.idle then
			love.audio.play(music.slash)
			self.a_cooldown = 40
			self.current_state = self.states.attacking
			self.current_image = self.images.attack
			bot:Collision()
		end
		if self.a_cooldown < 0 and self.current_state == self.states.attacking then 
			self.current_state = self.states.idle
			self.current_image = self.images.idle
		end
	end

-- weapon broken :(
	
	if _weapon3.swordbreak == true then
		if true and self.a_cooldown <= 0 and self.current_state ~= self.states.block 
			and self.current_state == self.states.sword_bi then
			love.audio.play(music.slash)
			self.a_cooldown = 40
			self.current_state = self.states.sword_ba
			self.current_image = self.images.swordbreak_a
			bot:Collision()
		end
		if self.a_cooldown <= 0 and self.current_state == self.states.sword_ba then
			self.current_state = self.states.sword_bi 
			self.current_image = self.images.swordbreak_i
		end
	end
end

function bot:hitbox()
	if self.current_state == self.states.attacking then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(player2.slash_img ,_weapon3.x - 12, _weapon3.y - 3)
	end
end

function bot:block(dt)
	self.b_cooldown = self.b_cooldown - self.b_timer * dt

	if (player1.current_state == player1.states.attacking and self.b_cooldown <= -10 
		and self.current_state ~= self.states.attacking and _weapon3.swordbreak ~= true) or (#player1.projectiles > 0) then
		self.b_cooldown = 20
		self.current_state = self.states.block
		self.current_image = self.images.block
	end

	if self.b_cooldown < 0 and self.current_state == self.states.block then
		self.current_state = self.states.idle
		self.current_image = self.images.idle
	end
end

-- Collissions with Bot
function bot:Collision()
	if CheckCollisions(_weapon3, player1) and player1.current_state ~= player1.states.block then
		love.audio.play(music.hurt)
		player1.health = player1.health - self.damage
		player1.healthbar.width = player1.healthbar.width - self.damage
	end

	if CheckCollisions(_weapon3, player1) and player1.current_state == player1.states.block then
		love.audio.play(music.clash)
		_weapon.healthbar.width = _weapon.healthbar.width - self.damage_sb
	end
end

-- rage functionality Bot :)
function bot:rage_u(dt)
	if self.health <= 20 then
		_rage3.raging = true
	end

	if _rage3.raging == true then
		_rage3.timer = _rage3.timer - 50 * dt
	end

	if _rage3.timer <= 0 then
		_rage3.raging = false
	end
	if _rage3.raging == true then
		love.audio.play(music.rage)
		fire = {}
		fire.x = self.x + 30
		fire.y = self.y + 25
		fire.width = 5
		fire.height = 5
		table.insert(self.fireball, fire)
	end

	for i, f in ipairs(self.fireball) do
		if f.x < 0 or (self.win == true or player1.win == true or draw == true or _rage3.raging == false) then
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

function bot:rage_d()
	for i, f in pairs(self.fireball) do
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(_projectile_img_1, f.x, f.y)
	end

	if _rage3.raging == true then
		love.graphics.setColor(255, 104, 203)
		love.graphics.print("Rage time :"..math.floor(_rage3.timer), 150, 40)
		love.graphics.setColor(255, 0, 0, 100)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth() / 3, love.graphics.getHeight() / 3)
	end
end

-- win Bot
function bot:win_u()
	if player1.health <= 0 then
		self.win = true
	end
end

function bot:win_d()
	if self.win == true then
		love.graphics.setColor(255, 104, 203)
		love.graphics.print(self.name.." Wins \n \n"..self.name.."ality", 80, 50)
		love.graphics.print("'R to restart'", 75, 120)
	end
end

-- Bot sword break :(
function bot:swordbreak_u()
	if _weapon3.healthbar.width <= 0 then
		_weapon3.swordbreak = true
	end 

	if self.current_state == self.states.block and _weapon3.swordbreak == true then
		love.audio.play(music.s_break)
		self.current_state = self.states.sword_bi
		self.current_image = self.images.swordbreak_i
	end
end