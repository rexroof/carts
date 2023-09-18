pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
 cls(6)
 coin={ pix=1,x=1,y=1,show=0 }
 err={ pix=2,x=1,y=1,show=0 }
 ship={ pix=3,x=1,y=1,show=0 }
 enemy={ pix=4,x=1,y=1,show=0 }
 bullet={ pix=5,x=1,y=1,show=0 }

 add=1
 err.x=40
 err.y=64
 err.show=1
 ship.show=1
 ship.x=50
 ship.y=50
 coin.show=1
 enemy.show=1
 enemy.x=120
 distance=0
end

function _draw()
 cls(6)
 -- spr(ship.pix,ship.w,ship.h)
 if(coin.show == 1) spr(coin.pix,coin.x,coin.y)
 if(err.show == 1) spr(err.pix,err.x,err.y)
 if(bullet.show == 1) spr(bullet.pix,bullet.x,bullet.y)
 if(ship.show == 1) spr(ship.pix,ship.x,ship.y)
 if(enemy.show == 1) spr(enemy.pix,enemy.x,enemy.y)
end

function _update()
 ship.x=ship.x + rnd(6) - 3
 ship.y=ship.y + rnd(6) - 3
 if(ship.x > 125)ship.x=120
 if(ship.y > 125)ship.y=120
 if(ship.x < 0)ship.x=1
 if(ship.y < 0)ship.y=1

 if (err.x > 123) then
  err.x=123
  add=0
 end

 if (err.x < 0) then
  err.x=0
  add=1
 end

 if(ship.show == 1) then
  if (bullet.show == 0) then
   bullet.show=1
   bullet.x=ship.x
  end

  if(distance > 100) then
   distance=1
   bullet.show = 0
  end

  distance+=1
  bullet.y=ship.y-distance
 end

 if btn(0) then
    err.x=err.x-1
 end

 if btn(1) then
    err.x=err.x+1
 end

 if btn(2) then
    err.y=err.y-1
 end

 if btn(3) then
    err.y=err.y+1
 end

 -- dvd logo?  calculate slope?
 -- edge of screen wrap around.   display ship on both sides of the screen for a second?

end
__gfx__
00000000000000000000000000099000000000000000000000000660000000000000000000000000000000000000000000000000000000000000000000000000
0000000000066600000002000009900000dddd000000000000066660000000000000000000000000000000000000000000000000000000000000000000000000
007007000066006000222200009999000d1111d00008800000066666000000000000000000000000000000000000000000000000000000000000000000000000
00077000006060600c21212c00911900d3d3d3d300aaaa0000666666000000000000000000000000000000000000000000000000000000000000000000000000
0007700000606060c0222220909999093d3d3d3d00aaaa0006666666000000000000000000000000000000000000000000000000000000000000000000000000
0070070000660060c0211120999999990d1111d0000aa00066666666000000000000000000000000000000000000000000000000000000000000000000000000
0000000000066600002222209990099900dddd000007700066666666000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000c0c0098800889000000000006600066666666000000000000000000000000000000000000000000000000000000000000000000000000
