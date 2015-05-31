cube = {}
cube.mod_name = "cube" -- Change this to change mod's name
dofile(minetest.get_modpath(cube.mod_name).."/configuration.txt")


minetest.register_on_mapgen_init(function(mgparams)
		minetest.set_mapgen_params({mgname="singlenode"})
end)

minetest.register_on_generated(function(minp, maxp, seed)
	-- Set up voxel manip
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local a = VoxelArea:new{
			MinEdge={x=emin.x, y=emin.y, z=emin.z},
			MaxEdge={x=emax.x, y=emax.y, z=emax.z},
	}
	local data = vm:get_data()
	local c_lights  = minetest.get_content_id((cube.light_node or "default:meselamp"))
	local c_segments = minetest.get_content_id((cube.segment_node or "default:steelblock"))
	local c_container = minetest.get_content_id((cube.container_node or "default:obsidian"))
	local c_wall = minetest.get_content_id((cube.wall_node or "default:stone"))
	local c_air = minetest.get_content_id("air")
	local distance = cube.cell_length or 12
	local x_wall = not (cube.no_x_wall or false)
	local y_wall = not (cube.no_y_wall or false)
	local z_wall = not (cube.no_z_wall or false)
	local lights = not (cube.no_lights or false)
	local limit = cube.length

	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			for y = minp.y, maxp.y do
				if not limit or (
					x <= (distance * limit)/2 and
					y <= (distance * limit)/2 and
					z <= (distance * limit)/2 and
					x >= -(distance * limit)/2 and
					y >= -(distance * limit)/2 and
					z >= -(distance * limit)/2) then
					-- First, the walls
					if (x % distance == 0 and x_wall)
						or (y % distance == 0 and y_wall)
						or (z % distance == 0 and z_wall) then
						local vi = a:index(x,y,z)
						data[vi] = c_wall
					end
					-- Following, the segments
					if x % distance == 0 and z % distance == 0
						or x % distance == 0 and y % distance == 0
						or z % distance == 0 and y % distance == 0 then
						local vi = a:index(x,y,z)
						data[vi] = c_segments
					end
					-- Finally, lamps
					if (x % (distance/2) == 0 and x % distance ~= 0
						and y % (distance/2) == 0 and y % distance ~= 0
						and z % (distance/2) == 0 and z % distance ~= 0)
						and lights then
	
						local vi = a:index(x,y,z)
						data[vi] = c_lights
					end
				end
				-- Otherwise, the external container
				if limit and ((
					((x == ((distance * limit)/2)+distance) or (x == -((distance * limit)/2)-distance))
						and ((z < ((distance * limit)/2)+distance+1) and (z > -((distance * limit)/2)-distance-1))
						and ((y < ((distance * limit)/2)+distance+1) and (y > -((distance * limit)/2)-distance-1))
				    ) or (
					((y == ((distance * limit)/2)+distance) or (y == -((distance * limit)/2)-distance))
						and ((z < ((distance * limit)/2)+distance+1) and (z > -((distance * limit)/2)-distance-1))
						and ((x < ((distance * limit)/2)+distance+1) and (x > -((distance * limit)/2)-distance-1))
				    ) or (
					((z == ((distance * limit)/2)+distance) or (z == -((distance * limit)/2)-distance))
						and ((x < ((distance * limit)/2)+distance+1) and (x > -((distance * limit)/2)-distance-1))
						and ((y < ((distance * limit)/2)+distance+1) and (y > -((distance * limit)/2)-distance-1))				
				    )) then
					local vi = a:index(x,y,z)
					data[vi] = c_container
				end
			end
		end
	end

	vm:calc_lighting()
	vm:update_liquids()
	vm:set_data(data)
	vm:write_to_map(data)
end)

