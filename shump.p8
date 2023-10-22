pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- main

-- homework
  -- try adding explosions?
    -- sprite animation?
    -- circle fills?
    --  rectangle fills? :D
    -- pixel explosion based on enemy sprite?

-- todo
-- add enemy health
-- add bullet dmg
-- bullet hitbox
-- expand objects
-- add invulnerablity frames to ship
-- add bullet rate/timer to ship
-- some ships should have charge shots?


function _init()
 cls(0)
 framecount=0
 blink_timer=0
 mode="start"
end

function _draw()
  if (mode == "game") then draw_game()
  elseif (mode == "start") then draw_start()
  elseif (mode == "over") then draw_over()
  end
end -- _draw

function _update()
  blink_timer+=1
  framecount+=1
  if (mode == "game") then update_game()
  elseif (mode == "start") then update_start()
  elseif (mode == "over") then update_over()
  end
end  -- end _update
-->8
-- tools

function particle_age_red(age)
   local color=7
   local size=4
   if (age>5) then
     color=10
     size=3
   end
   if (age>10) then
     color=9
     size=2
   end
   if (age>15) then
     color=8
     size=1
   end
   if (age>20) then
     color=2
     size=1
   end
   if (age>25) then
     color=5
     size=1
   end

   return color, size
end

function particle_age_blue(age)
   local color=2
   local size=4
   if (age>5) then
     color=10
     size=3
   end
   if (age>10) then
     color=12
     size=2
   end
   if (age>15) then
     color=13
     size=1
   end
   if (age>20) then
     color=2
     size=1
   end
   if (age>25) then
     color=3
     size=1
   end

   return color, size
end

function new_wave(wave_size)
 for i=1,wave_size do
   local n = new_enemy()
   n.x = flr(rnd(12)*10)
   n.y = flr(rnd(5)*8)
   add(enemies,n)
 end
end

function collide(a,b)
 -- collision math
 if ((abs(a.x-b.x)>8) or (abs(a.y-b.y)>8)) then
  return false
 else
  return true
 end

 return false
end

function draw_junk(objs)
 for o in all (objs) do
   sprite=o.pix

   if (o.pal_shift != nil) then
    for i=1,15 do
     pal(i,(i+o.pal_shift))
    end
   end
   if (o.flash != nil) then
     if o.flash > 0 then
       -- manipulate pallete if we're flashing
       o.flash-=1
       -- change every color to white for flashing
       for i=1,15 do
        pal(i,7)
       end
     end
   end
   if (o.ani != nil) sprite+=o.ani
   spr(sprite, o.x, o.y)

   pal() -- reset pallete
 end
end

function new_enemy()
 local hp=rnd(8)+1

 return {
   x=60, y=5,  -- position
   pix=21, -- sprite id
   pal_shift=(hp-1), -- pallete shift based on hp
   ani=0,  -- animate sprites
   spd=1,  -- enemy speed
   hp=hp,   -- health
   flash=0 -- hurt flash?
   }
end

-- add 50 particle explosion
function blast(x,y,blue)
  blue = blue or false

  -- initial large circle
  add(particles, { x=x, y=y,
      sx=0,
      sy=0,
      blue=blue,
      age=0,
      size=10,
      maxage=0
      } )

  for i=1,50 do
    add(particles, { x=x, y=y,
        sx=(rnd()-0.5)*4,
        sy=(rnd()-0.5)*4,
        blue=blue,
        age=0,
        maxage=rnd(30)
        } )
  end
end

function new_explosion(x,y)
 return {
   x=x, y=y,  -- position
   age=1,
   sprites={64,66,68,70,72},
   ani=0,  -- animate sprites
   }
end

function print_center(string, y, color)
 print(string,64-#string*2,y,color)
end

function blink()
 local c={5,5,5,5,5,5,6,6,7,7,6,6,5,5}
 if (blink_timer>#c) blink_timer=1
 return c[blink_timer]
end

function starfield()
 field={}
 for i=1,50 do
      -- x, y, speed
   add(field, { flr(rnd(128)), flr(rnd(128)), rnd(2)+0.2 } )
 end
 return field
end

function game_start()
 framecount=0
 mode="game"
 heart={pix=14,x=1,y=1}
 emptyheart={pix=13,x=10,y=1}
 ship={ pix=2,x=64,y=64,sx=0,sy=0 }
 invuln=0
 flamespr=5
 muzzle=0
 score=flr(rnd(10000))
 stars=starfield()
 bullets={}
 bullet_timer=0
 lifes=4
 maxlifes=4
 enemies={}
 -- explosions={}
 particles={}
 -- multiple enemies? one after another over time? pattern?
 -- different types of enemies. new animation
 -- new property to enemies?  speed?  movement?

 wave_size=10
 new_wave(wave_size)
end

function animatestars(stars)
   for s in all (stars) do
     s[2]+=s[3]
     if (s[2]>127) s[2]-=127
   end
   return stars
end

function random_starstream()
 x=10
 y=10
 for i=1,100 do
   x+=rnd(10)
   y+=rnd(10)
   -- set one pixel
   pset(x,y,7)
 end
end

function update_start()
 if (btnp(4) or btnp(5)) game_start()
end

function update_over()
 if (btnp(4) and btnp(5)) then
   mode="start"
   -- print("button press")
 end
end

--8
function update_game()
 -- ship.x=ship.x + rnd(6) - 3
 -- ship.y=ship.y + rnd(6) - 3
 if(ship.x > 125) ship.x=120
 if(ship.y > 125) ship.y=120
 if(ship.x < 0) ship.x=1
 if(ship.y < 0) ship.y=1

 ship.sx=0
 ship.sy=0
 ship.pix=2

 if btn(0) then
   ship.sx=-2
   ship.pix=1
 end

 if btn(1) then
   ship.sx=2
   ship.pix=3
 end

 if btn(2) then
   ship.sy=-2
 end

 if btn(3) then
   ship.sy=2
 end

 if btnp(4) then
   mode="over"
 end

 -- if (btnp(5)) bullet_timer=0
 if btn(5) then
  if bullet_timer <= 0 then
   local newbullet={pix=16,x=ship.x,y=ship.y-3,life=60,sx=0,sy=0,spd=4 }
   add(bullets,newbullet)
   sfx(0)
   muzzle=5
   bullet_timer=4
  end
 end
 if (bullet_timer>0) bullet_timer-=1

 ship.x=ship.x+ship.sx
 ship.y=ship.y+ship.sy

 -- cycle through all bullets
 for b in all (bullets) do
  b.y=b.y-b.spd

  if b.y < -10 then
    del(bullets, b)
  end

  -- test if bullets have hit enemies
  for e in all (enemies) do
    -- if bullet hits enemy
    if (collide(b,e)) then
      del(bullets, b)  -- someday bullets may have health/peircing?
      e.hp-=1
      sfx(3)  -- hit sound
      e.flash=3
      -- if enemy is dying
      if e.hp <= 0 then
       -- add(explosions, new_explosion(e.x-4,e.y-4))
       blast(e.x+4,e.y+4)
       del(enemies, e)
       score+=15
       sfx(2) -- death sound
      end
    end
  end
 end

 -- cycle through all enemies
 for e in all (enemies) do
   e.y+=e.spd
   if (e.y > 130) e.y=-10
   e.ani+=0.2
   if e.ani > 3 then
     e.ani=0
   end

   -- decrement invulnerability
   if (invuln>0) invuln-=1

   -- if this enemy has hit ship
   if (invuln<=0) and (collide(ship,e)) then
     blast(ship.x,ship.y,true)  -- blue is true
     lifes-=1
     e.hp-=3

     -- repeated from above, need to refactor
     if e.hp <= 0 then
      -- add(explosions, new_explosion(e.x-4,e.y-4))
      blast(e.x+4,e.y+4)
      del(enemies, e)
      score+=15
      sfx(2) -- death sound
     end

     sfx(1)
     invuln=200  -- frames of invulnerability
   end
   if (lifes<=0) mode="over" -- this should be a function inside ship obj?
 end -- for e in enemies

 if (#enemies == 0) then
   wave_size+=10
   new_wave(wave_size)
 end

 flamespr=flamespr+1
 if (flamespr > 8) flamespr=5

 if(muzzle>0) muzzle=muzzle-1

 if (framecount % 5) then
   stars=animatestars(stars)
 end

end -- update_game

-->8
-- draw
function draw_game()
 cls(0)
 for s in all (stars) do
   -- default color is light grey
   local color=6

   -- somewhat slow stars are grey
   if (s[3] < 1.5) color=13
   -- slowest stars are dark blue
   if (s[3] < 1) color=1

   -- super fast stars are a streak
   if (s[3] > 1.9) then
    line(s[1],s[2],s[1],s[2]-4,color)
   -- fast-ish stars flicker
   elseif (s[3] > 1.5) then
    pset(s[1],s[2],rnd(3)+5)
   else
    pset(s[1],s[2],color)
   end
   -- pset(s[1],s[2], flr(rnd(3)+5) )
 end

 draw_junk(bullets)
 draw_junk(enemies)

 if (invuln<=0) then
  spr(ship.pix,ship.x,ship.y)
  spr(flamespr,ship.x,ship.y+6)
 else
  -- blink ship while invulnerable
  if sin(framecount/3)<0.5 then
   spr(ship.pix,ship.x,ship.y)
   spr(flamespr,ship.x,ship.y+6)
  end
 end

 if(muzzle>0) circfill(ship.x+3,ship.y, muzzle, 7)

 -- draw explosions
 -- for pop in all(explosions) do
 --   spr(pop.sprites[flr(pop.age)], pop.x, pop.y, 2, 2)
 --   pop.age+=0.4
 --   if (pop.age > #pop.sprites) del(explosions,pop)
 -- end

 -- draw particles
 for p in all(particles) do
   local pcolor=0
   local psize=0

   if (p.blue) then
     pcolor,psize=particle_age_blue(p.age)
   else
     pcolor,psize=particle_age_red(p.age)
   end
   circfill(p.x,p.y,psize,pcolor)

   -- this should probably be in update?
   p.x+=p.sx
   p.y+=p.sy
   p.age+=1
   if (p.age>p.maxage) del(particles,p)
 end

 for i=1,maxlifes do
   if (lifes>=i) then
     spr(heart.pix,i*9-9,1)
   else
     spr(emptyheart.pix,i*9-9,1)
   end
 end

 print_center("score: "..score, 1, 12)
 print(#enemies, 100,1,9)

end -- draw_game

function draw_start()
 cls(1)

 -- draw background pattern using sprite
 for x=1,127,8 do
   for y=1,127,8 do
    spr(42, x, y)
   end
 end

 print_center("rexroof games shump", 60, blink())
end

function draw_over()
 cls(1)
 print_center("game over", 60,8)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099009900990099000000000
00000000000cc000000cc000000cc000000000000ccaccc0000ca000000cc000000cc00000000000000000000000000000000000911991199999999900000000
0070070000c55c0000c55c0000c55c000000000000cccc00000cc000000cc0000007700000000000000000000000000000000000911111199999999900000000
000770000c495c000c5495c000c549c000000000007cc700000cc000000770000000000000000000000000000000000000000000911111199999999900000000
000770000c495c000c5495c000c549c00000000000077000000cc000000000000000000000000000000000000000000000000000091111900999999000000000
00700700c55555c0c555555c0c55555c000000000000000000077000000000000000000000000000000000000000000000000000009119000099990000000000
000000000ccaacc00ccaacc00ccaacc0000000000000000000000000000000000000000000000000000000000000000000000000000990000009900000000000
0000000000c00c0000c00c0000c00c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000033000033330000333300003300000000000000000088880000000000000b0000000000000000000000000000
000000000000000000000000000000000000000033b00b3333b00b3333b00b3300000000000000000868888000000000000bb000000000000000000000000000
00088000000000000000000000000000000000000b3bb3b00b3bb3b00b3bb3b00000000000000000888868880000000000bbbb00000000000000000000000000
00aaaa000000000000000000000000000000000000b33b0000b33b0000b33b000000000000000000886888680000303300bbbb00000000000000000000000000
00aaaa0000000000000000000000000000000000003bb300003bb300033bb330000000000000000088888888002223300bb44bb0000000000000000000000000
000aa00000000000000000000000000000000000007337000373373003733730000000000000000088686868222122300bb44bb0000000000000000000000000
00077000000000000000000000000000000000000070070000700700000000000000000000000000088888800222120000bbbb00000000000000000000000000
000660000000000000000000000000000000000000700700000000000000000000000000000000000088880000222000000bb000000000000000000000000000
00000000000000009880088900000000000000000009900000099000000000000000000000000000dddddddd0000000000000000000000000000000000000000
00066600000002009990099900dddd00000000000009900000099000000000000000000000000000dccddddd0000000000000000000000000000000000000000
0066006000222200999999990d1111d0000000000099990000999900000000000000000000000000dccddddd0000000000000000000000000000000000000000
006060600c21212c90999909d3d3d3d3000880000091190000911900000000000000000000000000dddddddd0000000000000000000000000000000000000000
00606060c0222220009119003d3d3d3d000880009099990990999090000000000000000000000000dddddddd0000000000000000000000000000000000000000
00660060c0211120009999000d1111d0000000009999999999999990000000000000000000000000dddddccd0000000000000000000000000000000000000000
00066600002222200009900000dddd00000000009990099999909990000000000000000000000000dddddccd0000000000000000000000000000000000000000
00000000000c0c000009900000000000000000009880088998808890000000000000000000000000dddddddd0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000550000000000005005000050005000005500000050000000000000000000000000000000000000000000000000
00000000000000000000000000000000000555525500550005555052555550005505555055005500000000000000000000000000000000000000000000000000
00000000000000000099999990990000055552222222225000005222222255000555500000055050000000000000000000000000000000000000000000000000
0000a0aa00aa0000009999aa99999000052528888888825505552222822225500505550000050055000000000000000000000000000000000000000000000000
000a7a77aa7a0000009a7a77aa7a9000055288898888882555522888882822550550055005550005000000000000000000000000000000000000000000000000
0000a777777a00000099aaaaa7aa9000052899999988882005282988898222250500005500000000000000000000000000000000000000000000000000000000
0000a7777777a0000009aaaaaaa7900055289aaaa989882505228808a08922205500000550005005000000000000000000000000000000000000000000000000
0000a777777a00000099aa777aa99000028899a777998825522288a00a8822200005500050005005000000000000000000000000000000000000000000000000
000a7777777a0000009aa77777a99000528889a77a998255028288a00a8882505005000000050055000000000000000000000000000000000000000000000000
000a77777777a000099aa77aaaa99000552889979998825005228908908222505500500000000050000000000000000000000000000000000000000000000000
000aa779777a0000099aaaaa7aaa9000555288999888255005528898888225055550550000500550000000000000000000000000000000000000000000000000
00000aa77777a00009999aaaaa999000005288888882500005028228822250000050055000505000000000000000000000000000000000000000000000000000
0000a0a00aa00000000999a999900000005528228225500055052822822505500055000000055500000000000000000000000000000000000000000000000000
00000000000000000000099999000000005522552550000000552255255000500555005505500500000000000000000000000000000000000000000000000000
00000000000000000000000000000000000550055000000000505505005500005505500550000550000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000550000550000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07077070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07067070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70667607000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06067070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06066060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06067070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06066060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70067007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000047500a7500d7501175013750157501775017750197501d7501e7502075022750247502771018000180001600016000160001600016000160001500015000150001c00021000260002d0003400039000
000100000000000000000002a1502435021150193501515014350101500b3500815007350061500615006150061500615006150081500b1500e15014150171501915000000000000000000000000000000000000
1a03000038650336500b6500a65033650336500b65008650056500465003650006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
5d040000273500a320080001d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000e7501175016750197501c7501f7502275024750277502a7502c7502e7503175033750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
