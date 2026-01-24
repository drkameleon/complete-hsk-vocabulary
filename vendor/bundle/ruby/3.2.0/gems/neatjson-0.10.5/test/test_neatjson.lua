local function dump(v)
	local reserved = {["and"]=1,["break"]=1,["do"]=1,["else"]=1,["elseif"]=1,["end"]=1,["false"]=1,["for"]=1,["function"]=1,["goto"]=1,["if"]=1,["in"]=1,["local"]=1,["nil"]=1,["not"]=1,["or"]=1,["repeat"]=1,["return"]=1,["then"]=1,["true"]=1,["until"]=1,["while"]=1}
	local t=type(v)
	if t=='table' then
		local s,r={},{}
		for i,v2 in ipairs(v) do s[i]=true table.insert(r,dump(v2)) end
		for k,v2 in pairs(v) do
			if not s[k] then
				if type(k)=='string' and not reserved[k] and string.match(k,'^[%a_][%w_]*$') then
					table.insert(r,k..'='..dump(v2))
				else
					table.insert(r,'['..dump(k)..']='..dump(v2))
				end
			end
		end
		return '{'..table.concat(r,', ')..'}'
	elseif t=='string' then
		return string.format('%q',v)
	else
		return tostring(v)
	end
end


package.path = '?.lua;../lua/?.lua'
local tests = require'tests'
local neatJSON = require'neatjson'
local startTime = os.clock()
local count,pass=0,0
for _,valtest in ipairs(tests) do
	local value = valtest.value
	for _,test in ipairs(valtest.tests) do
		local cmd = "neatJSON("..dump(value)..(test.opts and (", "..dump(test.opts)) or '')..")"
		local ok,err = pcall(function()
			local json, success
			if test.opts then
				local opts = {}
				for k,v in pairs(test.opts) do opts[k]=v end
				json = neatJSON(value,opts)
			else
				json = neatJSON(value)
			end

			if type(test.json)=='string' then
				success = json==test.json
			else
				-- If it's not a string, assume it's an array of acceptable string patterns
				success = false
				for _,testPattern in ipairs(test.json) do
					if json:match(testPattern) then
						success = true
						break
					end
				end
			end

			if success then
				pass = pass + 1
			else
				local expected = type(test.json)=='string' and test.json or table.concat(test.json, ' or ')
				print(cmd)
				print('EXPECTED')
				print(expected)
				print('ACTUAL')
				print(json==nil and '(nil)' or #json==0 and '(empty string)' or json)
				print('')
			end
		end)
		if not ok then
			print('Error running '..cmd)
			print(err)
			print('')
		end
		count = count + 1
	end
end
local elapsed = os.clock()-startTime
print(("%d/%d test%s passed in %.2fms (%.0f tests per second)"):format(
	pass, count,
	count==1 and '' or 's',
	elapsed,
	1000 * count/elapsed
))
