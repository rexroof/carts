pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

---
-- example of exploding sprite using a simple particle system
---

function _init()
 t=0
 init_particles()
end

function _update()
  t+=1

  -- every 10 frames, explode a random sprite
  if ( t%10 == 0 ) then
    -- random x&y
    local startx=flr(rnd(100))+10
    local starty=flr(rnd(100))+10

    -- sprites 128-191
    local sprite=flr(rnd(64))+128

    for x=0,7 do
      for y=0,7 do
        local color=get_pixel(sprite,x,y)
        spr(sprite,x,y)
        if (color != 0) then
          add_random_particle(startx+x, starty+y,color)
        end
      end
    end
  end

  update_particles()
end

function _draw()
  cls()
  draw_particles()
end

function get_pixel(sprite,x,y)
  -- i'm sure I could simplify this?
  local starty=(flr(sprite/16) * 8)
  local startx=((sprite-(flr(sprite/16) * 16)) * 8)

  return sget(startx+x, starty+y)
end

--8
--particles


function init_particles()
  particles={}
end

function draw_particles()

 for p in all(particles) do
   pset(p.x,p.y,p.color)
 end

end

function update_particles()

 for p in all(particles) do
   p.x+=p.sx
   p.y+=p.sy
   p.age+=1
   if (p.age>p.maxage) del(particles,p)
 end

end

function add_random_particle(x,y,c)
    c=c or 7
    add(particles, { x=x, y=y,
        sx=(rnd()-0.5)*1,
        sy=(rnd()-0.5)*1,
        age=0,
        color=c,
        maxage=rnd(30)+5
        } )
end

__gfx__
00000000000220000002200000022000000000000000000000000000000000000000000000000000000000000000000000000000088008800880088000000000
000000000028820000288200002882000000000000077000000770000007700000c77c0000077000000000000000000000000000888888888008800800000000
007007000028820000288200002882000000000000c77c000007700000c77c000cccccc000c77c00000000000000000000000000888888888000000800000000
0007700000288e2002e88e2002e882000000000000cccc00000cc00000cccc0000cccc0000cccc00000000000000000000000000888888888000000800000000
00077000027c88202e87c8e202887c2000000000000cc000000cc000000cc00000000000000cc000000000000000000000000000088888800800008000000000
007007000211882028811882028811200000000000000000000cc000000000000000000000000000000000000000000000000000008888000080080000000000
00000000025582200285582002285520000000000000000000000000000000000000000000000000000000000000000000000000000880000008800000000000
00000000002992000029920000299200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999000009999000000000000000000000000000330033003300330033003300330033000000000000000000000000000000000000000000000000000000000
9977990009aaaa9000000000000000000000000033b33b3333b33b3333b33b3333b33b3300000000000000000000000000000000000000000000000000000000
9a77a9009aa77aa90000000000000000000000003bbbbbb33bbbbbb33bbbbbb33bbbbbb300000000000000000000000000000000000000000000000000000000
9a77a9009a7777a90000000000000000000000003b7717b33b7717b33b7717b33b7717b300000000000000000000000000000000000000000000000000000000
9a77a9009a7777a90000000000000000000000000b7117b00b7117b00b7117b00b7117b000000000000000000000000000000000000000000000000000000000
99aa99009aa77aa90000000000000000000000000037730000377300003773000037730000000000000000000000000000000000000000000000000000000000
09aa900009aaaa900000000000000000000000000303303003033030030330300303303000000000000000000000000000000000000000000000000000000000
00990000009999000000000000000000000000000300003030000003030000300330033000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000070000020000200200002002000020020000205555555555555555555555555555555502222220022222200222222002222220
000bb000000bb0000007700000077000022ff220022ff220022ff220022ff2200578875005788750d562465d0578875022e66e2222e66e2222e66e2222e66e22
0066660000666600606666066066660602ffff2002ffff2002ffff2002ffff2005624650d562465d05177150d562465d27761772277617722776177227716772
0566665065666656b566665bb566665b0077d7000077d700007d77000077d700d517715d051771500566865005177150261aa172216aa162261aa612261aa162
65637656b563765b056376500563765008577580085775800857758008577580056686500566865005d24d50056686502ee99ee22ee99ee22ee99ee22ee99ee2
b063360b006336000063360000633600080550800805508008055080080550805d5245d505d24d500505505005d24d5022299222229999222229922222299222
006336000063360000633600006336000c0000c007c007c007c00c7007c007c05005500505055050050000500505505020999902020000202099990202999920
0006600000066000000660000006600000c7c7000007c0000077cc000007c000dd0000dd0dd00dd005dddd500dd00dd022000022022002202200002202200220
00ff880000ff88000330033000999900200000020200002003300330033003303350053303500530000000000000000000000000000000000000000000000000
088888800888888033b33b3309aaaa90220000222200002233b33b3333b33b33330dd033030dd030005005000350053000000000000000000000000000000000
06555560076665503bbbbbb39aa77aa922222222222222223bbbbbb33bbbbbb33b8dd8b3338dd833030dd030030dd03003e33e300e33e330033e333003e333e0
65666655765555653b7717b39a7777a928222282282222823b7717b33b7717b3032dd2300b2dd2b0038dd830338dd833e33e33e333e33e333e33e333e33e333e
57655576555776550b7117b09a7777a928888882288888820b7117b00b7117b03b3553b33b3553b3033dd3300b2dd2b033300333333003333330033333300333
0655766005765550003773009aa77aa928788782287887820037730000377300333dd333333dd33303b55b303b3553b3e3e3333bbe33333ebe3e333be3e3333b
00576500006557000303303009aaaa9028888882080000800303303003033030330550330305503003bddb30333dd3334bbbbeb44bbbebb44bbbbeb44bbbebe4
00065000000570000300003000999900080000800000000030000003033003300000000000000000003553000305503004444440044444400444444004444440
0066600000666000006660000068600000888000002222000022220000222200002222000cccccc00c0000c00000000000000000088008800002200000222200
055556000555560005585600058886000882880002eeee2002eeee2002eeee2002eeee20c0c0c0ccc000000c0000000000000000888888880028820008888820
55555560555855605588856058828860882228802ee77ee22ee77ee22eeeeee22ee77ee2c022220ccc2c2c0cc022220c00222200888888880028820008888820
55555550558885505882885088222880822222802ee77ee22ee77ee22ee77ee22ee77ee2cc2cac0cc02aa20cc0cac2ccc02aa20c8888888802e88e2008ee8e80
15555550155855501588855018828850882228802eeeeee22eeeeee22eeeeee22eeeeee2c02aa20cc0cac2ccc02aa20ccc2cac0c088888802e87c8e208ee8e80
01555500015555000158550001888500088288002222222222222222222222222222222200222200c022220ccc2c2c0cc022220c008888002881188200884200
0011100000111000001110000018100000888000202020200202020220202020020202020000000000000000c000000cc0c0c0cc000880000285582003bb3bb3
00000000000000000000000000000000000000002000200002000200002000200002000200000000000000000c0000c00cccccc0000000000029920003330333
000880000009900000089000000890000070000001111110011111100000000000d89d0000189100001891000019810000005500000050000005000000550000
70666605076666500067660000665600000d330001cccc1001cccc10000770000d5115d000d515000011110000515d0000055000000550000005500000055000
1661c6610161661000666600001666000028833001cccc1001cccc1000c77c00d51aa15d0151a11000155100011a151005555550055555500555555005555550
70666605076666500067660000665600077ffd70017cc710017cc71000cccc00d51aa15d0d51a15000d55d00051a15d022222222222222222222222222222222
0076650000766500007665000076650007188210017cc710017cc710000cc0006d5005d6065005d0006dd6000d50056026060602260606022666666226060602
000750000007500000075000000750000028820001111110011111100000000066d00d60006d0d600066660006d0d60020000002206060622222222020606062
0007500000075000000750000007500007d882d01100001101100110000000000760067000660600000660000060660020606062222222200000000022222220
0006000000060000000600000006000000dffd001100001101100110000000000070070000070700000770000070700022222220000000000000000000000000
0007033000700000007d330003330333000000000022220000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d3300000d33000028833003bb3bb3000000000888882000000000000000000000000000000000000000000000000000000000000000000000000000000000
0778827000288330071ffd1000884200002882000888882000288200000000000000000000000000000000000000000000000000000000000000000000000000
071ffd10077ffd700778827008ee8e800333e33308ee8e80088ee883000000000000000000000000000000000000000000000000000000000000000000000000
00288200071882100028820008ee8e8003bb4bb308ee8e8008eeee83000000000000000000000000000000000000000000000000000000000000000000000000
07d882d00028820007d882d00888882008eeee800088420008eeee80000000000000000000000000000000000000000000000000000000000000000000000000
0028820007d882d000dffd0008888820088ee88003bb3bb3088ee880000000000000000000000000000000000000000000000000000000000000000000000000
00dffd0000dffd000000000000222200002882000333033300288200000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000149aa94100000000012222100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00019777aa921000000029aaaa920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d09a77a949920d00d0497777aa920d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0619aaa9422441600619a77944294160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07149a922249417006149a9442244160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07d249aaa9942d7006d249aa99442d60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
067d22444422d760077d22244222d770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d666224422666d00d776249942677d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
066d51499415d66001d1529749251d10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0041519749151400066151944a151660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a001944a100a0000400149a4100400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000049a400090000a0000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000