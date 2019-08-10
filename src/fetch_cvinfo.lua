--fetch_cvinfo

ngx.req.read_body()
local data = ngx.req.get_body_data()

-------------------参数检查--------------------
local body_tb = cjson_safe.decode(data)
if not body_tb then
	yuqing_util.http_return(406, "invalid json")
end

local username = body_tb["username"]
local password = body_tb["password"]

if not username or username=="" or not password or password=="" then
	yuqing_util.http_return(406, "invalid username/password")
end

local username_md5 = ngx.md5(username)
local push_data = {}
push_data[username_md5] = {
	["username"] = username,
	["password"] = password
}

local r = redis_util.rpush(redis_conf.yq_mysql, "username", full_key, nil, unpack(push_data))
if not r then
	yuqing_util.http_return(500, "push to redis error")
end

-- 当前时间
local start_time = ngx.time()
local time_now
local ret_data
while true do
	local ret_data = redis_util.
	if ret_data then
		break
	end
	time_now = ngx.time()
	if time_now - start_time > 60 then
		break
	end
	ngx.sleep(0.5)
end

local ret_dict = {
	["status"] = "faield",
	["message"] = "",
	["type"] = "",
}
if not ret_data then
	ret_dict["status"] = "ok",
	ret_dict["type"] = "",
	ret_dict["data"] = ret_data
end

yuqing_util.http_return_json(ret_dict)

