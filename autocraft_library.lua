-- By: Nathan Flack AKA dom416
--
-- how to use:
-- 1. create new file with any desired name
-- 2. type " require("autocraft_library") " to include this library
-- 3. on the next line initialize a table with this convention
--
--    examppleTable = {"Certus Quartz Crystal" = 100, "example label" = 40}
--
--	  These labels are case sensitive and must have corresponding crafting pattern in the system
--	  The number after the label is the amount that you want to keep in the system
-- 4. on the next line type " autoCraft(examppleTable) "
-- 5. run the file
--    it will take a while to get started
--
--	  if you take a pattern out then you will probably have to restart the program
--	  because it uses a snapshot of the crafting patterns that is taken at the start
--
--	  sidenote: if this destroys your me system im sorry..

local component = require("component")
local me = component.me_controller
--local db = component.database
local sides = require("sides")
local serialization = require("serialization")
local computer = require("computer")
local event = require("event")

function meSearch(target) 						-- parameter is name of item you want to search.
	local system = me.getItemsInNetwork()		-- returns the item table.
												-- example: meSearch("minecraft:dirt")
	for key,item in ipairs(system) do
		if (item.name == target)
		then
			return(item)
		end
	end
	print("Error: That item isnt in the network")
	return 0
end

function meSearchByLabel(target) 				-- parameter is name of item you want to search.
	local system = me.getItemsInNetwork()		-- returns the item table.
												-- example: meSearch("minecraft:dirt")
	for key,item in ipairs(system) do
		if (item.label == target)
		then
			--print(item.label.." :: "..item.size)
			return(item)
		end
	end
	print("Error: That item isnt in the network")
	return 0
end

function meSearchCraftables(target) 			-- parameter is name of item you want to search.
	local craftables = me.getCraftables()		-- returns the item table.
												-- example: meSearchCraftables("minecraft:dirt")
	for key,item in ipairs(craftables) do
		if (item.getItemStack().name == target)
		then
			--print(item.getItemStack().label.." :: "..item.getItemStack().size)
			return(item)
		end
	--print(item.getItemStack().name()) --debugging stuff
	end
	print("Error: "..target.." isnt craftable")
	return 0
end

function meSearchCraftablesByLabel(target) 		-- parameter is name of item you want to search.
	local craftables = me.getCraftables()		-- returns the item table.
												-- example: meSearchCraftables("minecraft:dirt")
	for key,item in ipairs(craftables) do
		if (item.getItemStack().label == target)
		then
			--print(item.getItemStack().label.." :: "..item.getItemStack().size)
			return(item)
		end
	--print(item.getItemStack().name()) --debugging stuff
	end
	print("Error: "..target.." isnt craftable")
	return 0
end

function meAvailableCpus() 						-- sees if there are available cpus on the network
	local Cpus = me.getCpus()					-- returns true if there are available cpus
	for key,cpu in ipairs(Cpus) do
		if (not cpu.busy)
		then
			return true
		end
	end
	return 0
end

function meStartCraft(item, amount)			--starts the crafting of an item specified from a table
	local status
	if(meAvailableCpus())
	then
		status = item.request(amount)
	end
	return status
end

function checkStatus(status, autocrafTables, patternTable)
    local requestTable = {}
    local request = false
    for label,targetAmount in pairs(autocrafTables) do
        local item = patternTable[label]										--this variable represents the crafting pattern not the item
		local item2 = meSearchByLabel(label)									--this variable has the correct size data
        if item then
            if (item2.size < targetAmount) then
				if not status or status.isDone() then
                	requestTable[item] = (targetAmount - item2.size)
                	request = true
				end
            end
        end
    end
    return request, requestTable
end

function wait(n)
    local t0 = os.clock()
    while os.clock() - t0 <= n do end
end

function autoCraft(autoTable)
    local patterns = {}

    for label2,item in pairs(autoTable) do
        patterns[label2] = meSearchCraftablesByLabel(label2)
    end
    for label2,item in pairs(patterns) do
        print(item.getItemStack().label)
    end
    local status
    for i = 1, 10000 do
        local check, requestTable = checkStatus(status, autoTable, patterns)
        if check then
            for k,v in pairs(requestTable) do
                status = meStartCraft(k,v)
                requestTable[k] = nil
            end
            if status.isDone() or status.isCanceled() then
                status = nil
            end
        end
	event.pull()
	wait()
    end
end
