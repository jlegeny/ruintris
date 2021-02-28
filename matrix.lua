local matrix = {}

matrix.transpose = function(m)
  local columns = #m
  local rows = #m[1]

  for r = 1, rows do
    for c = r, columns do
      m[r][c], m[c][r] = m[c][r], m[r][c]
    end
  end
end

matrix.reverse_rows = function(m)
  local columns = #m
  local rows = #m[1]

  for r = 1, rows do
    local ci, cj = 1, columns
    while ci < cj do
      m[ci][r], m[cj][r] = m[cj][r], m[ci][r]
      ci = ci + 1
      cj = cj - 1
    end
  end
end

matrix.reverse_columns = function(m)
  local columns = #m
  local rows = #m[1]

  for c = 1, columns do
    local ri, rj = 1, rows
    while ri < rj do
      m[c][ri], m[c][rj] = m[c][rj], m[c][ri]
      ri = ri + 1
      rj = rj - 1
    end
  end
end

return matrix
