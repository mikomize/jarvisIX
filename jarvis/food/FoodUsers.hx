package jarvis.food;

import yawf.redis.RedisHashKey;

class FoodUsers extends RedisHashKey<FoodUser>
{
	public function new() {
		super("FoodUsers");
	}
}