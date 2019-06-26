#!/usr/bin/lua

print([[<html><head><meta http-equiv="Content-type" content="text/html;charset=UTF-8"></meta></head><body>]])
for line in io.lines() do
	local fname, ayatno, ayatbody = string.match(line,
			"([^:]+):<p>(%d+)%.(.-)</p>")
	if fname then
		print(string.format("<p><a href=\"../%s\">%s</a>: %d. %s</p>", fname, fname,
				ayatno, ayatbody))
	else
		print(line)
	end
	print()
end
print("</body></html>")

