pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- main
--
-- blocked logic is broken
-- add generic update function to all sprites?
--   -- generic sprite prototype for all sprites?
-- flash enemies when they fire, or muzzle flash?
-- add sound effect for firing enemy bullet
-- add logic where some enemies fire occasionally instead of attack
--   - attack can be fire or fly down.  random calculation added to enemy object
--  draw new bullets
--  sound effects for each bullet?
--
-- review hitboxes
--
function _init()
 cls(0)
 t=0
 blink_timer=0
 mode="start"
 lockout=0  -- button lockout
end

function _draw()
 if (mode == "game") then draw_game()
 elseif (mode == "start") then draw_start()
 elseif (mode == "wavetext") then draw_wavetext()
 elseif (mode == "over") then draw_over()
 elseif (mode == "win") then draw_win()
 end
end -- _draw

function _update()
 blink_timer+=1
 t+=1
 if (mode == "game") then update_game()
 elseif (mode == "start") then update_start()
 elseif (mode == "wavetext") then update_wavetext()
 elseif (mode == "over") then update_over()
 elseif (mode == "win") then update_win()
 end
end  -- end _update
-->8
-- tools

-- blue or red particle colors, fizzing out with age
function particle_age(age, blue)
 local colors={
  red={ 7,10, 9,8, 2,5},
  blue={7, 6,12,3,13,1},
 }
 local set=colors.red
 if (blue) set=colors.blue
 local color=set[0]
 local size=4

 if (age>5) then
  color=set[1]
  size=3
 end
 if (age>10) then
  color=set[2]
  size=2
 end
 if (age>15) then
  color=set[3]
  size=1
 end
 if (age>20) then
  color=set[4]
  size=1
 end
 if (age>25) then
  color=set[5]
  size=1
 end

 return color,size
end

-- add a shockwave to array at position
function small_shockwave(x,y)
 add(shockwaves,{
  x=x, y=y, r=2, maxr=4, color=9, speed=1
 })
end

-- add a large shockwave to array at position
function big_shockwave(x,y)
 add(shockwaves,{
  x=x, y=y, r=3, maxr=30, color=7, speed=3
 })
end

-- a couple sparks when we hit enemies
function small_sparks(x,y)
 for i=1,rnd(3) do
  add(particles, {
   x=x, y=y,
   sx=(rnd()-0.5)*8,
   sy=(rnd()-1)*3, -- flying backwards (upwards)
   blue=blue,
   age=0,
   spark=true,
   maxage=rnd(30)
  } )
 end
end

-- create new enemies from wave table
function new_wave(incomingwave)
 local x=6
 local y=20
 local spec=incomingwave.patterns
 for row in all(spec) do
  for en in all(row) do
   if (en != 0) then
    en.x=x
    en.y=y
    en.wait=(x/4)
    local e = new_enemy(en)
    add(enemies, e)
   end
   x+=11
  end
  y+=10
  x=7
 end
end

-- return true if two objects have collided
function collide(a,b)
 -- hitbox defaults to 7x7, starting at origin
 -- if (not(a.hitbox)) a.hitbox={x=0,y=0h=7,w=7}
 -- if (not(b.hitbox)) b.hitbox={x=0,y=0h=7,w=7}
 if (not(a.hitbox)) stop("missing hitbox: a ")
 if (not(b.hitbox)) stop("missing hitbox: b ")
 --
 -- if a top > b bottom
 if (a.y+a.hitbox.y > b.y+b.hitbox.w-1) return false
 -- if b top > a bottom
 if (b.y+b.hitbox.y > a.y+a.hitbox.h-1) return false
 -- if a left > b right
 if (a.x+a.hitbox.x > b.x+b.hitbox.w-1) return false
 -- if b left > a right
 if (b.x+b.hitbox.x > a.x+a.hitbox.w-1) return false
 return true
end

-- generic sprite draw function
function draw_junk(objs)
 for o in all(objs) do
  local tmpx,tmpy = o.x,o.y
  local height=o.h or 1 -- for wider/taller sprites
  local width=o.w or 1  -- for wider/taller sprites
  if (o.pal_shift != nil) then
   for i=1,15 do
    pal(i,(i+o.pal_shift))
   end
  end
  if (o.shake != nil) and (o.shake>0) then
   o.shake-=1
   if (t%4<2) tmpx+=1
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
  -- o.ani tracks which frame of the sprite animation we're on
  if (not(o.ani)) o.ani=1
  spr(o.pix[flr(o.ani)], tmpx, tmpy, height, width)
  pal() -- reset pallete
 end
end

-- draw particles
function draw_particles(ptable)
 for p in all(ptable) do
   local pcolor=0
   local psize=0
   pcolor,psize=particle_age(p.age, p.blue)

   if p.spark then
    pset(p.x,p.y,7) -- sparks always white
   else
    circfill(p.x,p.y,psize,pcolor)
   end
   -- this should probably be in update?
   p.x+=p.sx
   p.y+=p.sy
   p.age+=1
   if (p.age>p.maxage) del(ptable,p)
 end
end -- end draw_particles

-- generate a new bullet and add it to bullets table
function fire_bullet(input)
 local spec = {
   pix={113,114,115},
   hitbox={x=2,y=2,h=2,w=2},
   x=0,
   y=0,
   sx=0,sy=0,spd=6,
   ani=1,
   ani_speed=0.4
 }
 -- override spec with object passed in
 for k,v in pairs(input) do
   spec[k]=v
 end
 add(enemy_bullets, spec)
end -- end fire_bullet

-- generate a new enemy and return a table of it
function new_enemy(input)
 local presets = {
   x=0, y=0,         -- position
   pix={21,22,23},   -- sprite ids for animation
   h=1,w=1,          -- height and width of sprites
   ani=1,            -- animation frame of sprites
   ani_speed=0.3,    -- animation speed
   spd=1,            -- enemy speed
   pal_shift=0,
   sx=0,sy=0,        -- x&y speed
   hp=rnd(3)+1,      -- health
   wait=0,
   mission="flyin",  -- initial state
   shake=0,          -- we shake before an attack
   flash=0,          -- if we're flashing after hit
   takehit = function(self) -- take damage
   end,
   kill = function(self)
    -- kill steps
    blast(self.x+4,self.y+4) -- should become new explosion method
    -- add(explosions, new_explosion(e.x-4,e.y-4))
    score+=15 -- todo: make this variable
    sfx(2) -- death sound
    if (self.mission == "attack") enemy_attack() -- trigger new attack if i was attacking
    del(enemies, self) -- remove me from enemies list
   end
 }
 -- override all presets with object that was passed in
 for k,v in pairs(input) do
   presets[k]=v
 end
 -- presets.pal_shift=(presets.hp-1)  -- pallete shift based on hp
 -- set target position to original x & y + random jank
 presets.target={
   x = presets.x+(rnd()-0.5)*3,
   y = presets.y+(rnd()-0.5)*3,
  }
 -- move current position way off the upper screen
 presets.y-=flr(rnd(40))+50
 -- presets.x=flr(rnd(200))
 presets.x=64
 return presets
end -- end new_enemy

-- enemy update function for when on mission
function enemy_mission(e)
 -- don't do anything unless in game mode
 if (mode != "game") return
 -- don't do anything if we're waiting
 if (e.wait>0) then
  e.wait-=1
  return
 end

 if e.mission == "flyin" then
   -- e.y+=e.sy
   -- e.x+=e.sx
   -- simple easing function
   local n = (rnd(3)+10)
   e.y+=(e.target.y-e.y)/n
   e.x+=(e.target.x-e.x)/n
   -- e.y+=rnd(2)+1
   if (e.y>=(e.target.y-1)) and (e.x>=(e.target.x-1)) then
     -- snap to your actual position
     e.y = e.target.y
     e.x = e.target.x
     e:set_mission("chill")
   end
 elseif e.mission == "attack" then
   e:attack()
   move_sprite(e)
 elseif e.mission == "chill" then
  -- should we try blocking hits to an above enemy?
  return
 end
end  -- end enemy_mission

-- move a sprite on screen using speeds in object
function move_sprite(obj)
  obj.x+=obj.sx
  obj.y+=obj.sy
end

-- check if there are enemies blocking below
function blocked(e)
  local blocked=false
  -- make copy of enemy to test
  local ecopy={x=e.x,y=e.y}
  e.pal_shift+=1
  -- set default hitbox, used for stepping down screen
  if (not(e.hitbox)) then
   ecopy.hitbox={x=0,y=0,h=8,w=8}
  else
   ecopy.hitbox={x=e.hitbox.x,y=e.hitbox.y,h=e.hitbox.h,w=e.hitbox.w}
  end
  -- move down by hitbox steps until off screen
  while (ecopy.y < 128) do
   ecopy.y+=(ecopy.hitbox.h+ecopy.hitbox.y)
   for b in all(enemies) do
    -- if we would hit another enemy, we are blocked
    if (collide(ecopy,b)) blocked=true
   end
  end
  -- true/false if blocked
  return blocked
end

-- pick an enemy and attack
function enemy_attack()
  -- don't do anything if not in game mode
  if (mode != "game") return
  -- if no enemies, return
  if (#enemies == 0) return
  -- grab random enemy
  e=rnd(enemies)
  -- only chilling enemies can attack
  if (e.mission == "chill") then
   if (not blocked(e)) then
    e:set_mission("attack")
   end
  end
  return
end -- enemy attack, picking function

-- add 50 particle explosion
function blast(x,y,blue)
  blue = blue or false

  -- initial large circle
    -- doesn't work in my version
  add(particles, { x=x, y=y,
      sx=0,
      sy=0,
      blue=blue,
      age=0,
      size=10,
      maxage=0
      } )

  -- circles for explosion
  for i=1,40 do
    add(particles, { x=x, y=y,
        sx=(rnd()-0.5)*4,
        sy=(rnd()-0.5)*4,
        blue=blue,
        age=0,
        maxage=rnd(30)
        } )
  end

  -- these are sparks
  for i=1,40 do
    add(particles, { x=x, y=y,
        sx=(rnd()-0.5)*6,
        sy=(rnd()-0.5)*6,
        blue=blue,
        age=0,
        spark=true,
        maxage=rnd(30)
        } )
  end

  big_shockwave(x,y)
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
 t=0
 mode="wavetext"
 wavetime=60
 wave=1

 enemy_types={
  fly={
   pix={21,22,23},
   hitbox={x=1,y=1,h=6,w=8},
   hp=1,
   sy=1.7,
   set_mission = function(self, new)
     self.mission = new
     if ( new == "attack" ) then
       self.ani_speed*=2
       self.shake=40
       self.wait=self.shake
       fire_bullet({x=self.x+3, y=self.y+5, sy=2})
     end
   end,
   attack = function(self)
     self.sx=sin(t/45)
     -- make enemies trend towards center of screen
     if (self.x<32) self.sx+=1-(self.x/32)
     if (self.x>88) self.sx-=(self.x-88)/32
   end,
  },
  mushroom={
   pix={48,49,50,51},
   hitbox={x=1,y=1,h=6,w=6},
   hp=2,
   sy=2.5,
   set_mission = function(self, new)
     self.mission = new
     if ( new == "attack" ) then
       self.ani_speed*=2
       self.shake=40
       self.wait=self.shake
     end
   end,
   attack = function(self)
     self.sx=sin(t/20)
     -- make enemies trend towards center of screen
     if (self.x<32) self.sx+=1-(self.x/32)
     if (self.x>88) self.sx-=(self.x-88)/32
   end,
  },
  blade={
   pix={52,53,54,55},
   hitbox={x=1,y=0,h=8,w=8},
   hp=3,
   sy=2.1,
   set_mission = function(self, new)
     self.mission = new
     if ( new == "attack" ) then
       self.ani_speed*=2
       self.shake=25
       self.wait=self.shake
     end
   end,
   attack = function(self)
    -- fly down until at ship, then towards ship
    if self.sx == 0 then
     -- if we are lower than ship
     if ship.y<=self.y then
      self.sy=0
      if ship.x < self.x then
       self.sx=-2.1
      else
       self.sx=2.1
      end
     end
    end
   end,
  },
  bubble={
   pix={56,57,58,59},
   hitbox={x=0,y=0,h=8,w=8},
   hp=6,
   sy=0.9,
   set_mission = function(self, new)
     self.mission = new
     if ( new == "attack" ) then
       self.ani_speed*=2
       self.shake=40
       self.wait=self.shake
     end
   end,
   attack = function(self)
     self.sy = 0.35
     self.sx=sin(t/120)
     -- make enemies trend towards center of screen
     if (self.x<32) self.sx+=1-(self.x/32)
     if (self.x>88) self.sx-=(self.x-88)/32
   end,
  },
  ignokt={
   pix={46,44},
   h=2, w=2,
   hitbox={x=1,y=5,h=12,w=10},
   hp=15,
   ani_speed=0.1,
   pal_shift=0,
   sy=0.35,
   set_mission = function(self, new)
     self.mission = new
     if ( new == "attack" ) then
       self.ani_speed*=2
       self.shake=100
       self.wait=self.shake
     end
   end,
   attack = function(self)
     if (self.y>110) then
      self.sy=1
     end
   end,
  }
 }

 local f=enemy_types.fly
 local m=enemy_types.mushroom
 local d=enemy_types.blade
 local b=enemy_types.bubble
 local i=enemy_types.ignokt

 waves={
  -- wave one
  { attack_speed=90,
    patterns={
     {f, f, f, f, f, f, f, f, f, f, f},
     {f, f, f, f, f, f, f, f, f, f, f},
     {f, f, f, f, f, f, f, f, f, f, f}
    },
  },

 -- wave two
 { attack_speed=75,
 patterns={
  {m, m, 0, 0, f, f, f, 0, 0, f, m},
  {m, m, 0, 0, m, m, m, 0, 0, f, m},
  {m, m, 0, 0, f, f, f, 0, 0, f, m},
 },
},

-- wave three
{ attack_speed=55,
patterns={
 {d, d, d, d, d, d, d, d, d, d, d},
 {m, m, m, 0, 0, 0, 0, 0, m, m, m},
 {m, m, m, 0, 0, 0, 0, 0, m, m, m},
},
   },

   -- wave four
   { attack_speed=30,
   patterns={
    {b, b, b, b, 0, 0, 0, b, b, b, b},
    {b, 0, b, 0, b, 0, b, 0, b, 0, b},
    {0, b, 0, b, 0, b, 0, b, 0, b, 0},
   },
  },

  -- wave five
  { attack_speed=20,
  patterns={
   {0, 0, 0, 0, 0, i, 0, 0, 0, 0, 0},
   {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
   {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  },
 },

 }

 heart={pix=14,x=1,y=1}
 emptyheart={pix=13,x=10,y=1}
 ship={
   pix=2,
   x=64,y=84,
   hitbox={
     x=2,y=3,
     h=3,w=4
   },
   sx=0,sy=0,
   firing_speed=8,
   takehit = function(self)
     -- if we are invulnerable, skip
     if (self.invuln > 0) return false
     blast(self.x,self.y,true)  -- create explosion, blue is true
     lifes-=1
     sfx(1)
     self.invuln=200 -- make me invulnerable
     return true
   end
 }
 invuln=0
 flamespr=5
 muzzle=0
 score=flr(rnd(10000))
 stars=starfield()
 bullets={}
 enemy_bullets={}
 bullet_timer=0
 lifes=4
 maxlifes=4
 enemies={}
 -- explosions={}
 particles={}
 shockwaves={}

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
 -- make sure we have released the buttons so we see the screen
 if btn(4)==false and btn(5)==false then
   buttonrelease=true
 end

 if buttonrelease then
   if btnp(4) or btnp(5) then
     game_start()
     buttonrelease=false
   end
 end
end

function update_over()

 -- don't do anything until lockout is over
 if t < lockout then
   return
 else
   lockout=0
 end

 -- make sure we have released the buttons so we see the screen
 if btn(4)==false and btn(5)==false then
   buttonrelease=true
 end

 if buttonrelease then
   if btnp(4) or btnp(5) then
     mode="start"
     buttonrelease=false
     lockout=0
   end
 end
end

function update_win()

 -- don't do anything until lockout is over
 if t < lockout then
   return
 else
   lockout=0
 end

 -- make sure we have released the buttons so we see the screen
 if btn(4)==false and btn(5)==false then
   buttonrelease=true
 end

 if buttonrelease then
   if btnp(4) or btnp(5) then
     mode="start"
     buttonrelease=false
   end
 end
end

function update_wavetext()
 update_game()
 wavetime-=1
 if wavetime <= 0 then
   mode="game"
   new_wave(waves[wave])
 end
end

--8
function update_game()
 -- ship.x=ship.x + rnd(6) - 3
 -- ship.y=ship.y + rnd(6) - 3

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

 if (btn(2)) ship.sy=-2
 if (btn(3)) ship.sy=2

 if btnp(4) then
  -- this doesn't do anything yet
 end

 -- shoot a bullet!
 if btn(5) then
  if bullet_timer <= 0 then
   local newbullet={pix={17},hitbox={x=0,y=0,h=4,w=4},
                     x=ship.x+2,y=ship.y-1,
                     sx=0,sy=0,spd=4,
                     ani=1,ani_speed=0}
   add(bullets,newbullet)
   sfx(0)
   muzzle=5
   bullet_timer=ship.firing_speed
  end
 end
 if (bullet_timer>0) bullet_timer-=1

 ship.x=ship.x+ship.sx
 ship.y=ship.y+ship.sy

 if(ship.x > 120) ship.x=120
 if(ship.y > 120) ship.y=120
 if(ship.x < 0) ship.x=1
 if(ship.y < 0) ship.y=1

 -- cycle through all bullets
 for b in all (bullets) do
  b.y=b.y-b.spd

  b.ani+=b.ani_speed
  if (flr(b.ani) > #b.pix)  then
    b.ani=1
  end

  if b.y < -10 then
    del(bullets, b)
  end

  -- test if bullets have hit enemies
  for e in all (enemies) do
    -- if bullet hits enemy
    if (collide(b,e) and e:takehit()) then -- takehit returns true if took damage
      small_shockwave(b.x,b.y)
      small_sparks(e.x+4,e.y+7)
      del(bullets, b)  -- someday bullets may have health/peircing?
      e.hp-=1
      sfx(3)  -- hit sound
      e.flash=3
      -- if enemy is dying
      if e.hp <= 0 then
       e:kill()
      end
    end
  end -- end for e in all enemies

 end -- end for b in bullets

 -- cycle through all enemy bullets
 for b in all (enemy_bullets) do
  b.y+=b.sy
  b.x+=b.sx
  b.ani+=b.ani_speed

  if (flr(b.ani) > #b.pix)  then
    b.ani=1
  end

  -- if bullet is off screen, delete it.
  if (b.x < -10) del(enemy_bullets,b)
  if (b.x > 130) del(enemy_bullets,b)
  if (b.y < -10) del(enemy_bullets,b)
  if (b.y > 130) del(enemy_bullets,b)

  -- if bullet has hit ship
  if (collide(ship, b)) then
  end

  -- todo: test if bullets have hit ship
  -- for e in all (enemies) do
    -- if bullet hits enemy
    -- if (collide(b,e)) then
      -- small_shockwave(b.x,b.y)
      -- small_sparks(e.x+4,e.y+7)
      -- del(bullets, b)  -- someday bullets may have health/peircing?
      -- e.hp-=1
      -- sfx(3)  -- hit sound
      -- e.flash=3
      -- if enemy is dying
      -- if e.hp <= 0 then
       -- e:kill()
      -- end
    -- end
  -- end -- end for e in all enemies

 end -- end for b in bullets

 -- every X frames, pick an enemy to attack
 local attack_speed=waves[wave].attack_speed
 if (t%attack_speed == 0) enemy_attack()

 -- cycle through all enemies
 for e in all (enemies) do
   enemy_mission(e)

   -- if enemies are not flying in
   if (e.mission != "flyin") then
    -- if enemy has exited to the bottom
    if (e.y > 130) del(enemies, e)
    -- or sides
    if (e.x > 138) del(enemies, e)
    if (e.x < -10) del(enemies, e)
   end

   -- move this into an e:update function?
   e.ani+=e.ani_speed
   if (flr(e.ani) > #e.pix) then
     e.ani=1
   end

   -- decrement invulnerability
   if (invuln>0) invuln-=1

   -- if this enemy has hit ship
   if (collide(ship,e) and ship:takehit()) then -- takehit returns true if we took damage
     e.hp-=3
     -- repeated from above, need to refactor
     -- kill enemy if it is dead
     if e.hp <= 0 then
      -- add(explosions, new_explosion(e.x-4,e.y-4))
      blast(e.x+4,e.y+4)
      del(enemies, e)
      score+=15
      sfx(2) -- death sound
     end
   end


   if (lifes<=0) then
     mode="over" -- this should be a function inside ship obj?
     lockout=t+30
   end
 end -- for e in enemies

 if (#enemies == 0) and (wavetime <= 0) then
   -- next wave
   wave+=1
   wavetime=60
   mode="wavetext"

   if wave>5 then
     mode="win"
     lockout=t+30
   end
 end

 flamespr=flamespr+1
 if (flamespr > 8) flamespr=5

 if(muzzle>0) muzzle=muzzle-1

 if (t % 5) then
   stars=animatestars(stars)
 end

end -- update_game

-->8
-- draw
function draw_game()
 cls(0)
 -- draw all stars
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

 -- generic sprite drawing function
 draw_junk(bullets)
 draw_junk(enemies)
 draw_particles(particles)
 draw_junk(enemy_bullets)

 -- logic to draw ship
 if (lifes > 0) then
  if (invuln<=0) then
   spr(ship.pix,ship.x,ship.y)
   spr(flamespr,ship.x,ship.y+6)
  else
   -- blink ship while invulnerable
   if sin(t/3)<0.5 then
    spr(ship.pix,ship.x,ship.y)
    spr(flamespr,ship.x,ship.y+6)
   end
  end
 end

 -- muzzle flashes
 if(muzzle>0) circfill(ship.x+3,ship.y, muzzle, 7)
 if(muzzle>0) circfill(ship.x+4,ship.y, muzzle, 7)

 -- draw shockwaves
 for sw in all(shockwaves) do
   circ(sw.x+4,sw.y+4,sw.r,sw.color)  -- white circle
   sw.r+=sw.speed
   if (sw.r > sw.maxr) then
     del(shockwaves,sw)
   end
 end

 -- draw life bar
 for i=1,maxlifes do
   if (lifes>=i) then
     spr(heart.pix,i*9-9,1)
   else
     spr(emptyheart.pix,i*9-9,1)
   end
 end

 -- print score
 print_center("score: "..score, 1, 12)
 -- debug text
 -- print(#enemies, 100,1,9)
 -- print(#particles, 100,1,9)

end -- end draw_game()

function draw_start()
 cls(1)

 -- draw background pattern using sprite
 for x=1,127,8 do
   for y=1,127,8 do
    spr(42, x, y)
   end
 end

 print_center("rexroof games shump", 60, blink())
end -- end draw_start()

function draw_over()
 draw_game()
 print_center("game over",60,8)
end

function draw_win()
 draw_game()
 print_center("you winned",60,8)
end

function draw_wavetext()
 draw_game()  -- first draw the game
 print_center("wave "..wave,60,blink())
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
000000009889000000000000000000000000000033000033330000333300003300000000000000000088880000000000000b0000000000000000000000000000
000000009aa9000000000000000000000000000033b00b3333b00b3333b00b3300000000000000000868888000000000000bb000000000000000000000000000
000880009aa900000000000000000000000000000b3bb3b00b3bb3b00b3bb3b00000000000000000888868880000000000bbbb00000000000000000000000000
00aaaa000990000000000000000000000000000000b33b0000b33b0000b33b000000000000000000886888680000303300bbbb00000000000000000000000000
00aaaa0007700000000000000000000000000000003bb300003bb300033bb330000000000000000088888888002223300bb44bb0000000000000000000000000
000aa00006600000000000000000000000000000007337000373373003733730000000000000000088686868222122300bb44bb0000000000000000000000000
00077000000000000000000000000000000000000070070000700700000000000000000000000000088888800222120000bbbb00000000000000000000000000
000660000000000000000000000000000000000000700700000000000000000000000000000000000088880000222000000bb000000000000000000000000000
00000000000000009880088900000000000000000009900000099000000000000000000000000000dddddddd0000000000000000000000000000000000000000
00066600000002009990099900dddd00000000000009900000099000000000000000000000000000dccddddd0000000000000000000b000000000000000b0000
0066006000222200999999990d1111d0000000000099990000999900000000000000000000000000dccddddd0000000000000bb0000b000000000bb0000b0000
006060600c21212c90999909d3d3d3d3000880000091190000911900000000000000000000000000dddddddd0000000000000bbb00bb000000000bbb00bb0000
00606060c0222220009119003d3d3d3d000880009099990990999090000000000000000000000000dddddddd000000000000bbbbbbbb00000000bb1bb1bb0001
00660060c0211120009999000d1111d0000000009999999999999990000000000000000000000000dddddccd000000000000b1bbb1bb00001000b1bbbb1b0001
00066600002222200009900000dddd00000000009990099999909990000000000000000000000000dddddccd0000000000001bbbbb1b00001000bbbbbbbb0001
00000000000c0c000009900000000000000000009880088998808890000000000000000000000000dddddddd000000000000b11b11bb00001000b11bb11b0010
0004400000044000000440000004400000e00e0000e00e0000e00e0000e00e00004444000004440000444000004444000000bbbbbbbbb1000100bbbbbbbbb100
000f4400000444000004f400000f44000030030000300300003003000030030004b000400040b04004b0040004b00040001bbbbbbbbbb010001bbbbbbbbbb000
0044f400004f440000444f00004444000033330000333300003333000033330040000004040000844000084040000004010bb11111bbb001000bbbb1111bb000
04f44f400f44f440044f44f004f44f400003300000033000000330000003300040800084048008044080804040800084100bbbbbbbbbb001000bbbbbbbbbb000
044f4f4004f4f4400f44f4f0044f4440003ee300003e3000000330000003e30040080804040800044008004040080804100bbbbbbbbbb000000bbbbbbbbbb000
04f4f4f00f4f4f40044f444004f444f00390093003909300003993000039093004400440004404477440040004400440000bbbbbbbbbb000000bbbbbbbbbb000
004dd400004dd400004dd400004dd400039009300390930000399300003909300704407000704400007440000704407000000010100000000000001010000000
000dd000000dd000000dd000000dd000003003000030300000033000000303000007000000007000000070000007000000001110111000000000111011100000
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
00700700000000000000000000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07077070000000000008880000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70700700000000000088888000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07067070000888000088888000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000070000888000000800000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70667607000080000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606707000ee000000ee000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060660600e22e0000e88e00007cc7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e2e82e00e87e8e007c67c700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06067070e2882e00e8ee8e007c77c700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060660600e22e0000e88e00007cc7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ee000000ee000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70067007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000047200a7200d7201172013720157201772017720197201d7201e7202072022720247202771018000180001600016000160001600016000160001500015000150001c00021000260002d0003400039000
000100000000000000000002a1502435021150193501515014350101500b3500815007350061500615006150061500615006150081500b1500e15014150171501915000000000000000000000000000000000000
1a03000038650336500b6500a65033650336500b65008650056500465003650006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
5d040000273500a320080001d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000015530655305553105530c553125530050002500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000e7501175016750197501c7501f7502275024750277502a7502c7502e7503175033750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00003995037920369203a920379232b92023920299102c9103391035910329102b910249102391025910289202e9203192034920319202692024920279502a9502a950000000000000000000000000000000
010d00003995337923369233a923379232b92323923299132c9133391335913329132b913249132391325913289232e9233192334923319232692324923279532a9532a953000030000300003000030000300003
__music__
00 41421444

