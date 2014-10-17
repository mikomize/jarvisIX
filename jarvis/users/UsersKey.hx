package jarvis.users;

import yawf.redis.RedisHashKey;

class UsersKey extends RedisHashKey<User>
{
	public function new() {
		super("users");
	}
}