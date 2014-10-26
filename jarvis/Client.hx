package jarvis;

import js.Node;

import yawf.typedefs.Nconf;
import yawf.typedefs.Winston;

import yawf.ILogger;
import yawf.IConfig;

import yawf.redis.RedisClient;
import yawf.redis.Redis;
import yawf.redis.RedisLayer;

import yawf.reflections.Reflection;
import yawf.reflections.ClassInfo;
import yawf.reflections.ClassFieldInfo;
import yawf.reflections.FuncArg;

import yawf.node.Util;
import yawf.ObjectMapper;

import jarvis.users.User;
import jarvis.users.UsersModule;
import jarvis.users.UsersManager;

import minject.Injector;

class Client
{
	private var conf:Nconf;

	private var logger:WinstonLogger;

	private var mainConfigPath:String;
	private var envConfigPath:String;

	private var redisClient:RedisClient;

	public var xmpp:SimpleXmpp;

	private var modules:Map<String, Class<Dynamic>>;

	private var prompts:Map<String, Prompt>;

	private function getDefaults():Dynamic {
		return {
			"jid": "username@gmail.com",
			"password": "password",
			"host": "talk.google.com",
			"presence": "Ready to go!",
        	"port": 5222,
			"redis": {
				"db": 4,
				"ip": "127.0.0.1",
				"port": 6379,
				"options": {}
			},
			"loggers": {
				"Console": {
					"level": "silly",
					"colorize": true,
					"timestamp": true
				}
			}
		};
	}

	//@see https://github.com/flatiron/nconf
	private function setUpConf():Void {
		conf = Node.require("nconf");
		conf.env();
		var env:String = conf.get("APP_CONFIG");
		var configs:String = conf.get("APP_CONFIGS_DIR");
		if (configs == null) {
			configs = "configs/";
		}
		if (env != null) {
			envConfigPath = Util.resolvePath(configs + env + ".json");
			if(Util.fileExists(envConfigPath)) {
				conf.add("env", {type: "file", file: envConfigPath});
			} else {
				throw "specified config: " + envConfigPath + " does not exists";
			}
		}

		mainConfigPath = Util.resolvePath(configs + "main.json");
		conf.add("main", {type: "file", file: mainConfigPath});
		conf.defaults(getDefaults());
		conf.set("configs", configs);
	}

	private function setUpRedis(cb:Void -> Void):Void {
		if (conf.get("redis") != null) {
			redisClient = Redis.newClient(conf.get("redis:port"), conf.get("redis:ip"), conf.get("redis:options"));
			logger.info("redis connected to: " + conf.get("redis:ip") + ":" + conf.get("redis:port"));
			var redisDb:Int = conf.get("redis:db"); 
			if (redisDb != null) {
				redisClient.select(redisDb, function(err:Dynamic, res:String) {
					logger.info("redis db set to: " + redisDb);
					cb();
				});
				return;
			} 
		} 
		cb();
	}

	//@see https://github.com/flatiron/winston
	//@see https://github.com/indexzero/winston-syslog
	private function createLogger():Void {
		var winston:Winston = Node.require('winston');
		Node.require('winston-syslog').Syslog;
		var transports:Array<Dynamic> = new Array<Dynamic>();
		var loggers:Dynamic = conf.get('loggers');
		for (field in Reflect.fields(loggers)) {
			var loggerClass:Class<Dynamic> = Reflect.field(winston.transports, field);
			var loggerConf:Dynamic = Reflect.field(loggers, field);
			//resolving path in config
			if (Reflect.hasField(loggerConf, "filename")) {
				var filename:String = Reflect.field(loggerConf, "filename");
				filename = Util.resolvePath(filename);
				Reflect.setField(loggerConf, "filename", filename);
			}
			transports.push(Type.createInstance(loggerClass, [loggerConf]));
		}
		logger = Type.createInstance(winston.Logger, [{
			transports : transports
		}]);
	}


	public function new() {
		modules = new Map<String, Class<Dynamic>>();
		prompts = new Map<String, Prompt>();
		setUpConf();
		createLogger();
		logger.info("configs loaded from: " + Util.resolvePath(conf.get("configs")));
		if (envConfigPath != null) {
			logger.info("specified config loaded from: " + envConfigPath);
	 	}

	 	registerModule(UsersModule);

	}

	public function registerModule(c:Class<Dynamic>):Void {
		var classInfo:ClassInfo = Reflection.getClassInfo(c);
		for(name in classInfo.meta) {
			var moduleName:String = classInfo.meta.get("module")[0];
			if (moduleName == null) {
				throw "no module name, use @module annotation";
			}
			modules.set(moduleName, c);
		}
	}

	public function start(cb:Void -> Void) {

		xmpp = Node.require("simple-xmpp");
		setUpRedis(function():Void {

			var opts:Dynamic = {
				"jid": conf.get("jid"),
				"password": conf.get("password"),
				"host": conf.get("host"),
				"port": conf.get("port")
			};

			xmpp.on("online", function(data) {
				logger.info("conntected as: " + data.jid.local + "@" + data.jid.domain);
				xmpp.setPresence('chat', conf.get("presence"));
				xmpp.getRoster();
			});

			xmpp.on("chat", function (from, message) {
				process(from, message);
			});

			xmpp.on("subscribe", function (from) {
				logger.info("auto subscribing: " + from);
				xmpp.acceptSubscription(from);
			});

			xmpp.on("error", function (error) {
				logger.error(error);
			});

			xmpp.on("close", function () {
				logger.error("connection closed, reconnecting...");
				xmpp.connect(opts);				
			});

			xmpp.connect(opts);
			cb();
		});
	}

	private function createInjector(jid:String):Injector {
		var injector:Injector = new Injector();
		injector.mapValue(Injector, injector);
		injector.mapValue(IConfig, conf);
		injector.mapValue(ILogger, logger);
		injector.mapValue(Client, this);
		var r:RedisLayer = new RedisLayer(redisClient);
		injector.injectInto(r);
		injector.mapValue(RedisLayer, r);

		var usersManager:UsersManager = new UsersManager();
		injector.mapValue(UsersManager, usersManager);

		injector.injectInto(usersManager);
		return injector;
	}

	private function process(jid:String, raw:String):Void {
		var prompt:Prompt = prompts.get(jid);
		if( prompt != null) {
			logger.verbose("running prompt");
			var classInfo:ClassInfo = Reflection.getClassInfo(modules[prompt.module]);
			for (field in classInfo.getFieldsByMeta("prompt")) {
				for (rStr in field.meta.get("prompt")) {
					var r:EReg = new EReg(rStr, "");
					var name:String =  field.meta["name"] != null ? field.meta["name"][0] : null;
					trace(name);
					trace(prompt.name);
					if(r.match(StringTools.trim(raw)) && (prompt.name == null || name == prompt.name) ) {
						logger.verbose("matched prompt: " + rStr);
						call(jid, raw, classInfo, field, r, prompt.data);
						removePrompt(jid);
						return;
					}
				}
			}
			xmpp.send(jid, "sorry, im not sure what do you want from me :(");
			return;
		}
		logger.verbose("checking: '" + raw + "'");
		for (module in modules.keys()) {
			logger.verbose("module: " + module);
			var classInfo:ClassInfo = Reflection.getClassInfo(modules[module]);
			for (field in classInfo.getFieldsByMeta("command")) {
				for (rStr in field.meta.get("command")) {
					var r:EReg = new EReg(rStr, "");
					if(r.match(StringTools.trim(raw))) {
						logger.verbose("matched command: " + rStr);
						call(jid, raw, classInfo, field, r);
						return;
					}
				}
			}

		}
		xmpp.send(jid, "sorry, im not sure what do you want from me :(");
		
	}

	private function call(jid:String, raw:String, classInfo:ClassInfo, field:ClassFieldInfo, r:EReg, data:Dynamic = null):Void {
		
		var injector:Injector = createInjector(jid);
		var context:Context = new Context();
		context.jid = jid;
		context.raw = raw;
		context.data = data;
		injector.mapValue(Context, context);

		var pleaseDo = function () {
			var m:Dynamic = injector.instantiate(classInfo.c);
			var args:Array<Dynamic> = new Array<Dynamic>();
			var funcArgs:List<FuncArg> = Reflection.getFuncArgs(field);
			var i:Int = 1;
			for (arg in funcArgs) {
				args.push(ObjectMapper.fromPlainObjectUntyped(r.matched(i), arg.type));
				i++;
			}
			logger.info("calling: " + classInfo.path + "." + field.name + "(" + args.toString() + ")");
			Reflect.callMethod(m, Reflect.field(m, field.name), args);
		};

		var roles:Array<String> = field.meta["requireUser"];
		if (roles!= null) {
			var usersManager:UsersManager = injector.instantiate(UsersManager);
			usersManager.getByJID(jid, function (user:User) {
				if (user != null) {
					if (roles.length == 0 || userHasRole(user, roles)) {
						user.lastUsedJid = jid;
						trace(user.lastUsedJid);
						context.user = user;
						pleaseDo();	
					} else {
						xmpp.send(jid, "Permission denied");
					}
					
				} else {
					xmpp.send(jid, "Sorry, this command requires me to know you, please say hi to introduce yourself.");
				}
				
			});
		} else {
			pleaseDo();
		}
	}

	public function userHasRole(user:User, roles:Array<String>):Bool {
		for (role in roles) {
			if (user.roles.indexOf(role) != -1) {
				return true;
			}
		}
		return false;
	}

	public function setPrompt(prompt:Prompt):Void {
		prompts[prompt.jid] = prompt;
	}

	public function removePrompt(jid:String):Void {
		prompts.remove(jid);
	}


}