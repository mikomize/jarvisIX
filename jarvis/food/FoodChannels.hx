package jarvis.food;

import yawf.redis.RedisSimpleKey;

class FoodChannels extends RedisSimpleKey<Array<String>>
{
	public function new() {
		super("FoodChannels");
	}
}