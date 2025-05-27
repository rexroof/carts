pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- worm experiment

function _init()
  cls(0)

  worm = new_segment(10)
end

function _draw()
  cls(0)
  worm:draw()
end

function _update()
  worm:update()
end

-- create centipede body segment
-- count is number of segments after us
-- input is an object full of presets
function new_segment(count, input)
  -- initialize in top middle of screen, just off screen
  local segment={
    x=60, y=-1,  -- current left, down location
    dx=0, dy=0.7, -- speed
    speed=0.7,  -- default speed
    sprite=1,
    draw = function(seg)
      -- draw ourselves
      spr(seg.sprite,seg.x,seg.y)
      -- draw next segment
      if seg.next then
	seg.next:draw()
      end
    end,
    update = function(seg)
      -- update ourselves
      -- maybe if I'm moving down,
      -- if horizontal is % 8, move left/right?
      -- toggle left/right?
      if seg.dy > 0 then
	-- if my height is an even factor of my width
        if seg.y>0 and (flr(seg.y) % 8 == 0) then
	  seg.dy=0
	  seg.dx=-seg.speed
	end
      end
      seg.x+=seg.dx
      seg.y+=seg.dy
      -- update next segment
      if seg.next then
	seg.next:update()
      end
    end,
    next = nil  -- next segment
  }

  -- copy input table over presets
  if input then
      for k,v in pairs(input) do
	segment[k]=v
      end
  end

  if count > 0 then
    count-=1
    segment.next=new_segment(count, {x=segment.x, y=segment.y-7})
  end

  return segment
end



__gfx__
0000000000bbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000bbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700bbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000bbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000bbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700bbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000bbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000bbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
