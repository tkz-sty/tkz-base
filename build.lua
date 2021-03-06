-- Build script for tkz-base

module = "tkz-base"
tkzbasev = "3.06c"
tkzbased = "2020/04/06"
doctkzbasev = tkzbasev -- Same as "3.06c"
doctkzbased = tkzbased -- Same as "2020/03/20"

-- Setting variables for .zip file (CTAN)
textfiles  = {"README.md"}
ctanreadme = "README.md"
ctanpkg    = module
ctanzip    = ctanpkg.."-"..tkzbasev
packtdszip = false
flatten    = false
cleanfiles = {ctanzip..".curlopt", ctanzip..".zip"}

-- Creation of simplified structure for CTAN
local function make_ctan_tree()
  if direxists("code") then
    cleandir("code")
    cp("*.*", "latex", "code")
  else
    errorlevel = (mkdir("code") + cp("*.*", "latex", "code"))
    if errorlevel ~= 0 then
      error("** Error!!: Can't copy files from ./latex to ./code")
      return errorlevel
    end
  end
  if direxists("doc/examples") then
    cleandir("doc/examples")
    cp("*.*", "examples", "doc/examples")
  else
    errorlevel = (mkdir("doc/examples") + cp("*.*", "examples", "doc/examples"))
    if errorlevel ~= 0 then
      error("** Error!!: Can't copy files from ./examples to ./doc/examples")
      return errorlevel
    end
  end
  if direxists("doc/sourcedoc") then
    cleandir("doc/sourcedoc")
    cp("*.*", "doc/latex", "doc/sourcedoc")
    ren("doc/sourcedoc", "TKZdoc-base-main.tex", "TKZdoc-base.tex")
  else
    errorlevel = (mkdir("doc/sourcedoc") + cp("*.*", "doc/latex", "doc/sourcedoc")
                 + ren("doc/sourcedoc", "TKZdoc-base-main.tex", "TKZdoc-base.tex"))
    if errorlevel ~= 0 then
      error("** Error!!: Can't copy files from ./doc/latex to .doc/sourcedoc")
      return errorlevel
    end
  end
end

if options["target"] == "doc" or options["target"] == "ctan" or options["target"] == "install" then
  make_ctan_tree()
end

if options["target"] == "clean" then
  errorlevel = (cleandir("code") + cleandir("doc/sourcedoc") + cleandir("doc/examples"))
  lfs.rmdir("code")
  lfs.rmdir("doc/sourcedoc")
  lfs.rmdir("doc/examples")
end

-- Setting variables for package files
sourcefiledir = "code"
docfiledir    = "doc"
docfiles      = {"TKZdoc-base.pdf", "sourcedoc/*.*", "examples/*.*"}
sourcefiles   = {"tkz-*.cfg", "tkz-*.tex", "tkz-*.sty"}
installfiles  = {"tkz-*.*", "README.md"}

-- Setting file locations for local instalation (TDS)
tdslocations = {
  "doc/latex/tkz-base/sourcedoc/tiger.pdf",
  "doc/latex/tkz-base/sourcedoc/TKZdoc-*.tex",
  "doc/latex/tkz-base/examples/preamble-standalone.ltx",
  "doc/latex/tkz-base/examples/tkzBase-*.tex",
  "tex/latex/tkz-base/tkz-*.*",
}

-- Update package date and version
tagfiles = {"./latex/tkz*.*", "README.md", "doc/latex/TKZdoc-base-main.tex"}

function update_tag(file, content, tagname, tagdate)
  if string.match(file, "%.tex$") then
    content = string.gsub(content,
                          "\\fileversion{.-}",
                          "\\fileversion{"..tkzbasev.."}")
    content = string.gsub(content,
                          "\\filedate{.-}",
                          "\\filedate{"..tkzbased.."}")
    content = string.gsub(content,
                          "\\typeout{%d%d%d%d%/%d%d%/%d%d %d+.%d+%a* %s*(.-)}",
                          "\\typeout{"..tkzbased.." "..tkzbasev.." %1}")
    content = string.gsub(content,
                          "\\gdef\\tkzversionofpack{.-}",
                          "\\gdef\\tkzversionofpack{"..tkzbasev.."}")
    content = string.gsub(content,
                          "\\gdef\\tkzdateofpack{.-}",
                          "\\gdef\\tkzdateofpack{"..tkzbased.."}")
    content = string.gsub(content,
                          "\\gdef\\tkzversionofdoc{.-}",
                          "\\gdef\\tkzversionofdoc{"..doctkzbasev.."}")
    content = string.gsub(content,
                          "\\gdef\\tkzdateofdoc{.-}",
                          "\\gdef\\tkzdateofdoc{"..doctkzbased.."}")
  end
  if string.match(file, "%.sty$") then
    content = string.gsub(content,
                          "\\fileversion{.-}",
                          "\\fileversion{"..tkzbasev.."}")
    content = string.gsub(content,
                          "\\filedate{.-}",
                          "\\filedate{"..tkzbased.."}")
    content = string.gsub(content,
                          "\\typeout{%d%d%d%d%/%d%d%/%d%d %d+.%d+%a* %s*(.-)}",
                          "\\typeout{"..tkzbased.." "..tkzbasev.." %1}")
    content = string.gsub(content,
                          "\\ProvidesPackage{(.-)}%[%d%d%d%d%/%d%d%/%d%d %d+.%d+%a* %s*(.-)%]",
                          "\\ProvidesPackage{%1}["..tkzbased.." "..tkzbasev.." %2]")
  end
  if string.match(file, "%.cfg$") then
    content = string.gsub(content,
                          "\\fileversion{.-}",
                          "\\fileversion{"..tkzbasev.."}")
    content = string.gsub(content,
                          "\\filedate{.-}",
                          "\\filedate{"..tkzbased.."}")
    content = string.gsub(content,
                          "\\typeout{%d%d%d%d%/%d%d%/%d%d %d+.%d+%a* %s*(.-)}",
                          "\\typeout{"..tkzbased.." "..tkzbasev.." %1}")
  end
  if string.match(file, "README.md$") then
    content = string.gsub(content,
                          "Release %d+.%d+%a* %d%d%d%d%/%d%d%/%d%d",
                          "Release "..tkzbasev.." "..tkzbased)
  end
  return content
end

-- Typesetting package documentation
typesetfiles = {"TKZdoc-base.tex"}

local function type_manual()
  local file = jobname("doc/sourcedoc/TKZdoc-base.tex")
  errorlevel = (runcmd("lualatex --draftmode "..file..".tex", typesetdir, {"TEXINPUTS","LUAINPUTS"})
              + runcmd("makeindex "..file..".idx", typesetdir, {"TEXINPUTS","LUAINPUTS"})
              + runcmd("lualatex "..file..".tex", typesetdir, {"TEXINPUTS","LUAINPUTS"}))
  if errorlevel ~= 0 then
    error("Error!!: Typesetting "..file..".tex")
    return errorlevel
  end
  ren("doc/sourcedoc", "TKZdoc-base.tex", "TKZdoc-base-main.tex")
  return 0
end

specialtypesetting = { }
specialtypesetting["TKZdoc-base.tex"] = {func = type_manual}

-- Load personal data
local ok, mydata = pcall(require, "Alaindata.lua")
if not ok then
  mydata = {email="XXX", uploader="YYY"}
end

-- CTAN upload config
uploadconfig = {
  author      = "Alain Matthes",
  uploader    = mydata.uploader,
  email       = mydata.email,
  pkg         = ctanpkg,
  version     = tkzbasev,
  license     = "lppl1.3c",
  summary     = "Tools for drawing with a cartesian coordinate system",
  description = [[The bundle is a set of packages, designed to give mathematics teachers (and students) easy access to programming of drawings with TikZ.]],
  topic       = { "PGF TikZ", "pgf" },
  ctanPath    = "/macros/latex/contrib/tkz/"..ctanpkg,
  repository  = "https://github.com/tkz-sty/"..ctanpkg,
  bugtracker  = "https://github.com/tkz-sty/"..ctanpkg.."/issues",
  support     = "https://github.com/tkz-sty/"..ctanpkg.."/issues",
  announcement_file="ctan.ann",
  note_file   = "ctan.note",
  update      = true,
}

-- Print lines in 80 characters
local function os_message(text)
  local mymax = 77 - string.len(text) - string.len("done")
  local msg = text.." "..string.rep(".", mymax).." done"
  return print(msg)
end

-- Create check_marked_tags() function
local function check_marked_tags()
  local f = assert(io.open("latex/tkz-base.sty", "r"))
  marked_tags = f:read("*all")
  f:close()
  local m_pkgd, m_pkgv = string.match(marked_tags, "\\typeout{(%d%d%d%d%/%d%d%/%d%d) (%d+.%d+%a*) .-")
  if tkzbasev == m_pkgv and tkzbased == m_pkgd then
    os_message("** Checking version and date: OK")
  else
    print("** Warning: tkz-base.sty is marked with version "..m_pkgv.." and date "..m_pkgd)
    print("** Warning: build.lua is marked with version "..tkzbasev.." and date "..tkzbased)
    print("** Check version and date in build.lua then run l3build tag")
  end
end

-- Config tag_hook
function tag_hook(tagname)
  check_marked_tags()
end

-- Add "tagged" target to l3build CLI
if options["target"] == "tagged" then
  check_marked_tags()
  os.exit()
end

-- GitHub release version
local function os_capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

local gitbranch = os_capture("git symbolic-ref --short HEAD")
local gitstatus = os_capture("git status --porcelain")
local tagongit  = os_capture('git for-each-ref refs/tags --sort=-taggerdate --format="%(refname:short)" --count=1')
local gitpush   = os_capture("git log --branches --not --remotes")

if options["target"] == "release" then
  if gitbranch == "master" then
    os_message("** Checking git branch '"..gitbranch.."': OK")
  else
    error("** Error!!: You must be on the 'master' branch")
  end
  if gitstatus == "" then
    os_message("** Checking status of the files: OK")
  else
    error("** Error!!: Files have been edited, please commit all changes")
  end
  if gitpush == "" then
    os_message("** Checking pending commits: OK")
  else
    error("** Error!!: There are pending commits, please run git push")
  end
  check_marked_tags()

  local pkgversion = "v"..tkzbasev
  local pkgdate = tkzbased
  os_message("** Checking last tag marked in GitHub "..tagongit..": OK")
  errorlevel = os.execute("git tag -a "..pkgversion.." -m 'Release "..pkgversion.." "..pkgdate.."'")
  if errorlevel ~= 0 then
    error("** Error!!: tag "..tagongit.." already exists, run git tag -d "..pkgversion.." && git push --delete origin "..pkgversion)
    return errorlevel
  else
    os_message("** Running: git tag -a "..pkgversion.." -m 'Release "..pkgversion.." "..pkgdate.."'")
  end
  os_message("** Running: git push --tags --quiet")
  os.execute("git push --tags --quiet")
  if fileexists(ctanzip..".zip") then
    os_message("** Checking "..ctanzip..".zip file to send to CTAN: OK")
  else
    os_message("** Creating "..ctanzip..".zip file to send to CTAN")
    os.execute("l3build ctan > "..os_null)
  end
  os_message("** Running: l3build upload -F ctan.ann --debug")
  os.execute("l3build upload -F ctan.ann --debug >"..os_null)
  print("** Now check "..ctanzip..".curlopt file and add changes to ctan.ann")
  print("** If everything is OK run (manually): l3build upload -F ctan.ann")
  os.exit(0)
end
