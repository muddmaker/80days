require 'tween'

function love.load()
	love.graphics.setFont(love.graphics.newFont(20))
	
	map = love.graphics.newImage 'map.png'
	current = 1
	previous = 1
	debug = false
	camx = tween(1020, 0.4)
	camy = tween(215, 0.4)

	places = {
		{1020,	215,	'London',		tween(1, 0.4)},
		{1210,	340,	'Suez',			tween(0, 0.4)},
		{1440,	400,	'Bombay',		tween(0, 0.4)},
		{1520,	375,	'Calcutta',		tween(0, 0.4)},
		{1670,	385,	'Hong Kong',		tween(0, 0.4)},
		{1820,	310,	'Yokohama',		tween(0, 0.4)},
		{2375,	300,	'San Fransisco',	tween(0, 0.4)},
		{2650,	280,	'New York',		tween(0, 0.4)},
		{3070,	215,	'London',		tween(0, 0.4)}
	}

	paths = {
		newCurve(1020, 215, 1060, 270, 1130, 260, 1135, 330, 1210, 340),
		newCurve(1210, 340, 1240, 450, 1275, 450, 1440, 400),
		newCurve(1440, 400, 1469, 339, 1520, 375),
		newCurve(1520, 375, 1580, 550, 1670, 550, 1670, 385),
		newCurve(1670, 385, 1780, 420, 1820, 310),
		newCurve(1820, 310, 2375, 300),
		newCurve(2375, 300, 2400, 250, 2500, 300, 2650, 280),
		newCurve(2650, 280, 3070, 215)
	}

	quotes = {
		"So clean, well-arranged, solemn a mansion pleased him; it seemed to him like a snail's shell, lighted and warmed by gas, which sufficed for both these purposes. (Page 11)",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		""
	}
end

function love.update(dt)
	updateTweens(dt)
end

function love.draw()
	love.graphics.push()
	love.graphics.translate(love.window.getWidth() / 2 - camx.value, love.window.getHeight() / 4 - camy.value)
	
	love.graphics.draw(map)
	love.graphics.draw(map, map:getWidth())

	for i, k in ipairs(places) do
		if i > current then
			break
		end

		love.graphics.setColor(255, 0, 0, 127)
		love.graphics.setLineWidth(3)

		if i < previous then
			-- lines that we are not currently on
			love.graphics.line(paths[i])
		elseif i == current then
			-- line that we are currently on
			renderPathTo(paths[previous], current == previous and camx:getPercentage() or 1 - camx:getPercentage())
		end

		love.graphics.setLineWidth(1)
		love.graphics.setColor(255, 0, 0, k[4].value * 255)
		love.graphics.circle('fill', k[1], k[2], k[4].value * 10)
		love.graphics.setColor(2, 2, 2, k[4].value * 255)
		love.graphics.circle('line', k[1], k[2], k[4].value * 10, 15)
		love.graphics.setColor(255, 255, 230, k[4].value * 255)
		roundedRectangle(k[1] + 15, k[2] - 16, #k[3] * 15, 32, 10, {2, 2, 2, k[4].value * 255}, camx.value - love.graphics.getWidth() / 2, camy.value - love.graphics.getHeight() / 4)
		love.graphics.setColor(0, 0, 0, k[4].value * 255)
		love.graphics.printf(k[3], k[1] + 21, k[2] - 10, #k[3] * 13, 'center')
		love.graphics.setColor(255, 255, 255, 255)
	end

	love.graphics.pop()

	if debug then
		roundedRectangle(4, 4, 56, 46, 10, {2, 2, 2, 255})
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print(math.floor(camx.value - love.graphics.getWidth() / 2 + love.mouse.getX()), 6, 6)
		love.graphics.print(math.floor(camy.value - love.graphics.getHeight() / 4 + love.mouse.getY()), 6, 26)
		love.graphics.setColor(255, 255, 255, 255)
	end
end	

function love.keypressed(k)
	if not camx.moving then
		if k == 'left' and current > 1 then
			places[current][4]:start(0)
			current = current - 1
			previous = current
			camx:start(places[current][1])
			camy:start(places[current][2])
			places[current][4]:start(1)
		end

		if k == 'right' and current < #places then
			places[current][4]:start(0)
			previous = current
			current = current + 1
			camx:start(places[current][1])
			camy:start(places[current][2])
			places[current][4]:start(1)
		end
	end

	if k == 'escape' then
		love.event.quit()
	end

	if k == '`' then
		debug = not debug
	end
end

function newCurve(...)
	return love.math.newBezierCurve(...):render()
end

function renderPathTo(path, tf)
	accuracy = accuracy or 5
	local length = #path / 2
	local lastInt = math.floor(tf * length) * 2
	local newPath = {}

	if lastInt > 1 and lastInt < math.huge then
		for i = 1, lastInt, 2 do
			newPath[#newPath + 1] = path[i]
			newPath[#newPath + 1] = path[i + 1]
		end

		if #newPath > 2 then
			love.graphics.line(newPath)
		end
	end
end

function roundedRectangle(x, y, w, h, r, border, xoff, yoff)
	local camXOff = xoff or 0
	local camYOff = yoff or 0
	local color = {love.graphics.getColor()}
	love.graphics.rectangle('fill', x + r, y, w - 2 * r, h)
	love.graphics.rectangle('fill', x, y + r, r, h - 2 * r)
	love.graphics.rectangle('fill', x + w - r, y + r, r, h - 2 * r)
	love.graphics.setColor(border)
	love.graphics.line(x, y + r, x, y + h - r)
	love.graphics.line(x + r, y, x + w - r, y)
	love.graphics.line(x + w, y + r, x + w, y + h - r)
	love.graphics.line(x + r, y + h, x + w - r, y + h)
	love.graphics.setColor(color)
	love.graphics.setScissor(x - camXOff, y - camYOff, r, r)
		love.graphics.circle('fill', x + r, y + r, r)
		love.graphics.setColor(border)
		love.graphics.circle('line', x + r, y + r, r, 15)
		love.graphics.setColor(color)
	love.graphics.setScissor(x + w - r - camXOff, y - camYOff, r, r)
		love.graphics.circle('fill', x + w - r, y + r, r)
		love.graphics.setColor(border)
		love.graphics.circle('line', x + w - r, y + r, r, 15)
		love.graphics.setColor(color)
	love.graphics.setScissor(x - camXOff, y + h - r - camYOff, r, r)
		love.graphics.circle('fill', x + r, y + h - r, r)
		love.graphics.setColor(border)
		love.graphics.circle('line', x + r, y + h - r, r, 15)
		love.graphics.setColor(color)
	love.graphics.setScissor(x + w - r - camXOff, y + h - r - camYOff, r, r)
		love.graphics.circle('fill', x + w - r, y + h - r, r)
		love.graphics.setColor(border)
		love.graphics.circle('line', x + w - r, y + h - r, r, 15)
		love.graphics.setColor(color)
	love.graphics.setScissor()
end
