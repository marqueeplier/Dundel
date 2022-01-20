require "mainmenu"
require "collissions"
require "player1"
require "player2"
require "bot"

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	menu:load()
	player1:load()
	player2:load()
	bot:load()
	background:load()
	settings:load()
	timer_load()
	hats_load()
end

function love.update(dt)
	if menu.current_state == menu.states._menu then
		love.graphics.setBackgroundColor(79, 79, 79)
		menu:update(dt)
	end

	if menu.current_state == menu.states.bot then
		love.graphics.setBackgroundColor(255, 255, 152)
		player1:update(dt)
		bot:update(dt)
		background:update()
		timer_update(dt)
		foreground_main_u()
	end

	if menu.current_state == menu.states.player2 then
		love.graphics.setBackgroundColor(255, 255, 152)
		player1:update(dt)
		player2:update(dt)
		background:update()
		timer_update(dt)
		foreground_main_u()
	end

	if menu.current_state == menu.states.settings then
		love.graphics.setBackgroundColor(79, 79, 79)
		settings:update()
	end

end

function love.draw()
	if menu.current_state == menu.states._menu then
		menu:draw()
	end

	if menu.current_state == menu.states.bot then
		background:draw()
		player1:draw()
		bot:draw()
		timer_draw()
		foreground_main_d()
	end

	if menu.current_state == menu.states.player2 then
		background:draw()
		player1:draw()
		player2:draw()
		timer_draw()
		foreground_main_d()
	end

	if menu.current_state == menu.states.settings then
		settings:draw()
	end
		
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "m" then
		_mousebox.x = 0
		_mousebox.y = 0
		menu.current_state = menu.states._menu
		menu_reset()
	end

	player1:fireball_launch(key)
	player2:fireball_launch(key)
end

function love.keyreleased(key)
	anim_reset(key)
end