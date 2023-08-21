--[[-------------------------------------

Author: Pyro-Fire
https://patreon.com/pyrofire

Script: lib.lua
Purpose: lua.lua()

-----

Copyright (c) 2019 Pyro-Fire

I put a lot of work into these library files. Please retain the above text and this copyright disclaimer message in derivatives/forks.

Permission to use, copy, modify, and/or distribute this software for any
purpose without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

------

Written using Microsoft Notepad.
IDE's are for children.

How to notepad like a pro:
ctrl+f = find
ctrl+h = find & replace
ctrl+g = show/jump to line (turn off wordwrap n00b)

Status bar wastes screen space, don't use it.

Use https://tools.stefankueng.com/grepWin.html to mass search, find and replace many files in bulk.

]]---------------------------------------

lib=lib or {DATA_LOGIC=false,SETTINGS_STAGE=false}
if not table.contains then
	---@param table table
	---@param element any
	---@return integer|boolean
	--Usable in if statements, returns the index of the element if it exists, or false if it doesn't.
	function table.contains(table, element)
		for index, value in pairs(table) do
			if value == element then
				return index
			end
		end
		return false
	end
end
if not table.deepdeepcopy then
    ---@param t table
    ---@return table
    function table.deepdeepcopy(t)
        local copyTable = table.deepcopy(table) or {}
        for k, v in pairs(copyTable) do
            if type(v) == "table" then
                copyTable[k] = table.deepdeepcopy(v)
            end
        end
        return copyTable
    end
end

if(data)then

    local original_proto=proto
    local original_logic=logic
    local original_vector=vector
    local original_randompairs=RandomPairs
    local original_stringpairs=StringPairs
    local original_util=util
    local original_table=table
    local original_math=math
    local original_string=string
    local original_new=new
    table=table.deepcopy(table)
    math=table.deepcopy(math)
    string=table.deepcopy(string)
    
    --require("lib_global")
    --lib_global.lua functions
    do
        util=require("util")

        function istable(v) return type(v)=="table" end
        function isstring(v) return type(v)=="string" end
        function isnumber(v) return type(v)=="number" end

        function isvalid(v) return v and v.valid end


        function new(x,a,b,c,d,e,f,g) local t,v=setmetatable({},x),rawget(x,"__init") if(v)then v(t,a,b,c,d,e,f,g) end return t end

        local function toKeyValues(t) local r={} for k,v in pairs(t)do table.insert(r,{k=k,v=v}) end return r end
        local function keyValuePairs(x) x.i=x.i+1 local kv=x.kv[x.i] if(not kv)then return end return kv.k,kv.v end
        function RandomPairs(t,d) local rt=toKeyValues(t) for k,v in pairs(rt)do v.rand=math.random(1,1000000) end
            if(d)then table.sort(rt,function(a,b) return a.rand>b.rand end) else table.sort(rt,function(a,b) return a.rand>b.rand end) end
            return keyValuePairs, {i=0,kv=rt}
        end
        function StringPairs(t,d) local tbl=toKeyValues(t) if(d)then table.sort(tbl,function(a,b) return a.v>b.v end) else table.sort(tbl,function(a,b) return a.v<b.v end) end
            return keyValuePairs,{i=0,kv=tbl}
        end
        function table.RankedPairs(t,d) local tbl=toKeyValues(t) if(d)then table.sort(tbl,function(a,b) return a.k>b.k end) else table.sort(tbl,function(a,b) return a.k<b.k end) end
            return keyValuePairs,{i=0,kv=tbl}
        end

        function table.Count(t) local x=0 for k in pairs(t)do x=x+1 end return x end
        function table.First(t) for k,v in pairs(t)do return k,v end end
        function table.Random(t) local c,i=table_size(t),1 if(c==0)then return end local rng=math.random(1,c) for k,v in pairs(t)do if(i==rng)then return v,k end i=i+1 end end
        function table.HasValue(t,a) for k,v in pairs(t)do if(v==a)then return true end end return false end
        function table.GetValueIndex(t,a) for k,v in pairs(t)do if(v==a)then return k end end return false end
        function table.RemoveByValue(t,a) local i=table.GetValueIndex(t,a) if(i)then table.remove(t,i) end end
        function table.insertExclusive(t,a) if(not table.HasValue(t,a))then return table.insert(t,a) end return false end
        function table.deepmerge(s,t) for k,v in pairs(t)do if(istable(v) and s[k] and istable(s[k]))then if(table_size(v)==0)then s[k]=s[k] or {} else table.deepmerge(s[k],v) end else s[k]=v end end end
        function table.merge(s,t) for k,v in pairs(t)do s[k]=v end return s end
        function table.mergeCopy(s,t) local x={} for k,v in pairs(s)do x[k]=v end for k,v in pairs(t)do x[k]=v end return x end

        function table.KeyFromValue(t,x) for k,v in pairs(t)do if(v==x)then return k end end return false end

        function math.roundf(x,f) return math.floor((x+0.5)*10^(f or 1))/10^(f or 1) end
        function math.round(x) return math.floor(x+0.5) end
        function math.roundExEx(x,k) 
            return math.round(x*(1/k))/(1/k) 
        end -- round to nearest decimal e.g. 0.5 = nearest 0.5, 0.125=nearest 0.125?? I only really need *2 roundEx
        function math.roundEx(x,k,b) if(b)then return (x>=0 and math.ceil(x*k)/k or math.floor(x*k)/k) end return math.round(x*k)/k end -- round to nearest fraction e.g. *2 = nearest 0.5.
        function math.floorEx(x,k,b) if(b)then return (x>=0 and math.floor(x*k)/k or math.ceil(x*k)/k) end return math.floor(x*k)/k end -- round to nearest fraction e.g. *2 = nearest 0.5.
        function math.radtodeg(x) return x*(180/math.pi) end
        function math.nroot(r,n) return n^(1/r) end
        function math.sign(v) return v>0 and 1 or (v<0 and -1 or 0) end
        function math.signx(v) return v>=0 and 1 or (v<0 and -1 or 0) end
        math.uint32=4294967295

        --[[ Vector Meta ]]--

        vector={} local vectorMeta={__index=vector} setmetatable(vector,vectorMeta)
        setmetatable(vectorMeta,{__index=function(t,k) if(k=="x")then return rawget(t,"k") or t[1] elseif(k=="y")then return rawget(t,"y") or t[2] end end})
        function vectorMeta:__call(x,y) if(type(x)=="table")then return vector(vector.getx(x),vector.gety(x)) else return setmetatable({[1]=x or 0,[2]=y or 0,x=x or 0,y=y or 0},vector) end end
        function vectorMeta.__tostring(v) return "{"..vector.getx(v) .. ", " .. vector.gety(v) .."}" end
        function vector.__add(x,y) return vector.add(x,y) end
        function vector.__sub(x,y) return vector.sub(x,y) end
        function vector.__mul(x,y) return vector.mul(x,y) end
        function vector.__div(x,y) return vector.div(x,y) end
        function vector.__pow(x,y) return vector.pow(x,y) end
        function vector.__mod(x,y) return vector.mod(x,y) end
        function vector.__eq(x,y) return vector.equal(x,y) end
        function vector.__lt(x,y) return vector.getx(x)<vector.getx(y) and vector.gety(x)<vector.gety(y) end
        function vector.__le(x,y) return vector.getx(x)<=vector.getx(y) and vector.gety(x)<=vector.gety(y) end

        -- Vector Standard Lib

        vector.oppkey={x="y",y="x"}
        function vector.getx(vec) return vec[1] or vec.x or 0 end
        function vector.gety(vec) return vec[2] or vec.y or 0 end
        function vector.reverse(vx,vy) local x,y if(istable(vx))then x=vector.getx(vx) y=vector.gety(vx) else x,y=vx,vy end return vector(y,x) end
        function vector.raw(v) local x,y=vector.getx(v),vector.gety(v) return {x,y,x=x,y=y} end
        function vector.add(va,vb) if(isnumber(va))then return vector(va+vb.x,va+vb.y) elseif(isnumber(vb))then return vector(va.x+vb,va.y+vb) end local x=va.x+vb.x local y=va.y+vb.y return vector(x,y) end
        function vector.sub(va,vb) if(isnumber(va))then return vector(va-vb.x,va-vb.y) elseif(isnumber(vb))then return vector(va.x-vb,va.y-vb) end local x=va.x-vb.x local y=va.y-vb.y return vector(x,y) end
        function vector.mul(va,vb) if(isnumber(va))then return vector(va*vb.x,va*vb.y) elseif(isnumber(vb))then return vector(va.x*vb,va.y*vb) end local x=va.x*vb.x local y=va.y*vb.y return vector(x,y) end
        function vector.div(va,vb) if(isnumber(va))then return vector(va/vb.x,va/vb.y) elseif(isnumber(vb))then return vector(va.x/vb,va.y/vb) end local x=va.x/vb.x local y=va.y/vb.y return vector(x,y) end
        function vector.pow(va,vb) if(isnumber(va))then return vector(va^vb.x,va^vb.y) elseif(isnumber(vb))then return vector(va.x^vb,va.y^vb) end local x=va.x^vb.x local y=va.y^vb.y return vector(x,y) end
        function vector.mod(va,vb) if(isnumber(va))then return vector(va%vb.x,va%vb.y) elseif(isnumber(vb))then return vector(va.x%vb,va.y%vb) end local x=va.x%vb.x local y=va.y%vb.y return vector(x,y) end
        function vector.set(va,vb) va[1]=vector.getx(vb) va[2]=vector.gety(vb) va.x=vector.getx(vb) va.y=vector.gety(vb) return va end
        function vector.abs(v) return vector(math.abs(v.x),math.abs(v.y)) end
        function vector.normal(v) return v/vector.mag(v) end
        function vector.mag(v) return vector.length(v)*vector.sign(v) end
        function vector.sign(v) return vector(math.sign(vector.getx(v)),math.sign(vector.gety(v))) end
        function vector.signx(v) return vector(math.signx(vector.getx(v)),math.signx(vector.gety(v))) end
        function vector.equal(va,vb) return vector.getx(va)==vector.getx(vb) and vector.gety(va)==vector.gety(vb) end
        function vector.pos(t) if(t.x)then t[1]=t.x elseif(t[1])then t.x=t[1] end if(t.y)then t[2]=t.y elseif(t[2])then t.y=t[2] end return t end
        function vector.size(va,vb) return math.sqrt((va^2)+(vb^2)) end
        function vector.distance(va,vb) return math.sqrt((va.x-vb.x)^2+(va.y-vb.y)^2) end
        function vector.length(v) return math.sqrt(math.abs(vector.getx(v))^2+math.abs(vector.gety(v))^2) end
        function vector.floor(v) return vector(math.floor(vector.getx(v)),math.floor(vector.gety(v))) end
        function vector.round(v,k) return vector(math.round(v.x,k),math.round(v.y,k)) end
        function vector.roundEx(v,k,b) return vector(math.roundEx(vector.getx(v),k,b),math.roundEx(vector.gety(v),k,b)) end
        function vector.floorEx(v,k,b) return vector(math.floorEx(vector.getx(v),k,b),math.floorEx(vector.gety(v),k,b)) end

        function vector.ceil(v) return vector(math.ceil(v.x),math.ceil(v.y)) end
        function vector.min(va,vb) return vector(math.min(va.x,vb.x),math.min(va.y,vb.y)) end
        function vector.max(va,vb) return vector(math.max(va.x,vb.x),math.max(va.y,vb.y)) end
        function vector.clamp(v,vmin,vmax) return vector.min(vector.max(v.x,vmin.x),vmax.x) end
        function vector.area(va,vb) local t={va,vb,left_top=va,right_bottom=vb} return t end
        function vector.square(va,vb) if(isnumber(vb))then vb=vector(vb,vb) end local area={vector.add(va,vector.mul(vb,-0.5)),vector.add(va,vector.mul(vb,0.5))} area.left_top=area[1] area.right_bottom=area[2] return area end
        function vector.is_zero(vec) 
        if vec==nil then error("vector.is_zero(vec) vec is nil") end
            return vector.getx(vec)==0 and vector.gety(vec)==0 
        end
        function vector.MaxDir(vec)
            if(math.abs(vec.x)>math.abs(vec.y))then
                maxkey="x"
                if(vec.x<0)then maxdir="west" else maxdir="east" end
            else
                maxkey="y"
                if(vec.y<0)then maxdir="north" else maxdir="south" end
            end
            return maxdir,maxkey
        end

        function vector.isinbbox(p,a,b) local x,y=(p.x or p[1]),(p.y or p[2]) return not ( (x<(a.x or a[1]) or y<(a.y or a[2])) or (x>(b.x or b[1]) or y>(b.y or b[2]) ) ) end

        function vector.inarea(v,a) local x,y=(v.x or v[1]),(v.y or v[2]) return not ( (x<(a[1].x or a[1][1]) or y<(a[1].y or a[1][2])) or (x>(a[2].x or a[2][1]) or y>(a[2].y or a[2][2]))) end
        function vector.table(area) local t={} for x=area[1].x,area[2].x,1 do for y=area[1].y,area[2].y,1 do table.insert(t,vector(x,y)) end end return t end
        function vector.circle(p,z) local t,c,d={},math.round(z/2) for x=p.x-c,p.x+c,1 do for y=p.y-c,p.y+c,1 do d=math.sqrt(((x-p.x)^2)+((y-p.y)^2)) if(d<=c)then table.insert(t,vector(x,y)) end end end return t end
        function vector.circleEx(p,z) local t,c,d={},z/2 for x=p.x-c,p.x+c,1 do for y=p.y-c,p.y+c,1 do d=math.sqrt(((x-p.x)^2)+((y-p.y)^2)) if(d<c)then table.insert(t,vector(x,y)) end end end return t end
        function vector.ovalInverted(p,z,curve) local t,xz,yz={},math.round(z.x/2),math.round(z.y/2) for x=-xz,xz do for y=-yz,yz do
            if((math.abs(x^2)*math.abs(y^2)) < math.abs(xz^2)*math.abs(yz^2)*(curve or 0.5))then table.insert(t,vector(vector.getx(p)+x,vector.gety(p)+y)) end
        end end return t end
        function vector.ovalFan(p,z,curve) local t,xz,yz={},math.round(z.x/2),math.round(z.y/2) for x=-xz,xz do for y=-yz,yz do
            local deg=math.radtodeg(180-math.atan2(x,y)*math.pi)
            if(not(math.abs(x)<math.abs(math.sin(deg/180)*xz) and math.abs(y)<math.abs(math.cos(deg/180)*yz) ))then table.insert(t,vector(vector.getx(p)+x,vector.gety(p)+y)) end
        end end return t end
        function vector.oval(p,z,curve) local t,xz,yz={},math.round(z.x/2),math.round(z.y/2) for x=-xz,xz do for y=-yz,yz do
            if( (x^2)/(xz^2)+(y^2)/(yz^2) <1 )then table.insert(t,vector(vector.getx(p)+x,vector.gety(p)+y)) end
        end end return t end


        function vector.LayTiles(tex,f,area) local t={} for x=area[1].x,area[2].x do for y=area[1].y,area[2].y do table.insert(t,{name=tex,position={x,y}}) end end f.set_tiles(t) return t end
        vector.LaySquare=vector.LayTiles --alias

        function vector.LayCircle(tex,f,cir) local t={} for k,v in pairs(cir)do table.insert(t,{name=tex,position=v}) end f.set_tiles(t) return t end
        function vector.LayBorder(tex,f,a) local t={}
            for x=a[1].x,a[2].x do table.insert(t,{name=tex,position=vector(x,a[1].y)}) table.insert(t,{name=tex,position=vector(x,a[2].y)}) end
            for y=a[1].y,a[2].y do table.insert(t,{name=tex,position=vector(a[1].x,y)}) table.insert(t,{name=tex,position=vector(a[2].x,y)}) end
            f.set_tiles(t) return t
        end
        function vector.clearplayers(f,area,tpo) for k,v in pairs(players.find(f,area))do players.safeclean(v,tpo) end end
        function vector.clear(f,area,tpo) local e=f.find_entities(area) for k,v in pairs(e)do if(v and v.valid)then
            if(v.type=="character")then if(tpo)then entity.safeteleport(v,f,tpo) end else entity.destroy(v) end
        end end end
        function vector.clearFiltered(f,area,tpo) for k,v in pairs(f.find_entities_filtered{type="character",invert=true,area=area})do if(v.force.name~="player" and v.force.name~="enemy" and v.name:sub(1,9)~="warptorio")then entity.destroy(v) end end end

        function vector.snapclean(f,area) -- clean players because factorio likes to be glitchy about placing out of map tiles
            for k,v in pairs(f.find_entities_filtered{type="character",area=area})do entity.safeteleport(v.player,v.surface,v.position,true) end
        end

        vector.clean=vector.clear --alias
        vector.cleanplayers=vector.clearplayers --alias
        vector.cleanFiltered=vector.clearFiltered --alias


        function vector.GridPos(pos,g) g=g or 0.5 return vector.round(vector(pos)/g) end
        function vector.GridSnap(pos,g) g=g or 0.5 return vector.raw(vector(pos)*g) end -- *g+0.5
        function vector.Snap(pos,g) g=g or 0.5 local x=vector.GridPos(pos,g) return vector.GridSnap(x) end
        function vector.SnapAngle(pos,ang) local vx=vector.length(pos) local rad=math.rad(math.deg(math.atan2(pos.x,pos.y))+ang) return vector(vx*(math.sin(rad)),vx*(math.cos(rad)) ) end
        function vector.SnapOrientation(pos,ang) return vector.SnapAngle(pos,ang*360) end


        function vector.playsound(pth,f,x) for k,v in pairs(game.connected_players)do if(v.surface.name==f)then v.play_sound{path=pth,position=x} end end end



        --[[ Compass ]]--

        math.compass={east={1,0},west={-1,0},south={0,1},north={0,-1},se={1,1},sw={-1,1},ne={1,-1},nw={-1,-1}}
        math.compassorient={east=0.25,west=0.75,south=0.5,north=0,se=0.5-0.125,sw=0.5+0.125,ne=0.125,nw=1-0.125}
        math.compassangle=math.compassorient

        string.strcompass={north="north",east="east",south="south",west="west"} 
        string.compass={"north","east","south","west"} --old order{"east","west","south","north"}
        string.compassnum={"north","east","south","west"} -- compass by number key
        string.compasscorn={"nw","ne","sw","se"}
        string.compassall={"east","west","south","north","nw","ne","sw","se"}
        string.compassopp={east="west",west="east",north="south",south="north",nw="se",se="nw",sw="ne",ne="sw"}

        vector.compass={} for k,v in pairs(string.compass)do vector.compass[v]=vector(math.compass[v]) end
        vector.compasscorn={} for k,v in pairs(string.compasscorn)do vector.compass[v]=vector(math.compass[v]) end
        vector.compassall={} for k,v in pairs(math.compass)do vector.compassall[k]=vector(v) end
        vector.compassopp={} for k,v in pairs(string.compassopp)do vector.compassopp[k]=vector(math.compass[v]) end

        string.railcompass={["diagonal_left_bottom"]="sw",["diagonal_left_top"]="nw",["diagonal_right_bottom"]="se",["diagonal_right_top"]="ne",["vertical"]="east",["horizontal"]="south"}
        string.railcompassopp={["diagonal_left_bottom"]="diagonal_right_top",["diagonal_left_top"]="diagonal_right_bottom",["diagonal_right_bottom"]="diagonal_left_top",
            ["diagonal_right_top"]="diagonal_left_bottom",["vertical"]="vertical",["horizontal"]="horizontal"}

        string.opposite_loader={["input"]="output",["output"]="input"}
        function math.opposite_dir(d) return (d+4)%8 end



        --[[ rgb meta ]]--

        function rgb(r,g,b,a) a=a or 255 return {r=r/255,g=g/255,b=b/255,a=a/255} end


    end
    
    -- something about fonts here
    
    
    proto={}



    --lib_data.lua proto
    do
        --[[ Prototyping Data Stuff ]]--



        -- All the different things an item can be
        -- See also data.raw["item-subgroup"][k].name

        proto.ItemGroups={"item","tool","gun","ammo","capsule","armor","repair-tool","car","module","locomotive","cargo-wagon","artillery-wagon","fluid-wagon","rail-planner","item-with-entity-data"}

        -- All the different things an item can be place_result'd as
        proto.PlacementGroups={
        "accumulator","ammo-turret","arithmetic-combinator","artillery-turret","artillery-wagon","assembling-machine",
        "beacon","boiler",
        "car","cargo-wagon","character","constant-combinator","container",
        "decider-combinator",
        "electric-energy-interface","electric-turret","electric-pole",
        "fluid-turret","fluid-wagon","furnace",
        "gate","generator",
        "heat-pipe",
        "inserter",
        "lab","loader","logistic-container","logistic-robot",
        "mining-drill",
        "offshore-pump",
        "pipe","pipe-to-ground","power-switch","programmable-speaker","pump",
        "radar","reactor","roboport","rocket-silo",
        "simple-entity","simple-entity-with-force","simple-entity-with-owner","solar-panel","splitter","storage-tank",
        "train-stop","transport-belt",
        "underground-belt",
        "wall",
        }

        function proto.Recache() proto._items=nil proto._placeables=nil proto._labpacks=nil proto._used=nil proto._furnacecat=nil end

        function proto.CacheItems() local t={} for k,v in pairs(proto.ItemGroups)do for x,y in pairs(data.raw[v])do t[y.name]=y end end proto._items=t return t end
        function proto.Items(b) return (proto._items and (not b and proto._items or proto.CacheItems()) or proto.CacheItems()) end
        function proto.RawItem(n,b) return proto.Items(b)[n] end

        function proto.CacheLabPacks() local tx={} for k,v in pairs(data.raw.lab)do local vin=v.inputs for i,e in pairs(vin)do tx[e]=e end end proto._labpacks=tx return tx end
        function proto.GetLabPacks(b) return (proto._labpacks and (not b and proto._labpacks or proto.CacheLabPacks()) or proto.CacheLabPacks()) end
        function proto.LabPack(n,b) return proto.GetLabPacks(b)[n] end

        function proto.CachePlaceables() local t={} for k,v in pairs(proto.PlacementGroups)do for x,y in pairs(data.raw[v])do t[y.name]=y end end proto._placeables=t return t end
        function proto.Placeables(b) return (proto._placeables and (not b and proto._placeables or proto.CachePlaceables()) or proto.CachePlaceables()) end
        function proto.RawPlaceable(n,b) return proto.Placeables(b)[n] end -- place_result_entity
        proto.PlaceResultEntity=proto.RawPlaceable --alias

        function proto.CacheUsedRecipes() local t={}
            for k,v in pairs(data.raw.technology)do local fx=proto.TechEffects(v) for i,rcp in pairs(fx.recipes)do t[rcp]=true end end
            for k,v in pairs(data.raw.recipe)do if(proto.IsEnabled(v))then t[v.name]=true end end
        proto._used=t return t end
        function proto.UsedRecipes() return (proto._used and (not b and proto._used or proto.CacheUsedRecipes()) or proto.CacheUsedRecipes()) end
        function proto.UsedRecipe(n,b) return proto.UsedRecipes(b)[n] end
        function proto.CountUsedRecipes() return table_size(proto.UsedRecipes()) end
        function proto.CountUnsedRecipes() return table_size(data.raw.recipe)-proto.CountUsedRecipes() end

        function proto.IsAutoplaceControl(t) local dra=data.raw["autoplace-control"] if(dra[t.name] or dra[t.type] or (t.autoplace and t.autoplace.control))then return true end return false end

        function proto.HasFluidbox(t) return t.fluid_box or t.fluid_boxes or t.input_fluid_box or t.output_fluid_box end

        function proto.CacheFurnaceCats() local t={} for k,v in pairs(data.raw.furnace)do for cc in pairs(proto.CraftingCategories(v))do t[cc]=cc end end proto._furnacecat=t return t end
        function proto.FurnaceCats(b) return (proto._furnacecat and (not b and proto._furnacecat or proto.CacheFurnaceCats()) or proto.CacheFurnaceCats()) end
        function proto.FurnaceCat(n,b) return proto.FurnaceCats(b)[n] end

        function proto.Name(t) return (isstring(t) and t or (t.name and t.name or (isstring(t[1]) and t[1] or false))) end

        function proto.Fluids() return data.raw.fluid end
        function proto.Recipes() return data.raw.recipe end
        function proto.Techs() return data.raw.technology end

        function proto.IsEnabled(v) local c=false
            if(tostring(v.enabled)=="true")then c=true end
            if(v.normal and tostring(v.normal.enabled)=="true")then c=true end
            if(v.expensive and tostring(v.expensive.enabled)=="true")then c=true end
            --if(v.enabled==nil and (not v.normal or v.normal and v.normal.enabled==nil) and (not v.expensive or v.expensive and v.expensive.enabled==nil))then return true end
            return c
        end
        function proto.IsDisabled(v) local c=false
            if(tostring(v.enabled)=="false")then c=true end
            if(v.normal and tostring(v.normal.enabled)=="false")then c=true end
            if(v.expensive and tostring(v.expensive.enabled)=="false")then c=true end
            --if(v.enabled==nil and (not v.normal or v.normal and v.normal.enabled==nil) and (not v.expensive or v.expensive and v.expensive.enabled==nil))then return true end
            return c
        end

        proto.IsTechnologyEnabled=proto.IsEnabled -- alias

        function proto.IsHidden(v)
            if(tostring(v.hidden)=="true")then return true end
            if(v.normal and tostring(v.normal.hidden)=="true")then return true end
            if(v.expensive and tostring(v.expensive.hidden)=="true")then return true end
            return false
        end



        proto.Difficulties={[0]="standard",[1]="normal",[2]="expensive"}
        function proto.Normal(t) local v=t if(t.normal)then v=t.normal elseif(t.expensive)then v=t.expensive end return v end
        function proto.FetchDifficultyLayer(tx,seek)
            local t=tx if(t)then for k,v in pairs(seek)do if(t[v])then return t,0 end end end
            local t=tx.normal if(t)then for k,v in pairs(seek)do if(t[v])then return t,1 end end end
            local t=tx.expensive if(t)then for k,v in pairs(seek)do if(t[v])then return t,2 end end end
        end

        function proto.Result(t) if(t[1] and t[2])then return {type="item",name=t[1],amount=t[2]} else return t end end
        function proto.Results(tx) local t,dfc=proto.FetchDifficultyLayer(tx,{"result","results"}) if(t)then if(t.results)then rs=t.results else rs={{t.result,t.result_count or 1}} end end return rs,dfc end
        function proto.Ingredient(t) return proto.Result(t) end
        function proto.Ingredients(tx) local t,dfc=proto.FetchDifficultyLayer(tx,{"ingredients"}) return (t and t.ingredients),dfc end

        -- Fetch the raw item/object/etc
        function proto.CraftingObject(rs) local raw=proto.RawItem(rs.name) return raw or data.raw.fluid[rs.name] end
        function proto.ResultObject(t) local rs=proto.Result(t) return proto.CraftingObject(rs) end
        function proto.IngredientObject(t) local rs=proto.Ingredient(t) return proto.CraftingObject(rs) end

        function proto.TechBottles(tz) local t,dfc=proto.FetchDifficultyLayer(tz,{"unit"}) if(not t or not t.unit or not t.unit.ingredients)then return end
            local tx={} for k,v in pairs(t.unit.ingredients)do local rs=proto.Ingredient(v) tx[rs.name]=rs.name end return tx
        end
        function proto.LoopTech(n,p) p=p or {} p[n]=true local r=data.raw.technology[n] for k,v in pairs(r.prerequisites or {})do if(not p[v])then proto.LoopTech(v,p) end end return p end
        function proto.RecursiveTechBottles(g) local t={} for n in pairs(proto.LoopTech(g.name))do local c,u=data.raw.technology[n] u=proto.TechBottles(c) for k,v in pairs(u)do t[v]=true end end return t end

        function proto.TechEffects(g) local t={recipes={},items={},c=0} if(not g.effects)then return t end
            for k,v in pairs(g.effects)do local x=v.type if(x=="unlock-recipe")then table.insert(t.recipes,v.recipe) t.c=t.c+1 elseif(x=="give-item")then table.insert(x.items,v.item) t.c=t.c+1 end end
            return t
        end

        function proto.CraftingCategories(t) if(isstring(t))then return {t} end return t end
        function proto.FuelCategories(t) local x
            if(t.fuel_category)then x={} table.insert(x,t.fuel_category) end
            if(t.fuel_categories)then x=x or {} for k,v in pairs(t.fuel_categories)do table.insertExclusive(x,v) end end
            return x
        end

        function proto.MinableResults(tx)
            return {}
        end

        function proto.GetRawAutoplacers(raw,vfunc) local t={} -- data.raw.resource,data.raw.tree vfunc(v) return true_is_valid end
            for n,rsc in pairs(raw)do if(rsc.minable and proto.IsAutoplaceControl(rsc) and (not vfunc or (vfunc and vfunc(rsc))) )then
                local rs=proto.Results(rsc.minable)
                if(rs)then for k,v in pairs(rs)do local rso=proto.ResultObject(v)
                    if(not t[rso.name])then t[rso.name]={type=(rso.type~="fluid" and "item" or "fluid"),name=rso.name,proto=rsc} end
                end end
            end end
            return t
        end
        function proto.GetRawResources() return proto.GetRawAutoplacers(data.raw.resource) end
        function proto.GetRawTrees() return proto.GetRawAutoplacers(data.raw.tree) end
        function proto.GetRawRocks() return proto.GetRawAutoplacers(data.raw["simple-entity"],function(v) return v.count_as_rock_for_filtered_deconstruction end) end
        function proto.GetRaw() local t={} for k,v in pairs({proto.GetRawResources(),proto.GetRawTrees(),proto.GetRawRocks()})do for i,e in pairs(v)do table.insertExclusive(t,e) end end return t end


        function proto.Copy(a,b,x) local t=table.deepcopy(data.raw[a][b]) if(x)then table.deepmerge(t,x) end return t end

        function proto.ExtendBlankEntityItems(ent)
            local rcp=proto.Copy("recipe","nuclear-reactor")
            rcp.enabled=false rcp.name=ent.name rcp.ingredients={{"steel-plate",1}} rcp.result=ent.name

            local item=proto.Copy("item","nuclear-reactor")
            item.name=ent.name item.place_result=ent.name
            data:extend{rcp,item}
        end


        proto.VanillaPacks={red="automation-science-pack",green="logistic-science-pack",blue="chemical-science-pack",black="military-science-pack",
            purple="production-science-pack",yellow="utility-science-pack",white="space-science-pack"}

        function proto.SciencePacks(x) local t={} for k,v in pairs(x)do table.insert(t,{proto.VanillaPacks[k],v}) end return t end
        function proto.ExtendTech(t,d,s) local x=table.merge(t,d) if(s)then x.unit.ingredients=proto.SciencePacks(s) end data:extend{x} return x end

        function proto.Icons(p) if(p.icons)then return p.icons end if(p.icon)then return {{icon=p.icon,icon_size=p.icon_size}} end end
    end
    --lib_data_resize.lua proto
    do
        proto.no_resize_types={"item","item-on-ground","item-entity","item-request-proxy","tile","resource","recipe",
        "rail","locomotive","cargo-wagon","fluid-wagon","artillery-wagon","rail-chain-signal","rail-signal",
        "pipe","pipe-to-ground","infinity-pipe",
        "underground-belt","transport-belt","splitter",
        "construction-robot","logistic-robot","combat-robot","electric-pole","rocket-silo","rocket-silo-rocket",
        "offshore-pump", "heat-pipe", "tile", "constant-combinator", "decider-combinator", "arithmetic-combinator",
        "surface-defense"
        }

        function proto.ShouldResize(pr) 
            if(table.HasValue(proto.no_resize_types,pr.type))then 
                return false
            end
            if(table.HasValue(proto.no_resize_types,pr.name))then 
                return false
            end
            return true
        end


        --[[ Basic pictures and layers and offsets resizing and rescaling ]]--

        proto.offset_keys={"north_position","south_position","east_position","west_position","red","green","alert_icon_shift"} -- Table keys that are offsets
        function proto.IsImageLayer(k,v) 
            if(v.filenames)then 
                for i,e in pairs(v.filenames)do 
                    if(e:find(".png"))then 
                        return true 
                    end 
                end 
            end 
            return v.layers or (v.filename and v.filename:find(".png"))
        end
        function proto.IsOffsetLayer(k,v) 
            return (istable(v) and 
            isstring(k) and 
            (
                k:find("offset") or table.HasValue(proto.offset_keys,k)
            )
            )
        end
        function proto.IsRailLayer(k,v) return istable(v) and (v.metals or v.backplates) end
        function proto.LoopFindImageLayers(prototype,lz) 
            for key,val in pairs(prototype)do 
                if(istable(val) and key~="sound")then
                    prototype[key]=table.deepcopy(val)
                    val = prototype[key]
                    if(proto.IsImageLayer(key,val))then 
                        if(val.layers)then 
                            val.layers = table.deepcopy(val.layers)
                            for i,e in pairs(val.layers)do 
                                val.layers[i]=table.deepcopy(e)
                                e=val.layers[i]
                                table.insert(lz.images,e) 
                            end 
                        else 
                            table.insert(lz.images,val) 
                        end
                    elseif(proto.IsOffsetLayer(key,val))then 
                        table.insert(lz.offsets,val) 
                    elseif(proto.IsRailLayer(key,val))then 
                        table.insert(lz.rails,val) 
                    else 
                        proto.LoopFindImageLayers(val,lz)
                    end
                end
            end
        end
        function proto.FindImageLayers(prototype) 
            local imgz={images={},offsets={},rails={}} 
            proto.LoopFindImageLayers(prototype,imgz) 
            return imgz
        end
        function proto.MergeImageTable(img,tbl) 
            if(img.hr_version)then 
                proto.MergeImageTable(img.hr_version,tbl) 
            end 
            table.merge(img,table.deepcopy(tbl)) 
        end
        function proto.MultiplyOffsets(v,z) 
            if v[1] and istable(v[1]) and not v[2] then
                proto.MultiplyOffsets(v[1], z)
                return
            end
            --if (v[1] and istable(v[1]) and not vector.is_zero(v[1]) and not vector.is_zero(v[2])) then
            --[[local cond1 = (v[1] and istable(v[1]))
            if cond1 then
                local res, error_msg = pcall(vector.is_zero, v[1])
                if not res then
                    log("Error in proto.MultiplyOffsets: " .. error_msg)
                    log("Called vector.is_zero with: v[1], " .. serpent.block(v[1]))
                    error("Error in proto.MultiplyOffsets: " .. error_msg)
                end
            else
                goto else_block
            end
            cond1 = cond1 and not vector.is_zero(v[1])
            if cond1 then
                local res, error_msg = pcall(vector.is_zero, v[2])
                if not res then
                    log("Error in proto.MultiplyOffsets: " .. error_msg)
                    log("Called vector.is_zero with: v[2], " .. serpent.block(v[2]))
                    error("Error in proto.MultiplyOffsets: " .. error_msg)
                end
            else
                goto else_block
            end
            cond1 = cond1 and not vector.is_zero(v[2])
            if cond1 then
                goto main_logic
            else
                goto else_block
            end]]
            if (v[1] and istable(v[1]) and not vector.is_zero(v[1]) and not vector.is_zero(v[2])) then
                goto main_logic
            else
                goto else_block
            end
            ::main_logic::
                for a,b in pairs(v) do 
                    for c,d in pairs(b) do 
                        v[a][c]=d*z 
                    end 
                end 
                goto end_func
            ::else_block::
                vector.set(v,vector(v)*z) --v[1]=v[1]*z v[2]=v[2]*z
            ::end_func::
        end
        function proto.MultiplyImageSize(img,z) 
            if(img.hr_version)then 
                proto.MultiplyImageSize(img.hr_version,z) 
            end
            if(img.shift and istable(img.shift))then 
                for i,e in pairs(img.shift)do 
                    if(istable(e))then 
                        for a,b in pairs(e)do 
                            e[a]=b*z 
                        end 
                    else 
                        img.shift[i]=e*z 
                    end 
                end 
            elseif (img.shift and type(img.shift)=="number") then
                --if img.shift==0 then
                log("img.shift is a number: " .. img.shift .. " for sprite " .. img.filename)
                    local mult = (img.scale or 1)*z
                    mult = mult*(-0.5)
                    img.shift = {img.width * z * mult, img.height * -0.5 * z * mult}
                --end
            elseif (img.shift) then
                log("img.shift is not a table or number: " .. type(img.shift) .. " for sprite " .. img.filename)
            elseif img.filename then
                --log("img.shift is nil for sprite " .. img.filename)
            end
            img.scale=(img.scale or 1)*z 
            img.y_scale=(img.y_scale or 1)*z 
            img.x_scale=(img.x_scale or 1)*z
        end

        function proto.TintImages(pr,tint) local imgz=proto.FindImageLayers(pr) for k,v in pairs(imgz.images)do proto.MergeImageTable(v,{tint=tint}) end end
        function proto.MultiplyImages(pr,z) 
            local imgz=proto.FindImageLayers(pr)
            --log(serpent.block(imgz))
            for k,v in pairs(imgz.images) do
                --proto.MultiplyImageSize(v,z) 
                local state, error_msg = pcall(proto.MultiplyImageSize,v,z)
                if not state then
                    log("Error multiplying image size: "..error_msg)
                    log("Image: "..serpent.block(v))
                    error("Error multiplying image size: "..error_msg)
                end
                
            end
            for k,v in pairs(imgz.offsets) do
                --proto.MultiplyOffsets(v,z) 
                local state, error_msg = pcall(proto.MultiplyOffsets,v,z)
                if not state then
                    log("Error multiplying offsets: "..error_msg)
                    log("Offsets: "..serpent.block(v))
                    error("Error multiplying offsets: "..error_msg)
                end

            end
        end




        proto.bbox_keys={"collision_box","selection_box",  -- Table keys that are bounding boxes
            "drawing_box","window_bounding_box","horizontal_window_bounding_box","sticker_box","map_generator_bounding_box",
        }
        proto.ScalableBBoxes={"collision_box","selection_box"} -- Ordered pairs of bounding boxes we can make sized based calculations from
        function proto.BBoxIsZero(bbox) if(bbox and bbox[1][1]==0 and bbox[1][2]==0 and bbox[2][1]==0 and bbox[2][2]==0)then return true end return false end
        function proto.GetSizableBBox(pr) local b=pr[proto.ScalableBBoxes[1]] for i=2,#proto.ScalableBBoxes,1 do if(not b or proto.BBoxIsZero(b))then b=pr[proto.ScalableBBoxes[i]] else return b end end return b end
        function proto.MultiplyBBox(b,z)
            if(not proto.BBoxIsZero(b))then
                local truesize = vector(b[2])-vector(b[1])
                local roundedsize = vector.roundEx(truesize,2,true)
                local offsets = (truesize-roundedsize)/2
                local reset1 = vector(b[1])+offsets
                local reset2 = vector(b[2])-offsets
                reset1 = reset1*z
                reset2 = reset2*z
                b[1]=vector.raw(reset1-offsets)
                b[2]=vector.raw(reset2+offsets)
            end
        end
        function proto.MultiplyBBoxes(t,z)
            for _,nm in pairs(proto.bbox_keys)do
                if(t[nm] and not proto.BBoxIsZero(t[nm]))then
                    proto.MultiplyBBox(t[nm],z)
                end
            end
        end
        function proto.AddBBox(b,f) b[1]=vector.raw(vector(b[1])-vector(f)) b[2]=vector.raw(vector(b[2])+vector(f)) end
        function proto.AddBBoxes(t,f) for _,nm in pairs(proto.bbox_keys)do if(t[nm] and not proto.BBoxIsZero(t[nm]))then proto.AddBBox(t[nm],f) end end end
        function proto.BBoxSize(b) 
            return vector(b[2])-vector(b[1]) 
        end
        function proto.RecenterBBox(b) local len=proto.BBoxSize(b) b[2]=len/2 b[1]=-len/2 end


        function proto.GetBBoxOrigin(bbox) -- This is to give us +0.5 origin if the bbox needs it, but i dont think this is needed idfk
            local bbx=proto.BBoxSize(bbox)
            local bv=vector(math.round(bbx.x),math.round(bbx.y))
            local forigin=vector(bv.x%2==0 and 0.5 or 0,bv.y%2==0 and 0.5 or 0)
            return forigin
        end

        function proto.SizeTo(pr,scale) -- Resizes something purely off a simple scale, this function simply does *scale
            proto.MultiplyBBoxes(pr,scale)
            proto.MultiplyImages(pr,scale)
        end
        function proto.SizeToTile(pr,tilesize) -- Resizes something to a tile size based off its scaleable bbox. This is a simple call function to do simple image/bbox/offset resizing.
            local bbox=proto.GetSizableBBox(pr) if(not bbox or proto.BBoxIsZero(bbox))then return end
            local bbx=proto.BBoxSize(bbox)
            proto.SizeTo(pr,tilesize/math.max(bbx.x,bbx.y))
        end


        --[[ Fluidbox Counter/Scanner ]]--


        proto.fluidbox_keys={"fluid_boxes","fluid_box","input_fluid_box","output_fluid_box"}

        function proto.ScanReadFluidbox(fbox,fbc)
            if(not fbox.pipe_connections)then for k,v in pairs(fbox)do if(istable(v) and v.pipe_connections)then proto.ScanReadFluidbox(v,fbc) end end return end
            for pipeid,pipe in pairs(fbox.pipe_connections)do
                if(pipe.position or pipe.positions)then fbc.c=fbc.c+1 end
                if(pipe.position)then
                    local maxdir,maxkey=vector.MaxDir(vector(pipe.position))
                    fbc[maxdir.."ern"]=fbc[maxdir.."ern"]+1
                    fbc[maxdir.."single"]=fbc[maxdir.."single"]+1
                    local id=#fbc[maxdir]+1 
                    fbc[maxdir][id]=pipe.position
                    --fbc[maxdir][id].ref={ref=pipe.connections, id=pipeid, type="position"}
                elseif(pipe.positions)then
                    fbc["north".."single"]=fbc["north".."single"]+1
                    for i=1,4,1 do 
                        local dir=string.compassnum[i]
                        fbc[dir.."ern"]=fbc[dir.."ern"]+1
                        local id=#fbc[dir]+1
                        fbc[dir][id]=pipe.positions[i]
                        --fbc[dir][id].ref={ref=pipe.connections, id=pipeid, type="positions", ind=i}
                    end
                end
            end
        end
        function proto.ScanFluidboxCounts(pr)
            local fbc={c=0,
                north={},east={},south={},west={}, -- Table of fluidbox datas based on direction. Fluidboxes always default to north (y=-5)
                northern=0,eastern=0,southern=0,western=0, -- pipes specific separately
                northsingle=0,eastsingle=0,southsingle=0,westsingle=0, -- multiple pipes specified by one direction
            }
            --log("ScanFluidboxCounts: Scanning fluidboxes for "..pr.name)
            for _, fbn in pairs(proto.fluidbox_keys) do
                if (pr[fbn] and istable(pr[fbn])) then
                    --log("ScanFluidboxCounts: Found fluidbox "..fbn.." in "..pr.name..".")
                    proto.ScanReadFluidbox(pr[fbn], fbc)
                end
            end
            return fbc
        end


        --fbox = original box
        --vfb = replacement box
        --vecscale = bb scale? but it's SHIT and WRONG for oil refineries
        function proto.SizeFluidboxesTo(pr,vecscale,fbc)
            fbc=fbc or proto.ScanFluidboxCounts(pr)
            for dir in pairs(string.strcompass)do
                for vi,fbox in pairs(fbc[dir])do
                    --local vfb=vector.raw(vector.floorEx(vector(fbox)*vecscale,2,true))
                    local vfb=vector.raw(vector.floorEx(vector(fbox)*vecscale,4,true)) -- trying to fix boilers

        --[[
                    if (proto.dbg) then
                        log("\n OLDBOX: ".. serpent.block(fbox) ..
                        " \n NEWBOX: " .. serpent.block(vfb) ..
        --                   " \n ORIGIN: " .. serpent.block(origin) ..
        --                   " \n BBOX: " .. serpent.block(bbround) ..
                        " \n VECSCALE: " .. serpent.block(vecscale)
                        )
                    end
        --]]
                    vector.set(fbox,vfb)

                end
            end
        end




        function proto.ShiftFluidboxCenters(pr,bbox,fbc) -- Shift fluidboxes more towards the center if they're off-center as a sum.
            fbc=fbc or proto.ScanFluidboxCounts(pr)
            local needPrint = 0
            local shifts={north=vector(),east=vector(),south=vector(),west=vector()}
            for dir, vec in pairs(shifts) do
                for ktd, pos in pairs(fbc[dir]) do --if(proto.dbg and dir=="north")then error("northtest" .. serpent.block(pos)) end
                    shifts[dir] = shifts[dir] +
                        vector(((dir == "north" or dir == "south") and vector.getx(pos) or 0),
                            ((dir == "east" or dir == "west") and vector.gety(pos) or 0))
                end
                
                if (not vector.is_zero(shifts[dir])) then 
                    if needPrint>0 then log("ShiftFluidboxCenters:1["..pr.name.."] "..dir.." shift: "..serpent.block(shifts[dir])) end
                    shifts[dir] = shifts[dir] / fbc[dir .. "ern"] 
                    if needPrint>0 then log("ShiftFluidboxCenters:2["..pr.name.."] "..dir.." shift: "..serpent.block(shifts[dir])) end
                end
            end
        --if(proto.dbg)then error(serpent.block(shifts) .. ", " .. serpent.block(fbc)) end

            for dir,vec in pairs(shifts)do
                if needPrint>0 then log("ShiftFluidboxCenters:3["..pr.name.."] "..dir.." shift: "..serpent.block(vec)) end
                for vi,fbox in pairs(fbc[dir])do
                    local vfb=vector(fbox)-vec 
                    vector.set(fbox,vfb) 
                end
            end

        end

        local function goodpipetable(size)
            local offset_t = {}
            local i = 1

            while (size > 0) do
                offset_t[i] = -((size - 1) / 2)
                offset_t[i + 1] = (size - 1) / 2
                size = size - 2
                i = i + 2
            end
            return offset_t
        end


        --Taken from user HonkTown on the factorio discord
        --Small modifications / adaptations by chp2001
        local function available_centered_pipe_positions(collision_box)
            --only works with symmetric collision_box
            collision_box = collision_box or
                --[[ boiler ]] --{{-1.3, -.9}, {1.3, .9}}
                --[[ asm ]] {{-1.4, -1.4}, {1.4, 1.4}}
            if not (type(collision_box[1]) == "table") then
                collision_box = {{-collision_box[1]/2, -collision_box[2]/2}, {collision_box[1]/2, collision_box[2]/2}}
            end
            
            --for ind, orderedpair in pairs(collision_box) do
            --    for ind2, val in pairs(orderedpair) do
            --        collision_box[ind][ind2] = 2 * val 
            --    end
            --end
        
            local k, left_top = next(collision_box)
            local _, right_bottom = next(collision_box, k)
            --round up to nearest .5
            local width_half = math.floor( -(left_top.x or left_top[1]) * 2 + 1/2) / 2
            local height_half = math.floor( -(left_top.y or left_top[2]) * 2 + 1/2) / 2
        
            local available_positions = {}
        
            local pipe_x_for_y = width_half + 1/2
            local pipe_y_for_x = height_half + 1/2
        
            local pipe_x = width_half - 1/2
            local pipe_y = height_half - 1/2
            
            available_positions.north = {}
            available_positions.east = {}
            available_positions.south = {}
            available_positions.west = {}
            --north
            local northdir = -1
            local eastdir = 1
            for i = -northdir*pipe_x, northdir*pipe_x, northdir do
                --print(i..","..-pipe_y_for_x)
                table.insert(available_positions.north, {i, -pipe_y_for_x})
            end
        
            --east
            for i = -eastdir*pipe_y, eastdir*pipe_y, eastdir do
                --print(pipe_x_for_y..","..i)
                table.insert(available_positions.east, {pipe_x_for_y, i})
            end
        
            --south
            for i = -northdir*pipe_x, northdir*pipe_x, northdir do
                --print(i..","..pipe_y_for_x)
                table.insert(available_positions.south, {i, pipe_y_for_x})
            end
        
            --west
            for i = -eastdir*pipe_y, eastdir*pipe_y, eastdir do
                --print(-pipe_x_for_y..","..i)
                table.insert(available_positions.west, {-pipe_x_for_y, i})
            end
            
            --error("available_centered_pipe_positions: "..serpent.block(available_positions))
            return available_positions
        end

        local function sidewidthFromDirection(side,bb)
            --bb in this instance is {width,height}
            if side == "north" or side == "south" then
                return bb[1]
            else
                return bb[2]
            end
        end
        local function shifttomatchscale(pos, scale)
            return vector(pos) * (scale*2 + 5) / 7
        end
        local function matchOriginalPositionToScaledPosition(fbc, side, ind, scale, bbnew)
            local original_size = proto.resizedata.originalsize
            local original_valid_positions = available_centered_pipe_positions(bbnew)
            local function checkDist(pos1, pos2)
                return math.sqrt((pos1[1] - pos2[1])*(pos1[1] - pos2[1]) + (pos1[2] - pos2[2])*(pos1[2] - pos2[2]))
            end
            local checkPositions = original_valid_positions[side]
            local original_pos = fbc[side][ind]
            local test_pos = shifttomatchscale(original_pos, scale)
            local best_ind = 1
            local best_dist = checkDist(test_pos, checkPositions[1])
            for i, pos in pairs(checkPositions) do
                local dist = checkDist(test_pos, pos)
                if dist < best_dist then
                    best_dist = dist
                    best_ind = i
                end
            end
            -- local report = ""
            -- report = report .. "Original position was " ..serpent.line(original_pos) .. "\n"
            -- report = report .. "Best position was " ..serpent.line(checkPositions[best_ind]) .. "\n"
            -- report = report .. "Best distance was " .. best_dist .. "\n"
            -- report = report .. "Available positions were " ..serpent.block(checkPositions) .. "\n"
            -- error(report)
            
            return best_ind
        end

        function proto.resizethefluidboxforrealthistime(pr, fbc, pipescale, bbnew)
            local fbc=fbc or proto.ScanFluidboxCounts(pr)
            local needPrint = 0
            local function logif(s,priority)
                if not priority then priority=1 end
                if needPrint>=priority then log(s) end
            end
            local goalsize = pipescale
            if goalsize % 2 == 0 and goalsize > 2 then goalsize = goalsize - 1 end
            --if pr.type =="boiler" then goalsize = goalsize + 1 end
            local sidescale = math.max(fbc.northern,fbc.southern,fbc.eastern,fbc.western) or 1
            local scalechange = sidewidthFromDirection("north",bbnew) / sidewidthFromDirection("north",proto.resizedata.originalsize)
            --local pipeoffsets = goodpipetable(sidescale)
            local dirs = {"north","south","east","west"}
            local available_positions = available_centered_pipe_positions(bbnew)
            --log("[chp2001]:["..pr.name.."] "..serpent.block(proto.resizedata.originalsize).." -> "..serpent.block(bbnew))
            local newpipes_main = {north={},south={},east={},west={}}
            for _,dir in pairs(dirs) do
                local pipes = fbc[dir]
                local side = dir
                local newpipes = newpipes_main[dir]
                if #pipes == 0 then goto continue end
                for ind, pipe in pairs(pipes) do
                    --log("[chp2001]:["..pr.name.."] "..dir.."["..ind.."]")--.." "..serpent.block(pipe).." -> "..serpent.block(newpos))
                    local best_ind = matchOriginalPositionToScaledPosition(fbc, side, ind, pipescale, bbnew)
                    local newpos = available_positions[side][best_ind]
                    fbc[dir][ind][1] = newpos[1]
                    fbc[dir][ind]["x"] = fbc[dir][ind][1]
                    fbc[dir][ind][2] = newpos[2]
                    fbc[dir][ind]["y"] = fbc[dir][ind][2]
                end
                ::continue::
            end
        end


        function proto.AutoResize(pr,scale)
            --if(table.HasValue(proto.no_resize_types,pr.type))then return end
            --log("AutoResize: " .. pr.name .. " " .. pr.type)
            local goalsize=scale
            local bbox=proto.GetSizableBBox(pr) if(not bbox or proto.BBoxIsZero(bbox))then return end
            
            local truesize = proto.BBoxSize(bbox)
            local bbsize=vector.roundEx(truesize,2,true)
            proto.resizedata = proto.resizedata or {}
            proto.resizedata.originalsize = table.deepcopy(bbsize)
            proto.cache_resizedata = proto.cache_resizedata or {}
            --log("AutoResize: bbsize: " .. serpent.block(bbsize) .. " goalsize: " .. serpent.block(goalsize))
            --local bbpipe=bbsize+vector(1,1) -- The size the bbox would be if it were 1 tile bigger (fluidbox size = {-0.5,-0.5},{0.5,0.5} bigger than regular bbox.)
            local bbpipe=bbsize
            local bbmax=math.ceil(math.max(bbsize.x,bbsize.y))
            goalsize = scale * bbmax
            local pipemax=math.ceil(math.max(bbpipe.x,bbpipe.y))
            if(pr.type=="character" or pr.type=="character-corpse")then goalsize=0.75 end
            local fbc=proto.ScanFluidboxCounts(pr)
            local before_data = nil
            local after_data = nil
            --only want space exploration entities right now
            --they have names starting with "se-"
            if pr.name:find("industrial") == nil then
                proto.cache_resizedata[pr.name] = {}
            end
            if not proto.cache_resizedata[pr.name] then
                before_data = {
                    fbc=table.deepcopy(fbc),
                    bbox=table.deepcopy(bbox),
                    bbsize=table.deepcopy(bbsize),
                    bbpipe=table.deepcopy(bbpipe),
                    bbmax=table.deepcopy(bbmax),
                    pipemax=table.deepcopy(pipemax)}
            end

            --if(pr.name=="furnace")then proto.dbg=true end
            --if(pr.name=="boiler")then proto.dbg=true end
            --if(pr.name=="pumpjack")then proto.dbg=true end
            --if(pr.name=="offshore-pump")then proto.dbg=true end
            --if(pr.name=="oil-refinery")then proto.dbg=true end
            --if(pr.name=="chemical-plant")then proto.dbg=true end
            --if(pr.name=="pump")then proto.dbg=true end



            if(fbc.c>0)then -- Do the fluidbox thing
                --log("AutoResize: "..pr.name.." has "..fbc.c.." fluidboxes")
                --log("AutoResize: fbc: " .. serpent.block(fbc))
                local pipesizemin=math.max(goalsize,fbc.northern,fbc.southern,fbc.eastern,fbc.western) -- The minimum tile-size we can be due to fluidboxes
                --log("AutoResize: pipesizemin: " .. serpent.block(pipesizemin))
                --log("AutoResize: goalsize was " .. goalsize .. " now " .. pipesizemin)
                goalsize=pipesizemin
                local pipesize=goalsize+1 -- the goal tile-size which we would use if we were resizing to the size of the bbox if it were 1 tile bigger in all directions

                local pipescale=vector(pipesize,pipesize)/pipemax
                local bbnewpipe=bbpipe*pipescale
                --local truebbsize
                local bbnew=bbsize*(scale)
                --log("AutoResize: pipescale: " .. serpent.block(pipescale))
                --log("AutoResize: bbnewpipe: " .. serpent.block(bbnewpipe))
                --log("AutoResize: bbnew: " .. serpent.block(bbnew))


                proto.ShiftFluidboxCenters(pr,truesize,fbc) -- Shift fluidboxes to center of new bbox
        --		proto.SizeFluidboxesTo(pr,pipescale,fbc) -- Shift positions of fluidboxes
                proto.resizethefluidboxforrealthistime(pr, fbc, goalsize, bbnew)
        --[[
                if(proto.dbg)then
                    error(
                        "\nDEBUG: Size " .. goalsize .. ", bbmax: " .. pipemax .. ", scale: " .. goalsize/bbmax .. ", Pipescale: " .. serpent.block(pipescale) ..
                        "\nData:\n"..serpent.block(pr)..
                        "\n---------------FB----------------\n"..
                        serpent.block(fbc)..
                        "\n"..""
                    )
                end
        --]]
            end

            proto.SizeTo(pr,scale)

            if not proto.cache_resizedata[pr.name] then
                local new_bbox = proto.GetSizableBBox(pr)
                local new_bbsize = vector.roundEx(proto.BBoxSize(new_bbox),2,true)
                local new_bbpipe = new_bbsize
                local new_bbmax = math.ceil(math.max(new_bbsize.x,new_bbsize.y))
                local new_pipemax = math.ceil(math.max(new_bbpipe.x,new_bbpipe.y))

                after_data = {
                    fbc=table.deepcopy(fbc),
                    bbox=table.deepcopy(new_bbox),
                    bbsize=table.deepcopy(new_bbsize),
                    bbpipe=table.deepcopy(new_bbpipe),
                    bbmax=table.deepcopy(new_bbmax),
                    pipemax=table.deepcopy(new_pipemax),
                }
                proto.cache_resizedata[pr.name] = {before=before_data, after=after_data}
            end
            if pr.name:find("industrial") == nil then
                proto.cache_resizedata[pr.name] = nil
            end
            local dkey = nil
            if pr.vector_to_place_result then
                for dkey in pairs(pr.vector_to_place_result) do
                    pr.vector_to_place_result[dkey] = pr.vector_to_place_result[dkey] * goalsize/bbmax
                end
            end
        end

        function proto.AutoResize_by_scale(pr,scale)
            --if(table.HasValue(proto.no_resize_types,pr.type))then return end
            --local goalsize=tilesize
            -- local bbox=proto.GetSizableBBox(pr) 
            -- if(not bbox or proto.BBoxIsZero(bbox))then return end
            -- local bbsize=vector.roundEx(proto.BBoxSize(bbox),2,true)
            -- --local bbpipe=bbsize+vector(1,1) -- The size the bbox would be if it were 1 tile bigger (fluidbox size = {-0.5,-0.5},{0.5,0.5} bigger than regular bbox.)
            -- local bbpipe=bbsize
            -- local bbmax=math.ceil(math.max(bbsize.x,bbsize.y))
            -- local goalsize = math.ceil(bbmax * scale)
            --log("AutoResize_by_scale: " .. pr.name .. " " .. pr.type .. " scale: " .. scale .. " goalsize: " .. serpent.block(goalsize))
            proto.AutoResize(pr, scale)
        end
    end
    --lib.resize=require("lib_data_resize")
    --if(lib.DATA_LOGIC)then lib.logic=require("lib_data_logic") end
    
    --proto=lib.proto for k,v in pairs(lib.resize)do proto[k]=v end
    --logic=lib.logic
    
    function lib.lua()
        -- This is special thanks to other people who were relying on my functions even though they shouldn't have existed
        -- and were wondering why their non-existent functions were only partially working
        proto=original_proto
        logic=original_logic
        vector=original_vector
        util=original_util
        new=original_new
        RandomPairs=original_randompairs
        StringPairs=original_stringpairs
        table=original_table
        math=original_math
        string=original_string
    end
    
    return
    
else
    util = require("util")
end
    
    