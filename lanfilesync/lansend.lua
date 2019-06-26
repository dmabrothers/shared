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

local RPORT = 4367

function ismlistening (machip, port, timeout)
	local sock = assert(socket.tcp())
	assert(sock:settimeout(timeout))
	local ok, descr = sock:connect(machip, port)
	local ret
	if ok then
		ret = true
	else
		ret = false
	end
	sock:close()
	return ret
end

function discoverlan (timeout, verbose)
	assert(timeout)
	local myip = getmyip()
	local lan = string.match(myip, "(%d+%.%d+%.%d+)%.%d+")
	local t = {}
	for mach = 1, 254 do
		local machip = lan.."."..mach
		if ismlistening(machip, RPORT, timeout) then
			table.insert(t, machip)
			if verbose then
				print(machip.." is listening")
			end
		end
	end
	return t
end

function getlocalfilelist_unix ()
	local t = {}
	local pd = assert(io.popen("ls", "r"))
	for line in pd:lines() do
		table.insert(t, line)
	end
	return t
end

function sendfile (ip, port, fname)
	local sock = assert(socket.connect(ip, port))
	local fd = assert(io.open(fname, "rb"))
	local lastmsg = os.time()
	local bytessent = 0
	assert(sock:send(encodecmd("tf", fname).."\n"))
	while true do
		local data = fd:read(1024 * 512)
		if data then
			assert(sock:send(encodecmd("af", fname, data).."\n"))
			bytessent = bytessent + #data
		else
			break
		end
		local curtime = os.time()
		if not lastmsg or lastmsg ~= curtime then
			local msg1 = string.format("\"%s\": %.1f MB is sent", fname,
					bytessent / 1024 / 1024)
			local msg2 = string.format("\"%s\": %.1f MB is received", fname,
					bytessent / 1024 / 1024)
			local rcmd = encodecmd("pm", msg2)
			assert(sock:send(rcmd.."\n"))
			print(msg1)
			lastmsg = curtime
		end
	end

	local msg1 = string.format("\"%s\" is sent successfully", fname)
	local msg2 = string.format("\"%s\" is received successfully", fname)
	local rcmd = encodecmd("pm", msg2)
	assert(sock:send(rcmd.."\n"))
	print(msg1)

	sock:close()
end

function proposetoselectfromlist (t, prompt)
	local n
	while true do
		print()
		for i, v in ipairs(t) do
			print(""..i..".  "..v)
		end
		print()
		io.write(prompt)
		io.flush()
		n = tonumber(io.read())
		if n then
			break
		else
			print("not a number. try again")
		end
	end
	return t[n]
end


function main ()
	local machs = discoverlan(0.004)
	if #machs == 0 then
		print("fast scan returned no results. trying to scan slower...")
		machs = discoverlan(0.05, true)
	end
	if #machs == 0 then
		print("no machines are listening")
		os.exit(0)
	end
	local ip = assert(proposetoselectfromlist(machs,
			"enter machine number: "))
	while true do
		local fnames = getlocalfilelist_unix()
		table.insert(fnames, 1, "[exit]")
		local fname = proposetoselectfromlist(fnames,
				"enter file number: ")
		if not fname or fname == "[exit]" then
			os.exit()
		end
		print("sending file \""..fname.."\"...")
		sendfile(ip, RPORT, fname)
	end
	--local sock = assert(socket.connect(ip, RPORT))
	--sock:send(encodecmd("print-message", os.date().." message 1").."\n")
	--sock:close()
end

local ok, descr = pcall(main)
if not ok then
	print(descr)
	print("press \"Enter\" to continue...")
	io.read()
end

