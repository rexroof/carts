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
    direction=-1,
    change_direction = function(seg)
      seg.direction=seg.direction*-1
    end,
    draw = function(seg)
      -- draw ourselves
      spr(seg.sprite,seg.x,seg.y)
      -- draw next segment
      if seg.next then
	seg.next:draw()
      end
      print(remainder,64,64)
    end,
    update = function(seg)
      -- update ourselves
      -- maybe if I'm moving down,
      -- if horizontal is % 8, move left/right?
      -- toggle left/right?
      --
      -- if moving horizontally, check if close to edges
      if seg.dx~=0 then
	  if seg.x>119 or seg.x<2 then
	    -- start moving down/vertically
	    seg.dx=0
	    seg.dy=seg.speed
	    seg:change_direction()  -- change direction when next moving horizontally
	  end
      end
      -- if moving vertically
      if seg.dy>0 then
	-- if my height is an even factor 8
	remainder=flr(seg.y)%8
	printh('debug: remainder='..remainder..' seg.y='..seg.y, 'worm.log')
        if seg.y>0 and (remainder == 0) then
	  -- switch direction to left/right
	  seg.dy=0
	  seg.dx=seg.speed*seg.direction
	  printh('updated motion: seg.dy='..seg.dy..' seg.dx='..seg.dx, 'worm.log')
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
