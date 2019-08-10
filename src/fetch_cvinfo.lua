ngx.req.read_body()
--获取请求体body数据
local data,is_ok = common_util.get_data()
local body = cjson_safe.decode(data)
--必要的参数验证
if not body then
    common_util.http_return(406,"body data is error")
end

if not common_util.check_args(2, body.username, body.password) then
    common_util.http_return(406,"body data is error")
end