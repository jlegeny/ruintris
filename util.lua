local util = {}

function interp(s, tab)
  return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

getmetatable("").__mod = interp

util.deepcopy = function(orig, copies)
  copies = copies or {}
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    if copies[orig] then
      copy = copies[orig]
    else
      copy = {}
      copies[orig] = copy
      for orig_key, orig_value in next, orig, nil do
        copy[util.deepcopy(orig_key, copies)] = util.deepcopy(orig_value, copies)
      end
      setmetatable(copy, util.deepcopy(getmetatable(orig), copies))
    end
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

util.str = function(maybe_str)
  if maybe_str == nil then
    return '(nil)'
  end
  return maybe_str
end

return util
