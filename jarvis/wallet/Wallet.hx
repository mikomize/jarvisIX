package jarvis.wallet;

import yawf.redis.RedisKey;
import yawf.redis.RedisLayer;

class Wallet extends RedisKey
{

	@inject
	public var redis:RedisLayer;


	public function new(userId:String) {
		super("wallet." + userId);
	}

	public function addFunds(amount:Int, cb:Int -> Void):Void {
		redis.client.incrby(getKey(), amount, function (err:Dynamic, balance:Int) {
			if (err != null) {
				throw err;
			}
			cb(balance);
		});
	}

	public function removeFunds(amount:Int, cb:Int -> Void):Void {
		redis.client.decrby(getKey(), amount, function (err:Dynamic, balance:Int) {
			if (err != null) {
				throw err;
			}
			cb(balance);
		});
	}

	public function getBalance(cb:Int -> Void):Void {
		redis.client.get(getKey(), function (err:Dynamic, reply:String) {
			cb(Std.parseInt(reply));
		});
	}
}