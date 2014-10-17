package jarvis.users;

import yawf.redis.RedisObjectListKey;

import jarvis.LogItem;

class UsersLog extends RedisObjectListKey<LogItem>
{
	public function new() {
		super("users.log");
	}
}