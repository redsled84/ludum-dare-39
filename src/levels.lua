-- generated by alex's mapgen script
local doors = {
  {24,28},
  {29,28},
  {18,21},
  {27,18},
  {21,14},
  {20,9},
  {14,31},
  {3,19},
  {10,19},
  {14,16},
  {9,12},
  {14,9},
  {14,5},
  {8,2},
  {2,7},
}
local terms = {
  {
    {28,29},
  },
  {
    {31,26},
  },
  {
    {21,19},
  },
  {
    {32,13},
  },
  {
    {18,8},
    {22,8},
  },
  {
    {18,12},
  },
  {
    {12,31},
    {16,31},
  },
  {
    {6,27},
  },
  {
    {10,22},
  },
  {
    {12,13},
    {16,13},
  },
  {
    {6,14},
  },
  {
    {11,6},
  },
  {
    {16,4},
  },
  {
    {8,5},
    {9,6},
  },
  {
    {4,4},
  },
}
local grid = {
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,0,0,0,1,2,0,3,0,1,1,1,1,2,1,1,1,1,1,1,1,1,1,5,5,5,5,5,5,2,0,1},
  {1,0,0,0,1,0,0,1,0,1,1,1,1,0,1,1,1,1,1,1,1,1,1,5,0,0,2,5,5,0,0,1},
  {1,0,0,4,1,0,0,1,0,0,0,0,0,0,5,4,1,1,1,1,1,1,1,5,0,5,5,5,5,0,0,1},
  {1,0,2,0,1,0,0,4,1,1,1,1,1,3,1,1,1,1,1,1,1,1,1,5,0,5,5,5,5,0,0,1},
  {1,0,0,0,1,0,0,1,4,1,4,1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,0,1},
  {1,3,1,1,1,0,0,0,0,1,5,1,1,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,2,1,2,5,5,0,1,1,1,4,5,0,5,4,1,0,5,5,5,5,5,5,0,1},
  {1,1,1,1,1,1,1,1,1,1,5,1,1,3,1,1,1,1,1,3,1,1,1,0,5,5,1,5,5,5,0,1},
  {1,1,1,1,1,1,1,1,1,1,5,1,1,0,1,1,1,0,0,0,0,2,1,0,5,5,2,1,5,5,0,1},
  {1,1,1,1,1,1,1,1,2,1,1,1,1,0,1,1,1,0,0,0,0,0,1,5,5,5,5,5,0,0,0,1},
  {1,1,1,1,1,1,1,1,3,1,1,1,0,0,5,1,1,4,0,0,2,0,1,5,5,5,5,5,0,5,5,1},
  {1,1,1,1,0,0,0,0,0,0,1,4,0,0,5,4,1,0,0,0,0,0,1,2,5,5,0,5,0,5,5,4},
  {1,1,1,1,0,4,0,0,0,0,1,1,0,0,5,1,1,1,0,1,3,1,1,1,5,5,0,5,0,5,5,1},
  {1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,0,1,1,1,5,5,0,0,0,5,5,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,1,1,1,0,1,0,1,1,1,5,5,0,0,0,5,5,1},
  {1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,1,1,1,1,1,1,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1,5,5,5,3,5,5,0,0,1},
  {1,0,3,0,0,1,2,1,0,3,0,0,0,0,0,0,0,1,1,1,4,1,1,5,5,5,0,5,5,0,0,1},
  {1,0,1,1,0,1,0,1,0,1,0,0,0,0,0,0,0,1,1,0,0,0,0,5,5,5,0,5,5,0,0,1},
  {1,0,1,0,0,1,0,1,0,1,0,0,0,0,0,0,0,3,0,0,0,0,0,5,5,5,2,5,5,0,0,1},
  {1,0,1,0,1,1,0,1,1,4,0,0,0,0,0,0,0,1,0,0,0,0,0,5,5,5,5,5,5,0,0,1},
  {1,0,1,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,0,5,5,5,1,1,0,1,0,0,1,1,1},
  {1,0,1,0,0,0,0,1,2,1,1,0,0,0,0,0,1,1,0,0,5,5,5,0,1,0,1,1,0,1,1,1},
  {1,0,1,0,1,1,1,1,0,1,1,1,0,0,0,1,1,1,5,5,5,5,5,0,0,0,0,0,0,1,4,1},
  {1,0,0,0,1,4,0,0,0,1,1,1,1,0,1,1,1,1,5,1,1,1,0,0,0,0,0,0,0,0,0,1},
  {1,0,1,1,1,1,0,1,1,1,1,1,1,0,5,5,5,5,2,1,1,1,1,3,1,1,1,1,3,1,1,1},
  {1,0,0,0,0,1,0,0,0,1,1,1,1,0,1,1,1,1,1,1,1,1,1,5,1,1,1,4,0,1,1,1},
  {1,0,1,1,0,1,1,1,0,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,0,0,1,1,0,1,1,1},
  {1,0,0,1,0,0,0,0,0,0,0,4,1,3,1,4,5,5,0,0,0,0,0,0,1,0,0,0,0,1,1,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
}
local vector = require 'libs.vector'

function createLink(door, terminals)
  return {
    door = door,
    terminals = terminals
  }
end

function createLinks(grid)
  doors2terms = {}
  for i = 1, #doors do
    d = doors[i]
    tl = terms[i]
    term_list = {}
    for j = 1, #tl do
      t = tl[j]
      term_list[#term_list+1] = vector(t[1], t[2]) * tileSize
    end

    doors2terms[#doors2terms+1] = createLink(
      vector(d[1], d[2]) * tileSize,
      term_list
    )
  end
  return doors2terms
end

return grid
