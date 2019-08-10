--[[
	function: Mysql数据库操作
	author: jim_sun
	wiki: 
]]
local _m = {}
local DB_TIMEOUT = 10000
local DB_MAX_IDLE_TIME = 60000 --连接空闲时间
local DB_POOL_SIZE = 50 --数据库连接池大小
--返回mysql连接，未配置
function _m.new()
    local db, err = mysql:new()
    if not db then
        --common_util.http_return(500,err)
		ngx.print(err)
    end
    local ta = {mysql = db}
    return setmetatable(ta, { __index = _m }) 
end
--mysql执行sql语句
function _m.query(self,sql)
    local res1, err, errno, sqlstate = self["mysql"]:query(sql)
    if not res1 then
        return nil,false
    end
	if res1 then
        --return cjson.encode(res1),true
        return res1,true
    end
    local res_data = nil
end
function _m.set_timeout(self)
    self["mysql"]:set_timeout(DB_TIMEOUT)
end
--初始化mysql连接
function _m.init(self,dbparm)
    self:set_timeout()
    local ok, err, errcode, sqlstate = self["mysql"]:connect(dbparm)
    
    if not ok then
		ngx.print(err)
        --common_util.http_return(500,err)
    end
end

function _m.set_keepalive(self)
    local ok, err = self["mysql"]:set_keepalive(DB_MAX_IDLE_TIME, 50)
    if not ok then
		ngx.print(err)
        --common_util.http_return(500,err)
    end
end
--使用结束,放入连接池
function _m.over(self)
    self:set_keepalive()
end
return _m