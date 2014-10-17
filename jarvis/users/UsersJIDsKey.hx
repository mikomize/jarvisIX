package jarvis.users;

import yawf.redis.RedisHashKey;

class UsersJIDsKey extends RedisHashKey<String>
{
	public function new() {
		super("usersJIDs");
	}
}