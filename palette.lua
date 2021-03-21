local palette = {
  green = {
    [4] = { 182, 213, 60 },
  },
  grey = {
    [0] = { 48, 44, 46 },
  },
  red = {
    [0] = { 169, 59, 59 },
  },
  eggplant = {
    [7] = { 244, 204, 161 },
  }
}

function make_palette()
  local pal = {}
  for name, colors in pairs(palette) do
    local cpal = {}
    for i, c in pairs(colors) do
      cpal[i] = { c[1] / 255, c[2] / 255, c[3] / 255 }
    end
    pal[name] = cpal
  end
  return pal
end

return make_palette()

