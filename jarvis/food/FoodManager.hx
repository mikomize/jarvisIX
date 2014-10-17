package jarvis.food;

import yawf.redis.RedisLayer;

class FoodManager
{
	@inject
	public var redis:RedisLayer;

	public function new() {
		//...
	}

	public function getUser(id:String, cb:FoodUser -> Void):Void {
		var fu:FoodUsers = redis.cache.get(FoodUsers);
		fu.get(id, function (foodUser:FoodUser) {
			if (foodUser == null) {
				foodUser = new FoodUser();
				fu.set(id, foodUser);
			}
			cb(foodUser);
		});
	}

	public function getChannels(cb:Array<String> -> Void):Void {
		var fc:FoodChannels = redis.cache.get(FoodChannels);
		fc.get(function(channels:Array<String>) {
			if (channels == null) {
				channels = new Array<String>();
				channels.push("all");
				fc.set(channels);
			}
			cb(channels);
		});
	}

	public function addChannel(channel:String, cb:Bool-> Void):Void {
		getChannels(function(channels:Array<String>) {
			if (channels.indexOf(channel) == -1) {
				channels.push(channel);
				redis.cache.storeAllDirty(function () {
					cb(true);
				});
			} else {
				cb(false);
			}
		});
	}



	public function subscribe(user:FoodUser, channel:String, cb:String -> Void):Void {
		getChannels(function(channels:Array<String>) {
			if (channels.indexOf(channel) == -1) {
				cb("no such channel");
				return;
			}

			if (user.channels.indexOf(channel) != -1) {
				cb("already subscribed to that channel");
				return;
			}

			user.channels.push(channel);
			redis.cache.storeAllDirty(function () {
				cb(null);
			});
		});
	}

}