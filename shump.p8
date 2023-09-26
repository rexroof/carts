pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- main
function _init()
 cls(0)
 framecount=0
 blink_timer=0
 mode="start"
end

function _draw()
  if (mode == "game") draw_game()
  if (mode == "start") draw_start()
  if (mode == "over") draw_over()
end -- _draw

function _update()
  blink_timer += 1
  framecount += 1
  if (mode == "game") update_game()
  if (mode == "start") update_start()
  if (mode == "over") update_over()
end  -- end _update
-->8
-- tools

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

function startgame()
 mode="game"
 heart={ pix=14,x=1,y=1,show=0 }
 emptyheart={ pix=13,x=10,y=1,show=0 }
 ship={ pix=2,x=64,y=64,show=1,sx=0,sy=0 }
 bullet={ pix=16,x=64,y=-10,show=0,life=60,sx=0,sy=0 }
 flamespr=5
 muzzle=0
 score=flr(rnd(10000))
 stars=starfield()
 lifes=3
 maxlifes=4
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
 if (btnp(4) or btnp(5)) startgame()
end

function update_over()
 if (btnp(4) or btnp(5)) then
   -- mode="start"
   print("button press")
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

 if(ship.show == 1) then
  if(bullet.life > 0) then
   bullet.life-=1
   bullet.y-=1
  else
   bullet.life=60
   bullet.show=0
  end
 end

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

 if btnp(5) then
   bullet.show=1
   bullet.x=ship.x
   bullet.y=ship.y-3
   sfx(0)
   muzzle=5
   score+=1
 end

 ship.x=ship.x+ship.sx
 ship.y=ship.y+ship.sy

 bullet.y=bullet.y-4

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

 if(bullet.show == 1) spr(bullet.pix,bullet.x,bullet.y)
 if(ship.show == 1) spr(ship.pix,ship.x,ship.y)
 if(heart.show == 1) spr(heart.pix,heart.x,heart.y)
 if(emptyheart.show == 1) spr(emptyheart.pix,emptyheart.x,emptyheart.y)
 spr(flamespr,ship.x,ship.y+6)
 if(muzzle>0) circfill(ship.x+3,ship.y, muzzle, 7)

 print_center("score: "..score)

 for i=1,maxlifes do
   if (lifes>=i) then
     spr(heart.pix,i*9-9,1)
   else
     spr(emptyheart.pix,i*9-9,1)
   end
 end
end -- draw_game

function draw_start()
 cls(1)
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000009900000000000000000000009900000099000000000000000000000000000000000000000000000000000000000000000000000000000
00066600000002000009900000dddd00000000000009900000099000000000000000000000000000000000000000000000000000000000000000000000000000
0066006000222200009999000d1111d0000000000099990000999900000000000000000000000000000000000000000000000000000000000000000000000000
006060600c21212c00911900d3d3d3d3000880000091190000911900000000000000000000000000000000000000000000000000000000000000000000000000
00606060c0222220909999093d3d3d3d000880009099990990999090000000000000000000000000000000000000000000000000000000000000000000000000
00660060c0211120999999990d1111d0000000009999999999999990000000000000000000000000000000000000000000000000000000000000000000000000
00066600002222209990099900dddd00000000009990099999909990000000000000000000000000000000000000000000000000000000000000000000000000
00000000000c0c009880088900000000000000009880088998808890000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000e7501175016750197501c7501f7502275024750277502a7502c7502e7503175033750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
