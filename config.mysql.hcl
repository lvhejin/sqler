//创建一个名为"_boot"的宏/端点
//这个宏是私有的"在其他宏中使用"
//因为它以“_”开头。
_boot {
    // 执行建表SQL
    exec = <<SQL
				CREATE TABLE IF NOT EXISTS USERS (
					id BIGINT PRIMARY KEY AUTO_INCREMENT,
					name VARCHAR(32) NOT NULL DEFAULT '',
					email VARCHAR(128) NOT NULL DEFAULT '',
					password VARCHAR(32) NOT NULL DEFAULT '',
					time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
					data TEXT DEFAULT NULL
				);
			SQL
}

// 创建表并插入数据
addpost {
    include = ["_boot"]
    methods = ["POST"]

    validators {
		name_is_empty = "$input.name && $input.name.trim().length > 0"
		email_is_empty = "$input.email"
		password_is_empty = "$input.password"
    }

    bind {
		name = "$input.name"
        email = "$input.email"
        password = "$input.password"
		time = "$input.time"  // NOW()
        data = <<JS
					JSON.stringify({
						"name": $input.name,
						"email": $input.email
					})
				JS
    }

    exec = <<SQL
				INSERT INTO users(id,name,email,password,time, data) VALUES(default,:name,:email,:password,:time,:data) ;
			SQL
}

// adduser 宏/端点, 调用 `/adduser` 时传参 `?user_name=&user_email=` 或者 json格式 `POST` 请求传相同的字段即可。
adduser {
    validators {
        name_is_empty = "$input.name && $input.name.trim().length > 0"
        email_is_empty = "$input.email && $input.email.trim().length > 0"
        password_is_not_ok = "$input.password && $input.password.trim().length > 5"
    }

    bind {
        name = "$input.name"
        email = "$input.email"
        password = "$input.password"
    }

    methods = ["POST"]

    authorizer = <<JS
					(function(){
						log("HttpClinet：权限校验")
						token = $input.http_authorization  //传Unicode不乱码
						response = fetch("http://yourdomainname:8082/system/info/testGetParam", {  // 请求方法：GET
							headers: {
								"Authorization": token
							}
						})
						log("response.statusCode：" + response.statusCode)
						if ( response.statusCode != 200 ) {
							return false
						}
						return true
					})()
				JS

    // 可以包括之前声明的一个或多个宏
    include = ["_boot"]

    exec = <<SQL
				INSERT INTO users(name, email, password, time) VALUES(:name, :email, :password, NOW());
				-- SELECT * FROM users WHERE id = LAST_INSERT_ID();  // 不支持多语句
			SQL
}


// 列出所有数据库，并运行一个transformer函数
databases {
    // include = ["_boot"]
    exec = "SHOW DATABASES"
    transformer = <<JS
						(function(){
							// $result
							$new = [];
							for ( i in $result ) {
								$new.push($result[i].Database)
							}
							return $new
						})()
					JS
}

// 列出所有数据库中的所有表
tables {
    exec = "SELECT `table_name` as `table`, `table_schema` as `database` FROM INFORMATION_SCHEMA.tables"
    transformer = <<SQL
						(function(){
							$ret = []
							for ( i in $result ){
								$ret.push({
									table: $result[i].table,
									database: $result[i].database,
								})
							}
							return $ret
						})()
					SQL
}

// 读取n条id
data {
	
    bind {
        limit = 3
        field = "'id'"
    }
    
    exec = "SELECT id FROM users limit :limit"
}

// 将“数据库”宏和“表”宏聚合为一个宏的宏
databases_tables {
    aggregate = ["databases", "tables"]
}

users {
    exec = "SELECT * FROM users"
    transformer = <<SQL
						(function(){
							$ret = []
							for ( i in $result ){
								$ret.push({
									user: $result[i]
								})
							}
							return $ret
						})()
					SQL
}

users2 {
    exec = "SELECT * FROM users"
    transformer = <<SQL
						(function(){
							log("返回数据")
							return $result
						})()
					SQL
}


_sqlite_tables {  //定时器 + webhook
    exec = <<SQL
				SELECT `table_name` as `table`, `table_schema` as `database`
				FROM INFORMATION_SCHEMA.tables
				WHERE TABLE_SCHEMA='sql_to_api';
			SQL


    cron = "* * * * *"

    trigger {  // 请求方式：post，请求消息体：{"payload":[{"database":"sql_to_api","table":"users"}]}，注：URL有“?”webhook失效
		webhook = "http://yourdomainname:8082/system/info/testPostParam"
    }
}
