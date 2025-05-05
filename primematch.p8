pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- 368 chickens  https://368chickens.com/
-- 6x6 grid
-- grid still needs alignment
-- two tokens at a time
-- randomly horizontal or vertical
-- (only chosen if there is space left)
-- 3+ in a row causes clear out
-- total count reduced by number
-- calculate spots left in board, horizontal and vertical
-- always have one horiz & one vert piece available to play?
-- add option to see next piece? (two pieces?)
-- add option to swap tokens to be played?
-- add option to swap to next piece?


function _init()
  cls(12)
  tick=0
  sprite_size=12
  sprites={ 1, 3, 5, 7 }

  reset_game()
end

function _draw()
  cls(12)
  board:draw()
  print(score, 100,1, 0)

  -- hpair:draw()
  -- vpair:draw()
end

function _update()
  tick+=1

  -- fill board with random icons
  -- if tick % 5 then
  --  _x=flr(rnd(6))+1
  --  _y=flr(rnd(6))+1
  --  board.spots[_x][_y]=flr(rnd(4)+1)
  -- end

  hpair:update()
  vpair:update()
  board:update()

end

function reset_game()
  score=(19 * 2^5)
  board=init_board()
  hpair = init_pair({active=true, vertical=false})
  vpair = init_pair({active=true, vertical=true})
end

function init_pair(input)
  _new={
    active=false,  -- if we are "picked up"
    location={x=0,y=0},  -- our location on the board
    vertical=true, -- our orientation
    contents={
      { char=flr(rnd(4)+1), x=0, y=0 },
      { char=flr(rnd(4)+1), x=0, y=0 }
    },  -- the two types that are in our pair
    update = function(p)
      -- set sprites draw locations based on spot on the board
      -- first one is always at our location:
      _tmploc=board:spotlocation(p.location.x, p.location.y)
      p.contents[1].x=_tmploc.x
      p.contents[1].y=_tmploc.y
      -- second one varies depending on horiz/vert
      -- (we rely on movement to never allow us to be outside the board)
      if p.vertical then
        _tmploc=board:spotlocation(p.location.x, p.location.y+1)
      else
        _tmploc=board:spotlocation(p.location.x+1, p.location.y)
      end
      p.contents[2].x=_tmploc.x
      p.contents[2].y=_tmploc.y

      -- wiggle sprites if this pair is active (selected to be moved)
      if p.active then
	_freq=0.5; _amp=0.05;
        _tmpx = 1 + sin(tick*_amp)*_freq
	_freq=0.9; _amp=0.15;
        _tmpy = 1 + cos(tick*_amp)*_freq

	p.contents[1].x+=_tmpx
	p.contents[1].y+=_tmpy
	p.contents[2].x+=_tmpx
	p.contents[2].y+=_tmpy
      end
    end,
    draw = function(p)
      -- update function handles positioning
      for _, c in ipairs(p.contents) do
	place_sprite(c.char, c.x, c.y)
      end
    end,
    place = function(p,board) -- place the pair into the board
      -- test if we're allowed, exit if not
      -- destroy pair, place pair into board slots
    end,
    fits = function(p,board)  -- test if pair fits into board at location
      -- if something is at our current location on the board, return false
      if board.spots[p.location.x][p.location.y] ~= 0 then
	return false
      end
      if p.orientation == "horizontal" then
	-- the square below us.
	if board.spots[p.location.x][p.location.y+1] ~= 0 then
	  return false
	end
      else
	-- the square to the right
	if board.spots[p.location.x+1][p.location.y] ~= 0 then
	  return false
	end
      end
      return true
    end
  }
  -- copy input table over presets
  for k,v in pairs(input) do
    _new[k]=v
  end
  return _new
end

function init_board()
  _b={}
  _b.offset=5
  _b.spots = {}    -- matrix of spots on board
  for i=1,6 do
   _b.spots[i] = {} -- create a new row
   for j=1,6 do
     _b.spots[i][j] = 0 -- empty
   end
  end

  -- get {x,y} location of spot on board
  _b.spotlocation = function(b, _x, _y)
    return {
	x=((sprite_size+1)*(_x-1))+b.offset,
	y=((sprite_size+1)*(_y-1))+b.offset
    }
  end

  _b.update = function(board)
   -- test how many open adjecent spots there are
   -- test if there are any matches and handle them?
   -- end game if no available spots
   -- disable/grey out pieces that can't be played?
  end

  _b.draw = function(board)
    for y,row in ipairs(board.spots) do
      for x,occupant in ipairs(row) do
      -- fill empty spots with color 1
        loc=board:spotlocation(x,y)
	x1=loc.x+sprite_size
	y1=loc.y+sprite_size

	-- draw box around cell
	rect(loc.x-1,loc.y-1,x1+1,y1+1,0)

	if occupant == 0 then
          rectfill(loc.x,loc.y,x1,y1,1)
	else
	  place_sprite(occupant, loc.x, loc.y)
	end

      end
    end
  end

  return _b
end

function place_sprite(_occ, _x, _y)
  -- find our real sprite location from sprites table
  _spr=sprites[_occ]

  -- find our sprite positions in the sprite map
  sx, sy = (_spr % 16) * 8, (_spr \ 16) * 8
  -- shift by 1 because we have a frame on them
  sx+=1
  sy+=1
  -- display sprite on screen
  sspr(sx,sy,sprite_size,sprite_size,_x,_y)
end

__gfx__
00000000ffffffffffffff00ffffffffffffff00ffffffffffffff00ffffffffffffff0000000000000000000000000000000000000000000000000000000000
00000000f000000004400f00f000bbbbbb000f00f000aaaaaa000f00f000222222000f0000000000000000000000000000000000000000000000000000000000
00700700f444000049400f00f00bbbbbbbb00f00f00aaaaaaaa00f00f002222222200f0000000000000000000000000000000000000000000000000000000000
00077000f499400496400f00f0bbbbbbbbbb0f00f0aaaaaaaaaa0f00f022222222220f0000000000000000000000000000000000000000000000000000000000
00077000f477944996400f00fbbbbbbbbbbbbf00faaaaaaaaaaaaf00f222222222222f0000000000000000000000000000000000000000000000000000000000
00700700f469999979400f00fbbbbbbbbbbbbf00faaaaaaaaaaaaf00f222222222222f0000000000000000000000000000000000000000000000000000000000
00000000f049979995400f00fbbbbbbbbbbbbf00faaaaaaaaaaaaf00f222222222222f0000000000000000000000000000000000000000000000000000000000
00000000f049959999975f00fbbbbbbbbbbbbf00faaaaaaaaaaaaf00f222222222222f0000000000000000000000000000000000000000000000000000000000
00000000f049999996775f00fbbbbbbbbbbbbf00faaaaaaaaaaaaf00f222222222222f0000000000000000000000000000000000000000000000000000000000
00000000f049996777700f00fbbbbbbbbbbbbf00faaaaaaaaaaaaf00f222222222222f0000000000000000000000000000000000000000000000000000000000
00000000f044967755500f00f0bbbbbbbbbb0f00f0aaaaaaaaaa0f00f022222222220f0000000000000000000000000000000000000000000000000000000000
00000000f004967777700f00f00bbbbbbbb00f00f00aaaaaaaa00f00f002222222200f0000000000000000000000000000000000000000000000000000000000
00000000f000466777000f00f000bbbbbb000f00f000aaaaaa000f00f000222222000f0000000000000000000000000000000000000000000000000000000000
00000000ffffffffffffff00ffffffffffffff00ffffffffffffff00ffffffffffffff0000000000000000000000000000000000000000000000000000000000
