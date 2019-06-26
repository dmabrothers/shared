#!/usr/bin/env lua

local socket = require "socket"
table.unpack = table.unpack or unpack

--[[ SPECS:
  remote-to-here commands:
    append-to-file fname fdata
  	truncate-file fname
  	print-message text
]]

-- utils -------------

------------------------------------------------------------------------
-- discover main IP address of machine and write to standard output, see:
-- http://forums.coronalabs.com/topic/21105-found-undocumented-way-to-get-your-devices-ip-address-from-lua-socket/
-----------------------------------------------------------------------
function getmyip ()
  local mysock = socket.udp ()
  mysock:setpeername("108.1.1.1", "565412")  -- arbitrary IP/PORT
  local ip = mysock:getsockname()
  mysock:close()
  return ip or "127.0.0.1"
end

function escspaces (str)
	local ret = string.gsub(str, "[%s%%]", function (chr)
		local byte = string.byte(chr)
		return string.format("%%%02x", byte)
	end)
	return ret
end

function unescspaces (str)
	local ret = string.gsub(str, "%%(%x%x)", function (digits)
		local num = tonumber(digits, 16)
		local chr = string.char(num)
		return chr
	end)
	return ret
end

function decodecmd (str)
	local t = {}
	for word in string.gmatch(str, "(%S+)") do
		local dcddword = unescspaces(word)
		table.insert(t, dcddword)
	end
	return table.unpack(t)
end

function encodecmd (...)
	local args = {...}
	local t = {}
	for _, a in ipairs(args) do
		local earg = escspaces(a)
		table.insert(t, earg)
	end
	return table.concat(t, " ")
end

-- commands -------------

cmds = {
	["append-to-file"] = function (sock, fname, fdata)
		local fd = assert(io.open(fname, "ab"))
		assert(fd:write(fdata))
		assert(fd:close())
	end,
	["truncate-file"] = function (sock, fname)
		local fd = assert(io.open(fname, "wb"))
		assert(fd:close())
	end,
	["print-message"] = function (sock, text)
		print(text)
	end,
}
cmds.af = cmds["append-to-file"]
cmds.tf = cmds["truncate-file"]
cmds.pm = cmds["print-message"]

-- main -------------

local LPORT = 4367

function main ()
	local lsock = assert(socket.bind("*", LPORT))
	local myip = getmyip()
	print(string.format("listening on %s:%d", myip, LPORT))
	while true do
		local sock = assert(lsock:accept())
		while true do
			local line, descr = sock:receive("*l")
			if not line then
				if descr ~= "closed" then
					print("sock:recv() error: "..tostring(descr))
				end
				sock:close()
				break
			end
			local cmd, a, b, c = decodecmd(line)
			if cmd then
				cmds[cmd](sock, a, b, c)
			end
		end
	end
end

local ok, descr = pcall(main)
if not ok then
	print(descr)
	print("press \"Enter\" to continue...")
	io.read()
end

