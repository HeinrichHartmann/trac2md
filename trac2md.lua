--
-- Convert Trac/MoinMoin wiki syntax to Markdown
--

local L = require"lpeg"
local re = require"re"
require("pl.stringx").import()
require "pl.strict"

local link_root = os.getenv("LINK_ROOT")
local trac_root = os.getenv("TRAC_ROOT")

local hex_to_char = function(x)
  return string.char(tonumber(x, 16))
end
local unescape = function(url)
  return url:gsub("%%(%x%x)", hex_to_char)
end

local link_wiki2md = function(t)
  t = unescape(t)

  -- fix links to match wiki renames
  t = t:gsub(" ","_")
  t = t:gsub(":","_")
  t = t:gsub("'","")

  if link_root then
    t = t:gsub("^" .. link_root, "")
  end

  -- stash fragment
  local path, sep, fragment = t:rpartition("#")
  t = "/" .. path .. '.md'
  -- restore fragment
  if #fragment > 0 then
    t = t .. "#" .. fragment
  end

  return t
end

local mk = {
  head = function(s)
    return s:rstrip()
  end,
  image = function(t)
    -- strip alignment comments
    t = t:gsub(",left$","")
    t = t:gsub(",right$","")
    local alt = "Image: '" .. t .. "'"
    local base = "/assets/"
    local url = base .. t .. '?raw=true'
    return ("![%s](%s)"):format(alt,url)
  end,
  link = function(t, c)
    c = c:strip()
    t = t:strip()
    if t:startswith("wiki:") then
      -- internal wiki link
      -- https://github.com/blog/1395-relative-links-in-markup-files
      t = t:gsub("^wiki:","")
      t = link_wiki2md(t)
    elseif trac_root and t:startswith(trac_root) then
      -- explicit wiki link
      t = t:gsub(trac_root, "")
      t = link_wiki2md(t)
    elseif not t:startswith("http") then
      -- probably an internal wiki link
      t = link_wiki2md(t)
    end
    if #c == 0 then
      c = t
    end
    return "[" .. c .. "](" .. t .. ")"
  end,
  pre = function(mark, content)
    mark = mark:strip():sub(3)
    content = content:rstrip("\n")
    if mark == "html" then
      return content
    elseif mark == "comment" then
        return ""
    else
      return ("```%s\n%s\n```"):format(mark, content)
    end
  end,
  tablrow = function(row)
    return "|" .. row:gsub("||","|") .. "|\n"
  end,
  tablhead = function(row)
    local h = "|" .. row:gsub("||","|") .. "|\n"
    local b = {h, "|"}
    for i = 1, h:count("|") - 1 do
      b[#b + 1] = "---|"
    end
    return table.concat(b) .. "\n"
  end,
}

local EOS          = -L.P(1)
local space        = L.P" "^0
local alpha        = L.R("az","AZ")
local num          = L.R("09")
local EOL          = L.P[[\n]] + L.P"\n" + EOS
local BOL          = L.P"\n" -- + start of string?
local char         = L.P(1)
local text         = (L.R("az","AZ","09") + L.P' ')^1

local image        = L.P'[[Image(' * L.Cg((1 - L.P')')^1) * L.P')]]' / mk.image

local link_target  = (1 - L.S" ]")^1
local link_caption = (1 - L.P"]")^0 -- can be empty
local link         = L.P'[' * L.Cg(link_target) * L.Cg(link_caption) * L.P']'              / mk.link
local pre_mark     = (L.P'#!' * (alpha+num)^1 * EOL)^-1
local pre_content  = (1 - L.P'}}}')^0
local pre          = L.P"{{{" *space * EOL * L.Cg(pre_mark) * L.Cg(pre_content) * L.P"}}}" / mk.pre
local quote        = EOL * L.P"  " * L.Cg((1 - EOL)^0) / '    %1'
local style        = L.P {
  "sty",
  sty  = L.Cs(L.V'mono1' + L.V'mono2' + L.V'bold' + L.V'it'),
  it   = L.P"''"   * L.Cg((L.V'sty' + L.P"''"   + 1 - L.P"''")^0)  * L.P"''"  / '*%1*',
  bold = L.P"'''"  * L.Cg((L.V'sty' + L.P"!'''" + 1 - L.P"'''")^0) * L.P"'''" / '**%1**',
  mono1 = L.P'{{{' * L.Cg((           L.P"!}}}" + 1 - L.P'}}}')^0) * L.P'}}}' / '`%1`',
  mono2 = L.P'`'   * L.Cg((           L.P"!`"   + 1 - L.P'`')^0)   * L.P'`'   / '`%1`',
}

local misc_br      = L.Cg(L.P'[[BR]]' + L.P'[[br]]') / '  \n'
local misc_excl    = L.P'!' * L.Cg(alpha + L.P'{') / '%1'
local misc         = misc_br + misc_excl
local format       = misc + image + link + quote + pre + style

local tabl_rowc    = L.Cs((format + (1 - (L.P'||' * EOL)))^0)
local tabl_row     = L.P'||' * L.Cg(tabl_rowc) * L.P'||' * EOL
local tabl         = (EOL * EOL + L.Cc'\n') * (tabl_row / mk.tablhead) * (tabl_row / mk.tablrow)^0

local hcont        = L.Cg(L.Cs((format + (1 - L.P"="))^1)) / mk.head
local h1           = L.P"\n="    * space * L.Cg(hcont) * L.P"="     / '\n\n# %1'
local h2           = L.P"\n=="   * space * L.Cg(hcont) * L.P"=="    / '\n\n## %1'
local h3           = L.P"\n==="  * space * L.Cg(hcont) * L.P"==="   / '\n\n### %1'
local h4           = L.P"\n====" * space * L.Cg(hcont) * L.P"===="  / '\n\n#### %1'
local head         = h4 + h3 + h2 + h1

local list_defn    = EOL * space * L.Cg((alpha + L.S'/ .(),')^1) * L.P'::' / '\n* **%1** '
local list         = list_defn

local item         = head + tabl + list + format + text + char
local G            = L.Cs(item^0) * EOS

local input = io.read("*all")
local output = G:match("\n" .. input):strip("\n") .. "\n" or "Invalid format"
io.write(output)
