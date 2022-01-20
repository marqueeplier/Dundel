player1 = {}

function player1:load()
	self.name = "Bob"
	self.x = 5
	self.y = 136
	self.width = 64
	self.height = 64
	self.speed = 30
	self.xvel = 0
	self.yvel = 0
	self.friction = 3.5
	self.images = {	
					idle = love.graphics.newImage("assets/player1/idle.png"),
					attack = love.graphics.newImage("assets/player1/attack.png"),
					block = love.graphics.newImage("assets/player1/block.png"),
					swordbreak_a = love.graphics.newImage("assets/player1/swordbreakattack.png"),
					swordbreak_i = love.graphics.newImage("assets/player1/swordbreakidle.png")
				   }
	self.current_image = self.images.idle
	self.states = {	
					idle = "idle",
					walk = "walk",
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
					healthbar = { x = 73,
								  y = 20,
								  width = 30,
								  height = 10
								  }
				   }
	self.healthbar = { x = 3,
					   y = 3,
					   width = 100,
					   height = 12 
					  }
	self.health = 100
	self.win = false
	self.rage = { timer = 40,
				  raging = false}
	self.fireball = {}

	self.fire_img = love.graphics.newImage("assets/player2/ross_fireball.png")
	self.fire_img:setFilter("nearest", "nearest")
	self.projectiles = {}
	self.remaining_projectiles = 5

	_projectile_img = self.fire_img

	self.slash_img = love.graphics.newImage("assets/player1/bob_slash.png")
	self.slash_img:setFilter("nearest", "nearest")

--Animation related	
	
	self.fps = 6
	self.anim_timer = 1 / self.fps

	self.walk_spritesheet = love.graphics.newImage("assets/player1/bob_walk.png")

	self.walk_spritesheet:setFilter("nearest", "nearest")

	self.xoff = 0
	self.yoff = 0
	self.current_sprite = love.graphics.newQuad(self.xoff, self.yoff, 64, 64, self.walk_spritesheet:getDimensions())

--Damages
	self.damage = 10
	self.damage_sb = 1.5
	self.damage_fb = 2.5
	self.damage_fireb = 5
	
	_weapon = self.weapon
	_healthbar = self.healthbar
	_rage = self.rage

	draw = false
end

-- Parent functions Bob
function player1:update(dt)
	if (player2.win ~= true and bot.win ~= true) and draw ~= true then
		player1:movement(dt)
		player1:boundary()
		player1:attack(dt)
		player1:block(dt)
		player1:rage_u(dt)
		player1:win_u()
		player1:swordbreak_u()
	end
	
-- Always updated
	player1:healthbar_u()	
	players_anim_main_u(dt)
	win()
	restart()
end

function player1:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.push()
	love.graphics.scale(3, 3)
	
	player1:healthbar_d()
	
	if player2.win ~= true and bot.win ~= true and self.current_state ~= self.states.walk then
		player1:rage_d()
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.current_image, self.x, self.y)
		player1:hitbox()
		player1:win_d()
		draw_d()
	end
	players_anim_main_d()
	love.graphics.pop()
end

-- movement Bob
function player1:movement(dt)
	self.xvel = self.xvel * (1 - math.min(dt * self.friction, 1))	

	if love.keyboard.isDown("a") and self.xvel > -100 
		and self.current_state ~= self.states.block then
		self.xvel = self.xvel - self.speed * dt
		self.current_state = self.states.walk
	elseif love.keyboard.isDown("d") and self.xvel < 100 
		and self.current_state ~= self.states.block then
		self.current_state = self.states.walk
		self.xvel = self.xvel + self.speed * dt
	end

	self.x = self.x + self.xvel
	
	_weapon.x = self.x + 45
	_weapon.y = self.y + 35
end

-- boundary Bob
function player1:boundary()
	if self.x < 0 then
		self.x = 0
		self.xvel = 0
	end

	if self.x + self.width > love.graphics.getWidth() / 3 then
		self.xvel = 0
		self.x = love.graphics.getWidth() / 3 - self.width
	end
end

-- actions(attack and block)
function player1:attack(dt)
	self.a_cooldown = self.a_cooldown - self.a_timer * dt

-- weapon not broken :)
	
	if _weapon.swordbreak ~= true then
		if love.keyboard.isDown("j") and self.a_cooldown <= 0 and self.current_state ~= self.states.block 
			and self.current_state == self.states.idle and self.current_state ~= self.states.walk then
			love.audio.play(music.slash)
			self.a_cooldown = 40
			self.current_state = self.states.attacking
			self.current_image = self.images.attack
			player1:Collision()
		end

		if self.a_cooldown <= 0 and self.current_state == self.states.attacking then
			self.current_state = self.states.idle 
			self.current_image = self.images.idle
		end
	end

-- weapon broken :(
	
	if _weapon.swordbreak == true then
		if love.keyboard.isDown("j") and self.a_cooldown <= 0 and self.current_state ~= self.states.block
		and self.current_state == self.states.sword_bi then
			love.audio.play(music.slash)
			self.a_cooldown = 40
			self.current_state = self.states.sword_ba
			self.current_image = self.images.swordbreak_a
			player1:Collision()
		end
		if self.a_cooldown <= 0 and self.current_state == self.states.sword_ba then
			self.current_state = self.states.sword_bi 
			self.current_image = self.images.swordbreak_i
		end
	end
end

function player1:hitbox()
	if self.current_state == self.states.attacking then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.slash_img, _weapon.x, _weapon.y - 3)
	end
end

function player1:block(dt)
	self.b_cooldown = self.b_cooldown - self.b_timer * dt

	if love.keyboard.isDown("k") and self.b_cooldown <= 0 
		and self.current_state ~= self.states.attacking and _weapon.swordbreak ~= true then
		self.b_cooldown = 20
		self.current_state = self.states.block
		self.current_image = self.images.block
	end

	if self.b_cooldown <= 0 and self.current_state == self.states.block then
		self.current_state = self.states.idle
		self.current_image = self.images.idle
	end
end

-- healthbar Bob
function player1:healthbar_d()
	if self.health <= 20 then
		love.graphics.setColor(255, 100, 100)
	else
		love.graphics.setColor(144, 238, 144)
	end
	love.graphics.rectangle("fill", _healthbar.x, _healthbar.y, _healthbar.width, _healthbar.height)
	if self.health <= 20 then
		love.graphics.setColor(255, 100, 160)
	else
		love.graphics.setColor(144, 238, 200)
	end
	love.graphics.rectangle("line", _healthbar.x, _healthbar.y, _healthbar.width, _healthbar.height)
	love.graphics.setColor(255, 200, 144)
	love.graphics.rectangle("fill", _weapon.healthbar.x, _weapon.healthbar.y, _weapon.healthbar.width, _weapon.healthbar.height)
	love.graphics.setColor(255, 220, 144)
	love.graphics.rectangle("line", _weapon.healthbar.x, _weapon.healthbar.y, _weapon.healthbar.width, _weapon.healthbar.height)
	love.graphics.setColor(155, 135, 12)
	love.graphics.print(self.name.." : "..self.health, _healthbar.x, 2)
end

function player1:healthbar_u()
	if self.healthbar.width < 0 then
		self.healthbar.width = 0
		self.health = 0
	end

	if _weapon.healthbar.width <= 0 then
		_weapon.healthbar.width = 0
	end
end

-- Collision with Ross
function player1:Collision()
	if menu.current_state == menu.states.player2 then
		if CheckCollisions(_weapon, player2) and player2.current_state ~= player2.states.block then
			love.audio.play(music.hurt1)
			player2.health = player2.health - self.damage
			player2.healthbar.width = player2.healthbar.width - self.damage
		end

		if CheckCollisions(_weapon, player2) and player2.current_state == player2.states.block then
			love.audio.play(music.clash)
			player2.weapon.healthbar.width = player2.weapon.healthbar.width - self.damage_sb
		end
	end

	if menu.current_state == menu.states.bot then
		if CheckCollisions(_weapon, bot) and bot.current_state ~= bot.states.block then
			love.audio.play(music.hurt1)
			bot.health = bot.health - self.damage
			bot.healthbar.width = bot.healthbar.width - self.damage
		end

		if CheckCollisions(_weapon, bot) and bot.current_state == bot.states.block then
			love.audio.play(music.clash)
			bot.weapon.healthbar.width = bot.weapon.healthbar.width - self.damage_sb
		end
	end
end

-- rage functionality bob :)
function player1:rage_u(dt)
	if self.health <= 20 then
		_rage.raging = true
	end

	if _rage.raging == true then
		_rage.timer = _rage.timer - 50 * dt
	end

	if _rage.timer <= 0 then
		_rage.raging = false
	end
	if love.keyboard.isDown("l") and _rage.raging == true then
		love.audio.play(music.rage)
		fire = {}
		fire.x = self.x + 30
		fire.y = self.y + 25
		fire.width = 5
		fire.height = 5
		table.insert(self.fireball, fire)
	end

	for i, f in ipairs(self.fireball) do

	if menu.current_state == menu.states.player2 then
		if f.x > 300 or self.win == true or player2.win == true or draw == true then
			table.remove(self.fireball, i)
		end

		if CheckCollisions(f, player2) and player2.current_state ~= player2.states.block then
			table.remove(self.fireball, i)
			player2.health = player2.health - self.damage_fb
			_healthbar2.width = _healthbar2.width - self.damage_fb 
		end

		if CheckCollisions(f, player2) and player2.current_state == player2.states.block then
			table.remove(self.fireball, i)
			_weapon2.healthbar.width = _weapon2.healthbar.width - 1
		end
		f.x = f.x + 100 * dt
	end

	if menu.current_state == menu.states.bot then
		if f.x > 300 or (self.win == true or player1.win == true or draw == true or _rage.raging == false) then
			table.remove(self.fireball, i)
		end

		if CheckCollisions(f, bot) and bot.current_state ~= bot.states.block then
			table.remove(self.fireball, i)
			bot.health = bot.health - self.damage_fireb
			_healthbar2.width = _healthbar2.width - self.damage_fireb 
		end

		if CheckCollisions(f, bot) and bot.current_state == bot.states.block then
			table.remove(self.fireball, i)
			_weapon2.healthbar.width = _weapon2.healthbar.width - self.damage_fireb
		end
		f.x = f.x + 100 * dt
	end
	end

	for i, f in ipairs(self.fireball) do
		for i2, f2 in ipairs(player2.fireball or bot.fireball) do
			if CheckCollisions(f, f2) then
				table.remove(self.fireball, i)
				table.remove(player2.fireball or bot.fireball, i2)
			end
		end
	end
end

function player1:rage_d()
	for i, f in pairs(self.fireball) do
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(_projectile_img, f.x, f.y)
	end

	love.graphics.setColor(255, 104, 203)

	if _rage.raging == true then
		love.graphics.print("Rage time :"..math.floor(_rage.timer), 5, 40)
		love.graphics.setColor(0, 0, 255, 100)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth() / 3, love.graphics.getHeight() / 3)
	end
end

-- win bob
function player1:win_u()
	if player2.health <= 0 or bot.health <= 0 then
		self.win = true
	end
end

function player1:win_d()
	if self.win == true then
		love.graphics.setColor(255, 104, 203)
		love.graphics.print(self.name.." Wins \n \n"..self.name.."ality", 90, 50)
		love.graphics.print("'R to restart'", 75, 120)
	end
end

-- Bob sword break :(
function player1:swordbreak_u()
	if _weapon.healthbar.width <= 0 then
		_weapon.swordbreak = true
	end 

	if self.current_state == self.states.block and _weapon.swordbreak == true then
		love.audio.play(music.s_break)
		self.current_state = self.states.sword_bi
		self.current_image = self.images.swordbreak_i
	end
end

function player1:fireball_launch(key)
	if key == "h" and self.remaining_projectiles >= 0 then
		love.audio.play(music.fireball_launch)
		self.remaining_projectiles = self.remaining_projectiles - 1
		projectile = {}
		projectile.x = self.x + 20
		projectile.y = self.y + 10
		projectile.width = 16
		projectile.height = 16
		projectile.speed = 200
		projectile.xoff = 0
		projectile.yoff = 0
		projectile.img = _projectile_img
		projectile.current_sprite = love.graphics.newQuad(projectile.xoff, projectile.yoff, 16, 15, projectile.img:getDimensions())
		table.insert(self.projectiles, projectile)
	end
end

-- timer
function timer_load()
	timer = 0
 	speed = 1
 	countdown = 60
end

function timer_update(dt)
-- Timers	
	if timer > 1 then
		timer = timer - 1
	end
	
	if player1.win ~= true and player2.win ~= true and bot.win ~= true then 
		timer = timer + speed * dt
	end

	if timer >= 1 then
		countdown = countdown - 1
	end

	if countdown <= 0 then
		countdown = 0
	end
end

function timer_draw()
	love.graphics.setColor(255, 104, 203)
	love.graphics.push()
	love.graphics.print(countdown, 120, 2) 
	love.graphics.pop()
end

function win()
	if countdown <= 0 then
		if menu.current_state == menu.states.player2 then
			if player1.health > player2.health then
				player1.win = true
			end
			if player2.health > player1.health then
				player2.win = true
			end
			if player1.health == player2.health then
				draw = true
			end
		end

		if menu.current_state == menu.states.bot then
			if player1.health > bot.health then
				player1.win = true
			end
			if bot.health > player1.health then
				bot.win = true
			end
			if player1.health == bot.health then
				draw = true
			end
		end
	end
end

function draw_d()
	if draw == true then
		love.graphics.setColor(255, 104, 203)
		love.graphics.print("draw wins \n \n Drawality", 100, 50)
	end
end

function restart()
	if love.keyboard.isDown("r") and (player1.win == true or player2.win == true or bot.win == true or draw == true) then
		player1.win = false
		player2.win = false
		player1.remaining_projectiles = 5
		player2.remaining_projectiles = 5
		player1.xoff = 0
		player1.yoff = 0
		player2.xoff = 0
		player2.yoff = 0
		bot.win = false
		draw = false
		player1.health = 100
		player2.health = 100
		bot.health  = 100
		player1.x = 5
		player1.xvel = 0
		bot.x = 200
		bot.xvel = 0
		bot.y = 136
		player1.y = 136
		player1.current_image = player1.images.idle
		player1.current_state = player1.states.idle
		player2.current_image = player2.images.idle
		player2.current_state = player2.states.idle
		bot.current_image = player2.images.idle
		bot.current_state = player2.states.idle
		player2.x = 200
		player2.xvel = 0
		player2.y = 136
		countdown = 60
		_healthbar.width = 100
		_weapon.healthbar.width = 30
		_healthbar2.width = 100
		_healthbar3.width = 100
		_weapon3.healthbar.width = 30
		_weapon3.swordbreak = false
		_weapon2.healthbar.width = 30
		_weapon.swordbreak = false
		_weapon2.swordbreak = false
		_rage.raging = false
		_rage.timer = 40 
		_rage2.raging = false
		_rage2.timer = 40
		_rage3.raging = false
		_rage3.timer = 40
		background_u = math.random(1, num_of_bg)
	end
end 

-- 'm' reset
function menu_reset()
	player1.win = false
	player2.win = false
	player1.remaining_projectiles = 5
	player2.remaining_projectiles = 5
	player1.xoff = 0
	player1.yoff = 0
	player2.xoff = 0
	player2.yoff = 0
	bot.win = false
	draw = false
	player1.health = 100
	player2.health = 100
	bot.health  = 100
	player1.x = 5
	player1.xvel = 0
	bot.x = 200
	bot.xvel = 0
	bot.y = 136
	player1.y = 136
	player1.current_image = player1.images.idle
	player1.current_state = player1.states.idle
	player2.current_image = player2.images.idle
	player2.current_state = player2.states.idle
	bot.current_image = player2.images.idle
	bot.current_state = player2.states.idle
	player2.x = 200
	player2.xvel = 0
	player2.y = 136
	countdown = 60
	_healthbar.width = 100
	_weapon.healthbar.width = 30
	_healthbar2.width = 100
	_healthbar3.width = 100
	_weapon3.healthbar.width = 30
	_weapon3.swordbreak = false
	_weapon2.healthbar.width = 30
	_weapon.swordbreak = false
	_weapon2.swordbreak = false
	_rage.raging = false
	_rage.timer = 40 
	_rage2.raging = false
	_rage2.timer = 40
	_rage3.raging = false
	_rage3.timer = 40
end

function players_anim_main_u(dt)
	players_animation_u(player1, dt)
	players_animation_u(player2, dt)
	players_animation_u(bot, dt)

	players_swordbreak_u(player1)
	players_swordbreak_u(player2)
	players_swordbreak_u(bot)

	players_projectile_u(player1.projectiles, dt)
	players_projectile_u(player2.projectiles, dt)

	players_projectile_col(player1.projectiles, player2.projectiles)
end

function players_anim_main_d()
	players_animation_d(player1)
	players_animation_d(player2)
	players_animation_d(bot)
	players_projectile_d(player1.projectiles)
	players_projectile_d(player2.projectiles)
end

function players_animation_u(char, dt)
	char.anim_timer = char.anim_timer - dt

	if char.anim_timer <= 0 then
		char.anim_timer = 1 / char.fps
	if char.current_state == char.states.walk then
		char.xoff = char.xoff + 64

		if char.xoff >= 256 then
			char.xoff = 0
		end
	end
	char.current_sprite = love.graphics.newQuad(char.xoff, char.yoff, 64, 64, char.walk_spritesheet:getDimensions())
	end
end

function anim_reset(key)
	if key == "a" or key == "d" or key == "j" or key == "k" or key == "l" then
		if _weapon.swordbreak == false then 
			player1.current_state = player1.states.idle
			player1.current_image = player1.images.idle
		else
			player1.current_state = player1.states.sword_bi
			player1.current_image = player1.images.swordbreak_i
		end
		player1.xoff = 0
	end   

	if key == "left" or key == "kp4" or key == "right" 
		or key == "kp6" or key == "rctrl" or key == "kp+"
		or key == "return" or key == "kp5" or key == "kpenter" 
		or key == "rshift" then
		if _weapon2.swordbreak == false then 
			player2.current_state = player2.states.idle
			player2.current_image = player2.images.idle
		else
			player2.current_state = player2.states.sword_bi
			player2.current_image = player2.images.swordbreak_i
		end
		player2.xoff = 0
	end   
end

function players_animation_d(char)
	if char.current_state == char.states.walk then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(char.walk_spritesheet, char.current_sprite, char.x, char.y)
	end
end

function players_swordbreak_u(char)
	if char.weapon.healthbar.width <= 0 then
		char.yoff = 64
	end
end

function players_projectile_u(projectile_table, dt)
	for i, p in pairs(projectile_table) do 
		if p then
			p.xoff = p.xoff + 16

			if p.xoff >= 64 then
				p.xoff = 0
			end
			p.current_sprite = love.graphics.newQuad(p.xoff, p.yoff, 16, 15, p.img:getDimensions())

			p.x = p.x + p.speed * dt

			if p.x <= 0 or p.x >= 500 then
				table.remove(projectile_table, i)
			end
			
			if player1.win == true or player2.win == true or bot.win == true then
				table.remove(projectile_table, i)
			end
		end
	end
end

function players_projectile_col(p1_proj, p2_proj)
	for i1, p1 in pairs(p1_proj) do
		if player1.win ~= true then
		if CheckCollisions(p1, player2) and player2.current_state ~= player2.states.block then
			love.audio.play(music.fireball_hit)
			player2.health = player2.health - player1.damage
			_healthbar2.width = _healthbar2.width - player1.damage 
			table.remove(p1_proj, i1)
		end

		if CheckCollisions(p1, player2) and player2.current_state == player2.states.block then
			love.audio.play(music.clash)
			player2.weapon.healthbar.width = player2.weapon.healthbar.width - player1.damage_fb
			table.remove(p1_proj, i1)
		end

		if CheckCollisions(p1, bot) and bot.current_state ~= bot.states.block then				
			love.audio.play(music.fireball_hit)
			bot.health = bot.health - player1.damage
			_healthbar3.width = _healthbar3.width - player1.damage 
			table.remove(p1_proj, i1)
		end

		if CheckCollisions(p1, bot) and bot.current_state == bot.states.block then				
			love.audio.play(music.clash)
			bot.weapon.healthbar.width = bot.weapon.healthbar.width - player1.damage_fb
			table.remove(p1_proj, i1)
		end
		end
	end

	for i2, p2 in pairs(p2_proj) do 
		if player2.win ~= true then
		if CheckCollisions(p2, player1) and player1.current_state ~= player1.states.block then
			love.audio.play(music.fireball_hit)
			player1.health = player1.health - player2.damage
			_healthbar.width = _healthbar.width - player2.damage 
			table.remove(p2_proj, i2)
		end

		if CheckCollisions(p2, player1) and player1.current_state == player1.states.block then
			love.audio.play(music.clash)
			player1.weapon.healthbar.width = player1.weapon.healthbar.width - player2.damage_sb
			table.remove(p2_proj, i2)
		end
	for i1, p1 in pairs(p1_proj) do
		if CheckCollisions(p1, p2) then 
			love.audio.play(music.fireball_hit)
			table.remove(p1_proj, i1)
			table.remove(p2_proj, i2)
		end
		end
	end
	end
end

function players_projectile_d(projectile_table)
	for i, p in pairs(projectile_table) do
		if p then
			love.graphics.setColor(255, 255, 255)
			love.graphics.draw(p.img, p.current_sprite, p.x, p.y)
			love.graphics.setColor(0, 255, 255)
		end
	end	
end