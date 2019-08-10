--[[
	function: Mysql数据库配置
	author: jim_sun
	wiki: 
]]
local config = {}

config.host = '121.0.0.1'
config.port = 3306
config.user = 'geek'
config.password = '123456abc'
config.database = 'test'
config.max_packet_size = 1024 * 1024

return config


