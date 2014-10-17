package jarvis.users;

import yawf.redis.RedisLayer;

class UsersManager
{

	@inject	
	public var redis:RedisLayer;

	public function new() {
		//...
	}

	public function getByJID(jid:String, cb:User -> Void):Void {
		var usersJIDs:UsersJIDsKey = redis.cache.get(UsersJIDsKey);
		usersJIDs.get(jid, function(id:String) {
			if (id == null) {
				cb(null);
			} else {
				getById(id, cb);
			}
		});
	}

	public function getAll(cb:Array<User> -> Void):Void {
		var users:UsersKey = redis.cache.get(UsersKey);
		var res:Array<User> = new Array<User>();


		users.getKeys(function (keys:Array<String>) {
			var onComplete:Void -> Void = yawf.Util.after(keys.length, function () {
				cb(res);
			});
			for (key in keys) {
				users.get(key, function (user:User) {
					res.push(user);
					onComplete();
				});
			}
		});
	}

	public function getById(id:String, cb:User -> Void):Void {
		var users:UsersKey = redis.cache.get(UsersKey);
		users.get(id, cb);
	}

	public function addJIDtoUser(jid:String, id:String, cb:Void -> Void):Void {
		var usersJIDs:UsersJIDsKey = redis.cache.get(UsersJIDsKey);
		usersJIDs.set(jid, id);
		usersJIDs.store(function (err, res) {
			if (err != null) {
					throw "there was some error";
			} else {
				cb();
			}
		});
	}

	public function createUser(jid:String, id:String, name:String, cb:User -> Void):Void {
		getById(id, function (u:User) {
			if (u != null) {
				throw "user: " + id + " already exists";
			}

			var user:User = new User(id, name);
			var users:UsersKey = redis.cache.get(UsersKey);
			users.set(name, user);
			users.store(function (err, res) {
				if (err != null) {
					throw "there was some error";
				} else {
					addJIDtoUser(jid, id, function () {
						cb(user);
					});
				}
			});
		});
		
	}

	public function setSecret(jid:String, secret:String, cb:User -> Void):Void {
		getByJID(jid, function (user:User) {
			user.secret = secret;
			redis.cache.storeAllDirty(function () {
				cb(user);
			});
		});
	}
}