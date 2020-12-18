
local function get_specific_file(leading)
	local _, idx = leading:find('-f ')
	if idx == nil then
		_, idx = leading:find('-buildfile ')
		if idx == nil then
			_, idx = leading:find('-file ')
			if idx == nil then
				return 'build.xml'
			end
		end
	end

	leading = leading:sub(idx + 1)
	--print('--'..leading..'--')

	if leading:sub(0, 1) == '"' then
		local quote_idx = leading:find('"', 2)
		filename = leading:sub(2, quote_idx - 1)
	else
		filename = leading:sub(0, leading:find(' ') - 1)
	end

	return filename
end

local function self_test()
	local tests = {
		'',
		'ant -f "bacon.xml" stuff',
		'ant -f cheese.xml stuff',
		'ant -f test\\cheese.xml stuff',
		'ant -file ham.xml stuff',
		'ant -buildfile spam.xml stuff',
		'ant nope'
	}
	for _, txt in ipairs(tests) do
		print("Ans: -"..get_specific_file(txt)..'-')
	end
end

--self_test()
--do return end

local function get_targets(filename)
	local f = io.open(filename, "r")
	if f == nil then
		return {}
	end
	local content = f:read("*all")
	f:close()

	local targets = {}
	for tgt in content:gmatch('<target[^>]+name="([^"]+)"') do
		table.insert(targets, tgt)
	end

	return targets
end

local function get_specific(word)
	local leading = rl_state.line_buffer:sub(0, rl_state.first)
	local filename = get_specific_file(leading)
	return get_targets(filename)
end

parser = clink.arg.new_parser

local files_parser = parser({
	function(word)
        clink.match_files(word.."*", true, clink.find_dirs)
        clink.match_files(word.."*", true, clink.find_files)
        clink.matches_are_files()
	end
})

local ant_parser = parser()
ant_parser:set_flags({
	"-help", "-h",
	"-projecthelp", "-p",
	"-version",
	"-diagnostics",

	"-quiet", "-q",
	"-silent", "-S",
	"-verbose", "-v",
	"-debug", "-d",
	"-emacs", "-e",
	"-lib"..files_parser,
	"-logfile"..files_parser,
	"-l"..files_parser,
	"-logger",
	"-listener",
	"-noinput",
	"-buildfile"..files_parser,
	"-file"..files_parser,
	"-f"..files_parser,
	"-D",
	"-keep-going", "-k",

	"-propertyfile",

	"-inputhandler",
	"-find",
	"-s",
	"-nice",

	"-nouserlib",
	"-noclasspath",
	"-autoproxy",
	"-main"
})
ant_parser:set_arguments(
    { get_specific }
)
ant_parser:loop(0)

clink.arg.register_parser("ant", ant_parser)
