local palette = {
  green = {
    [4] = { 182, 213, 60 },
  },
  grey = {
    [0] = { 48, 44, 46 },
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

