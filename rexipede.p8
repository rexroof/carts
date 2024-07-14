pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- rexipede
-- player starts in center bottom
-- can only move 5-6 steps up
-- centipede starts in top middle
-- ^- starts with 12 segments
-- can't move through mushrooms
-- spider spawns at edge
-- spider will eat mushrooms
-- when shot availbe red spot on tip of player
-- shot is approx 4 pixels, red
-- only one shot on screen at time
-- killing spider gets you higher score when closer
-- check wikipedia for more details
-- entire color palette shifts after clear
-- lives are ships next to score


function _init()
  cls(0)
  frames=0
  mushrooms=populate_mushrooms()
  player=new_player()
  dart=new_dart()
end

function _draw()
  cls(0)
  for m in all(mushrooms) do
    m:draw()
  end
  dart:draw()
  player:draw()
end

function _update()
 player.sx=0
 player.sy=0
 if (btn(0)) player.sx=-2
 if (btn(1)) player.sx=2
 if (btn(2)) player.sy=-2
 if (btn(3)) player.sy=2
 if (btn(4)) dart:fire()

 frames+=1
 player:update()
 dart:update()

 -- check every mushroom for dart collision
 if dart.docked == false then
   for m in all(mushrooms) do
     if touching(dart,m) then
       m:hit()
       dart:reload()
     end
   end
 end

end -- end _update

function new_dart() -- my projectile
 return {
   x=0, y=0, -- position
   sx=0, sy=0,  -- movement speed
   hitbox={x=0,y=0,h=1,w=1}, -- our hitbox
   docked=true,
   reload = function(self)
     self.docked=true
     self.x=player.x+3
     self.y=player.y-1
     self.sx=0
     self.sy=0
   end,
   fire = function(self)
     if (self.docked) then
       self.docked=false
       self.sy=-4
     end
   end,
   update = function(self)
     if (self.docked) then
       -- center and slightly higher than player ship
       self.x=player.x+3
       self.y=player.y-1
       self.sx=0
       self.sy=0
     end

     self.x+=self.sx
     self.y+=self.sy

     -- test if dart goes off screen, testing every direction for sanity's sake?
     if (self.x > 128) self:reload()  -- right side
     if (self.x < 0) self:reload()   -- left side
     if (self.y > 128) self:reload() -- lower bounds
     if (self.y < 0) self:reload()   -- upper bounds
   end, -- end mushroom:update()
   draw = function(self)
     line(self.x, self.y, self.x, self.y+4, 8) -- short red line
   end,
 }
end

function new_player()
 return {
   x=60, y=120, -- position
   hitbox={x=2,y=1,h=7,w=5}, -- our hitbox
   sx=0, sy=0,  -- movement speed
   -- maybe set a left/right/top/bottom edge value when x or y change?
   pix=1,
   update = function(self)
     self.x+=self.sx
     self.y+=self.sy

     for m in all(mushrooms) do
       -- if this causes us to touch a mushroom, revert change
       if touching(m,self) then
         self.x-=self.sx
         self.y-=self.sy
         break
       end
     end

     if (self.x > 121) self.x=121 -- right side
     if (self.x < 0) self.x=0     -- left side
     if (self.y > 120) self.y=120 -- lower bounds
     if (self.y < 80) self.y=80   -- upper bounds

   end,
   draw = function(self)
     spr(self.pix,self.x,self.y)
   end,
 }
end

function populate_mushrooms()
  field={}
  count=40
  -- done this way so as to test for overlapping mushrooms
  while (count > 0) do
    new = new_mushroom()
    any_touching=false
    for m in all(field) do
      if touching(new,m) then
        any_touching=true
      end
    end
    if (any_touching==false) then
      add(field, new)
      count-=1
    end
  end
  return field
end

function new_mushroom()
  return {
    x=flr(rnd(120)),
    y=flr(rnd(120)),
    hitbox={x=2,y=2,h=5,w=6}, -- our hitbox
    pix={2, 3, 4, 5},
    damage=1,
    draw = function(self)
      spr(self.pix[self.damage], self.x, self.y)
    end,
    hit = function(self)
      self.damage+=1
      if (self.damage > #self.pix) del(mushrooms, self)
    end,
  }
end

function new_segment() -- centipede body segment
  local seg={
    x=0,y=0, -- location
    sx=0, sy=0, -- movement speed
    hitbox={x=0,y=0,h=7,w=7}, -- our hitbox
    headpix={13,14}, -- sprites for head segments
    bodypix={15,16,17,18}, -- sprites for body segments
    add_segments=0, -- if we're still growing, how many more segments to add
    nextsegment=nil, -- link to our next body segment
  }
  return seg
end

function touching(a,b)
 if (not(a.hitbox)) stop("missing hitbox: a ")
 if (not(b.hitbox)) stop("missing hitbox: b ")

 atop = a.y+a.hitbox.y
 btop = b.y+b.hitbox.y
 abot = a.y+a.hitbox.y+a.hitbox.h
 bbot = b.y+b.hitbox.y+b.hitbox.h
 aleft = a.x+a.hitbox.x
 bleft = b.x+b.hitbox.x
 aright = a.x+a.hitbox.x+a.hitbox.w
 bright = b.x+b.hitbox.x+b.hitbox.w

 if (atop >= bbot) return false
 if (btop >= abot) return false

 if (aleft >= bright) return false
 if (bleft >= aright) return false

 return true
end

__gfx__
00000000000f0000008888000088880000888800008888000000f00000f00000000f0000000f0000000000000000000000000000000000000f00000000f00000
0000000000fff00008aaaa8008aaaa8008aaaa8008aaaa800000f00000f00000000f0000000f000000ff0000000ff0000fff0000000fff0000b8800000b88000
00700700088f88008aaaaaa88aaaaaa88aaaaaa88aa0aaa8000ff00b00ff000000f0f00b00f0f0000f00f00b00f00f00f000f00b00f000f00bb88b000bb88b00
00077000f88f88f08aaaaaa88aaaaaa88aaaaaa880a0a0a800f00f8b8f00f0000f000f8b8f000f00f0000f8b8f0000f000000f8b8f000000bbbbbb00bbbbbb00
00077000fffffff0888888888088888880808088000000000f00088b88000f00f00f088b880f00f00000088b880000000000088b88000000bbbbbb00bbbbbb00
007007000fffff00008aa800008aa8000080000000000000f00f0bbbbb0f00f0000f0bbbbb0f000000ff0bbbbb0ff0000fff0bbbbb0fff000bb88b000bb88b00
0000000000fff000008aa800000a00000000000000000000000ffbb8bbff000000f0fbb88bf0f0000f00fb888bf00f00f000fb88bbf000f000b8800000b88000
0000000000fff0000088880000000000000000000000000000f000b8b000f0000f0000b8b0000f00f00000b8b00000f0000000b8b00000000f00000000f00000
0f00000000f00000000f00000000f000007770007777770000777700777770007777777077777770007777707700077007777770000007707700077077000000
00bbb00000bbb00000bbb00000bbb000077077007700077007700770770077007700000077000000077000007700077000077000000007707700770077000000
0bbbbb000bbbbb000bbbbb000bbbbb00770007707700077077000000770007707700000077000000770000007700077000077000000007707707700077000000
bbbbbb00bbbbbb00bbbbbb00bbbbbb00770007707777770077000000770007707777770077777700770077707777777000077000000007707777000077000000
bbbbbb00bbbbbb00bbbbbb00bbbbbb00777777707700077077000000770007707700000077000000770007707700077000077000000007707777700077000000
0bbbbb000bbbbb000bbbbb000bbbbb00770007707700077007700770770077007700000077000000077007707700077000077000770007707707770077000000
00bbb00000bbb00000bbb00000bbb000770007707777770000777700777770007777777077000000007777707700077007777770077777007700777077777770
0f00000000f00000000f00000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000770770007700777770077777700077777007777770007777000077777707700077077000770770007707700077007700770777777700007700007777700
77707770777007707700077077000770770007707700077077007700000770007700077077000770770007707770777007700770000077700077700077000770
77777770777707707700077077000770770007707700077077000000000770007700077077000770770707700777770007700770000777000007700000007770
77777770777777707700077077000770770007707700777007777700000770007700077077707770777777700077700000777700007770000007700000777700
77070770770777707700077077777700770777707777700000000770000770007700077007777700777777700777770000077000077700000007700007777000
77000770770077707700077077000000770077007707770077000770000770007700077000777000777077707770777000077000777000000007700077700000
77000770770007700777770077000000077770707700777007777700000770000777770000070000770007707700077000077000777777700777777077777770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770000777007777770000777700777777700777700007777700007770000077770000000000000000000000000000000000000000000000000000000000
00007700007777007700000007700000770007707700070077000770070077000708907000000000000000000000000000000000000000000000000000000000
00077000077077007777770077000000000077007770070077000770770007707090080700000000000000000000000000000000000000000000000000000000
00777700770077000000077077777700000770000777700007777770770007707080000700000000000000000000000000000000000000000000000000000000
00000770777777700000077077000770007700007007777000000770770007707090000700000000000000000000000000000000000000000000000000000000
77000770000077007700077077000770007700007000077000007700077007007080090700000000000000000000000000000000000000000000000000000000
07777700000077000777770007777700007700000777770007777000007770000709807000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000077770000000000000000000000000000000000000000000000000000000000