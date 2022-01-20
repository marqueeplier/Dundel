-- Main Menu
menu = {}

function menu:load()
	self.buttons = { botmatch = {x = 270, y = 180, width = 250, height = 50, 
						image = love.graphics.newImage("assets/menu/botmatch.png")},
					 player2 = {x = 270, y = 280, width = 250, height = 50, 
					 	image = love.graphics.newImage("assets/menu/twoplayer.png")},
					 settings = {x = 270, y = 380, width = 250, height = 50,
					    image = love.graphics.newImage("assets/menu/settings.png")},
					 quit = {x = 270, y = 480, width = 250, height = 50,
						image = love.graphics.newImage("assets/menu/quit.png")}
					}
	
	self.states =  { _menu = "menu",
					 bot = "bot",
				     player2 = "player2",
					 settings = "settings"
				    }
	self.current_state = self.states._menu

	_mousebox = {x = 0, y = 0, width = 10, height = 10}

	_botmatch = self.buttons.botmatch
	_player2 = self.buttons.player2
	_settings = self.buttons.settings
	_quit = self.buttons.quit

	events_load()
end 

function menu:update(dt)
	if CheckCollisions(_mousebox, _botmatch) then
		mousebox_reset()
		self.current_state = self.states.bot
	end

	if CheckCollisions(_mousebox, _player2) then
		mousebox_reset()
		self.current_state = self.states.player2
	end

	if CheckCollisions(_mousebox, _settings) then
		mousebox_reset()
		self.current_state = self.states.settings
	end

	if CheckCollisions(_mousebox, _quit) then
		love.event.quit()
	end
end

function menu:draw()
	logo_d()
	for i, b in pairs(self.buttons) do 
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(b.image, b.x, b.y)
	end

	love.graphics.setColor(255, 255, 255, 1)
	love.graphics.rectangle("fill", _mousebox.x, _mousebox.y, _mousebox.width, _mousebox.height)
end

function love.mousepressed(x, y, istouch)
	if menu.current_state == menu.states._menu or menu.current_state == menu.states.settings then
		_mousebox.x = x
		_mousebox.y = y
	end
end

-- Backgrounds :)

background = {}

function background:load()
	self.images = {	temple = love.graphics.newImage("assets/backgrounds/temple.png"),
					prison = love.graphics.newImage("assets/backgrounds/prison.png"),
					city = love.graphics.newImage("assets/backgrounds/city.png")
				   }
	self.images.temple:setFilter("nearest", "nearest")
	self.images.prison:setFilter("nearest", "nearest")
	self.images.city:setFilter("nearest", "nearest")
	
	self.current_background = self.images.temple

	num_of_bg = 3
	
	math.randomseed(os.time())

	background_u = math.random(1, num_of_bg)
end

function background:update()
	
	if background_u == 1 then
		self.current_background = self.images.temple
	end
	if background_u == 2 then
		self.current_background = self.images.prison
	end 
	if background_u == 3 then
		self.current_background = self.images.city
	end 

end

function background:draw()
	love.graphics.push()
	love.graphics.scale(3, 3)
	love.graphics.setColor(255, 255, 255)
	
	if _gfx.toggle == "Gud" then
		love.graphics.draw(self.current_background, 0, 0)
	end

	events_christmas_d()
	love.graphics.pop()
end

-- settings
settings = {}
function settings:load()
	self.buttons = {gfx = {x = 260, y = 150, width = 250, height = 50, toggle = "Bad"},
					music = {x = 260, y = 250, width = 250, height = 50, toggle = "Off"},
					fullscreen = {x = 260, y = 350, width = 250, height = 50, toggle = "Off"}}

	_gfx = self.buttons.gfx
	_music = self.buttons.music
	_fullscreen = self.buttons.fullscreen

	music = { background = love.audio.newSource("assets/sounds/backgroundmusic.wav"),
			  clash = love.audio.newSource("assets/sounds/clash.wav"),
			  slash = love.audio.newSource("assets/sounds/slash.wav"),
			  hurt = love.audio.newSource("assets/sounds/hurt.wav"),
			  hurt1 = love.audio.newSource("assets/sounds/hurt1.wav"),
			  rage = love.audio.newSource("assets/sounds/rage.wav"),
			  s_break = love.audio.newSource("assets/sounds/break.wav"),
			  fireball_launch = love.audio.newSource("assets/sounds/fireball_launch.wav"),
			  fireball_hit = love.audio.newSource("assets/sounds/fireball_hit.wav")
			 }

	font = love.graphics.newFont("assets/menu/ka1.ttf")

	love.graphics.setFont(font)
end

function settings:update()
-- GFX	
	if CheckCollisions(_mousebox, _gfx) and _gfx.toggle == "Bad" then
		mousebox_reset()
		_gfx.toggle = "Gud"
	end

	if CheckCollisions(_mousebox, _gfx) and _gfx.toggle == "Gud" then
		mousebox_reset()
		_gfx.toggle = "Bad"
	end
-- Music
	
	if CheckCollisions(_mousebox, _music) and _music.toggle == "Off" then
		mousebox_reset()
		_music.toggle = "On"
	end

	if CheckCollisions(_mousebox, _music) and _music.toggle == "On" then
		mousebox_reset()
		_music.toggle = "Off"
	end

-- fullscreen
	if CheckCollisions(_mousebox, _fullscreen) and _fullscreen.toggle == "Off" then
		mousebox_reset()
		_fullscreen.toggle = "On"
		love.window.setFullscreen(true, "normal")
	end

	if CheckCollisions(_mousebox, _fullscreen) and _fullscreen.toggle == "On" then
		mousebox_reset()
		_fullscreen.toggle = "Off"
		love.window.setFullscreen(false, "normal")
	end

-- moosic 
	
	if _music.toggle == "On" then
		music.background:setLooping(music.background)
		love.audio.play(music.background)
	else
		love.audio.stop(music.background)
	end

	events_update()
end

function settings:draw()
	love.graphics.setColor(255, 204, 203)

	love.graphics.rectangle("fill", _gfx.x, _gfx.y, _gfx.width, _gfx.height)
	
	love.graphics.setColor(23, 23, 23)
	love.graphics.print("Gfx : ".._gfx.toggle, _gfx.x, _gfx.y)

	love.graphics.setColor(255, 204, 203)
	love.graphics.rectangle("fill", _music.x, _music.y, _music.width, _music.height)
	
	love.graphics.setColor(23, 23, 23)
	love.graphics.print("Music : ".._music.toggle, _music.x, _music.y)

	love.graphics.setColor(255, 204, 203)
	love.graphics.rectangle("fill", _fullscreen.x, _fullscreen.y, _fullscreen.width, _fullscreen.height)
	
	love.graphics.setColor(23, 23, 23)
	love.graphics.print("Fullscreen : ".._fullscreen.toggle, _fullscreen.x, _fullscreen.y)

	events_button_d()
end

--events

function events_load()
	events = {
			  "noevent",
			  "christmas",
		     }

	logos = {love.graphics.newImage("assets/menu/logo.png"),
			 love.graphics.newImage("assets/events/christmas/christmas_logo.png")}
	
	events_christmas = {love.graphics.newImage("assets/events/christmas/christmas_temple.png"),
						love.graphics.newImage("assets/events/christmas/christmas_prison.png"),
						love.graphics.newImage("assets/events/christmas/christmas_city.png")
						}
	events_christmas[1]:setFilter("nearest", "nearest")
	events_christmas[2]:setFilter("nearest", "nearest")
	events_christmas[3]:setFilter("nearest", "nearest")

	event_no = 2
	current_event = events[event_no]

	event_button = {event = {x = 260, y = 450, width = 250, height = 50, toggle = current_event}}

	_event = event_button.event
end

function hats_load()
	events_hat = {bob_hat = {img = love.graphics.newImage("assets/events/christmas/christmashat_bob.png"), 
							 xoff = player1.x + 15, yoff = player1.y + 2},
				  ross_hat = {img = love.graphics.newImage("assets/events/christmas/christmashat_ross.png"), 
				              xoff = player2.x - 15, yoff = player2.y + 2},
				  steve_hat = {img = love.graphics.newImage("assets/events/christmas/christmashat_ross.png"), 
				               xoff = bot.x + 15, yoff = bot.y + 2}
					}
	events_hat.bob_hat.img:setFilter("nearest", "nearest")
	events_hat.ross_hat.img:setFilter("nearest", "nearest")
end

function events_update()
	events_button_u()
end

function events_draw()
	events_button_d()
end

function events_button_u()
	if menu.current_state == menu.states.settings then
		if CheckCollisions(_mousebox, _event) then 
			
			event_no = event_no + 1
			if event_no > #events then 
				event_no = 1
			end
			
			current_event = events[event_no]
			_event.toggle = current_event
			mousebox_reset()
		end
	end
end

function events_button_d()
	if menu.current_state == menu.states.settings then
		love.graphics.setColor(255, 204, 203)
		love.graphics.rectangle("fill", _event.x, _event.y, _event.width, _event.height)
		love.graphics.setColor(23, 23, 23)
		love.graphics.print("Event : ".._event.toggle, _event.x, _event.y)
	end
end

function events_christmas_d()
	if current_event == events[2] and _gfx.toggle == "Gud" and (menu.current_state == menu.states.bot or
															   menu.current_state == menu.states.player2) then 
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(events_christmas[background_u], 0, 0)
	end
end

function events_foreground_u(character, item, item_xoff, original)
	if current_event == events[2] and _gfx.toggle == "Gud" and (menu.current_state == menu.states.bot or
															   menu.current_state == menu.states.player2) then 
 		item.xoff = character.x + original
		if character.current_state == character.states.idle then
			item.xoff = character.x + original
		end
		if character.current_state == character.states.attacking or 
			character.current_state == character.states.sword_ba then
			item.xoff = item.xoff + item_xoff
		end
	end
end

function foreground_main_u()
	events_foreground_u(player1, events_hat.bob_hat, -14, 15)
	events_foreground_u(player2, events_hat.ross_hat, 7, 30)
	events_foreground_u(bot, events_hat.steve_hat, 7, 30)
end

function foreground_main_d()
	if player1.win ~= true then
		if menu.current_state == menu.states.bot then
			events_foreground_d(events_hat.steve_hat)
		end
		
		if menu.current_state == menu.states.player2 then
			events_foreground_d(events_hat.ross_hat)
		end
	end

	if player2.win ~= true and bot.win ~= true then 
		events_foreground_d(events_hat.bob_hat)
	end
end

function events_foreground_d(char_hat)
	if current_event == events[2] and _gfx.toggle == "Gud" and (menu.current_state == menu.states.bot or
															   menu.current_state == menu.states.player2) then 
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(char_hat.img, char_hat.xoff, char_hat.yoff)
	end
end

function logo_d()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(logos[event_no], 220, 35)
end

function mousebox_reset()
	_mousebox.x, _mousebox.y = 0, 0
end