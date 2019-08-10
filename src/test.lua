local result,boo=redis_util.redis_cmd('geek',"set","test_key","123")
ngx.print("test")
ngx.exit(200)