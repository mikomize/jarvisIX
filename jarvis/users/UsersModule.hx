package jarvis.users;

@module("Users")
class UsersModule extends Module
{

	public var usersLog:UsersLog;

	public function new() {
		super();
	}

	@post
	public function init() {
		usersLog = injector.instantiate(UsersLog);
	}


	@command("^hello$", "^hi$")
	public function hello():Void {
		usersManager.getByJID(context.jid,	function (user:User) {
			if(user == null) {
				prompt(context.jid, null, "getId");
				reply("Hi, my name is Jarvis IX, whats your name? (only letters and numbers)");
			} else {
				reply("Welcome back " + user.id);
			}
		});
		
	}

	@requireUser
	@command("^secret$") //DEBUG
	public function secret():Void {
		reply("Our secret is: '" + context.user.secret + "'");
	}

	@requireUser
	@command("^secret (\\w+) (\\w+)$")
	public function setSecret(old:String, newOne:String):Void {
		var user:User = context.user;
		if (user.secret != old && user.secret != null) {
			reply("Wrong secret");
		} else {
			usersManager.setSecret(context.jid, newOne, function(user:User) {
				reply("OK, thats gona be our secret, dont tell anyone!");
			});
		}
	}

	@name("getId")
	@prompt("^(\\w+)$")
	public function getId(name:String):Void {
		usersManager.getById(name, function(user:User) {
			if (user != null) {
				reply("Looks like you are connected from device that i dont know yet, please provide our secret word so i can recognize you as " + name);
				prompt(context.jid, {"id": name}, "validateSecret");
			} else {
				usersManager.createUser(context.jid, name, name, function (user:User) {
					reply("Nice to meet you " + name + "!\n Now, please tell me a secret word (only letters and numbers), im gona use it whenever i'll have trouble to recognize you in future");
					prompt(context.jid, null, "getSecret");
				});
			}
		});
		
	}

	@requireUser
	@name("getSecret")
	@prompt("^(\\w+)$")
	public function getSecret(secret:String):Void {
		setSecret("", secret);
	}


	@requireUser
	@name("validateSecret")
	@prompt("^(\\w+)$")
	public function validateSecret(secret:String):Void {
		usersManager.getById(context.data.id, function(user:User) {
			if (secret == user.secret) {
				usersManager.addJIDtoUser(context.jid, user.id, function() {
					reply("Welcome back " + user.id);
				});
			} else {
				reply("Wrong secret, are you sure your id is " + user.id + "?");
			}
		});
	}

	//admin stuff
	@requireUser("admin")
	@command("^users list$")
	public function usersList():Void {
		usersManager.getAll(function (users:Array<User>) {
			var tmp:String = "";
			for (user in users) {
				tmp += user.id + (user.roles.length > 0 ? " (" + user.roles.join(", ") + ")" : "") + "\n";
			}
			reply(tmp);
		});
	}


	@requireUser("admin")
	@command("^give role (\\w+) (\\w+)$")
	public function giveRole(userId:String, role:String):Void {
		usersManager.getById(userId, function(user:User) {
			if (user == null) {
				reply("No such user");
				return;
			}
			if (user.roles.indexOf(role) != -1) {
				reply("User already has that role");
				return;
			}
			user.roles.push(role);
			redis.cache.storeAllDirty(function () {
				usersLog.pushFront(new UserRoleGivenLogItem(context.user.id, userId, role), function () {
					reply("Role '" + role +  "' given to '" + userId + "'");
				});
			});

		});
	}

	@requireUser("admin")
	@command("^revoke role (\\w+) (\\w+)$")
	public function revokeRole(userId:String, role:String):Void {
		usersManager.getById(userId, function(user:User) {
			if (user == null) {
				reply("No such user");
				return;
			}
			user.roles.remove(role);
			redis.cache.storeAllDirty(function () {
				usersLog.pushFront(new UserRoleRevokedLogItem(context.user.id, userId, role), function () {
					reply("Role '" + role +  "' revoked from '" + userId + "'");
				});
			});

		});
	}

	@requireUser("admin")
	@command("^show logs$")
	public function showLogs():Void {
		usersLog.getAll(function (logItems:Array<LogItem>) {
			var tmp:String = "";
			for (logItem in logItems) {
				tmp += logItem + "\n";
			}
			reply(tmp);
		});
	}

}