--/reids_util

--local redis_conf = require "redis_conf_2"

local redis_util = {}

--[[
	--redis命令说明 http://doc.redisfans.com/
--]]
redis_util.redis_cmd = function(shm_name, cmd , ...)
	
	if not (shm_name and cmd) then 

		return nil, -1
	end
	
	local redis_server_conf = {}
	redis_server_conf["host"] = redis_conf.host
	redis_server_conf["port"] = redis_conf.port
	redis_server_conf["connect_timeout"] = redis_conf.connect_timeout
	redis_server_conf["password"] = redis_conf.password
	
	local db_num = redis_conf.db[shm_name] --选择数据库
	if not db_num then 
		--nlog.warn("shm_name undefine, shm_name=" .. shm_name)
		return nil, -1
	end 
	
	local red = redis:new()
	red:set_timeout(redis_server_conf.connect_timeout) 

	-- connect redis
	local ok, err = red:connect(redis_server_conf.host, redis_server_conf.port)
	if not ok then
		--nlog.error("connect redis failed! " .. debug_str)
		return nil, -2
	end
	if redis_server_conf.password then 
		--redis开启了授权认证
		local times, err = red:get_reused_times()
		if not times then
			--nlog.error("redis get_reused_times:" .. tostring(err))
			return -2
		elseif times == 0 then
			local res, err = red:auth(redis_server_conf.password)
			if not res then
				--nlog.error("redis auth:" .. tostring(err))
				return -2
			end
		end
	end 

	--选择 redis_db
	local ok, err = red:select(db_num)
	if not ok then
		--nlog.error("select redis db failed! " .. debug_str)
		return nil, -3 
	end
	--exec cmd
	local ret = nil
	ret, err = red[cmd](red, ...)
	if not ret then
		--nlog.warn("exec cmd failed! ".. debug_str)
		return nil, -4
	end
	
	ok, err = red:set_keepalive(redis_conf.keepalive.idle_time, redis_conf.keepalive.pool_size)
	if not ok then
		-- 保持连接失败并不会影响实际数据
		--nlog.warn("set_keepalive failed!")
		--return nil ,-5
	end
	if ngx.null == ret or ret == "null" then 
		return nil, 0
	end 
	return ret,0           --不同命令可能返回string或table
end


return redis_util