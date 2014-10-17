package jarvis;

import minject.Injector;

import yawf.IConfig;
import yawf.ILogger;

import yawf.reflections.Reflection;

import yawf.redis.RedisLayer;

import jarvis.users.UsersManager;
import jarvis.users.User;

@:rtti
class Module
{

	@inject
	public var context:Context;

	@inject
	public var app:Client;

	@inject
	public var injector:Injector;

	@inject
	public var conf:IConfig;

	@inject
	public var logger:ILogger;

	@inject
	public var redis:RedisLayer;

	@inject
	public var usersManager:UsersManager;


	public function new() {
		//...
	}

	public function prompt(jid:String, data:Dynamic = null, name:String = null) {
		var moduleName:String = Reflection.getClassInfo(Type.getClass(this)).meta["module"].shift();
		var p:Prompt = new Prompt(jid, moduleName, data, name);
		app.setPrompt(p);
	}

	public function reply(msg:String) {
		redis.cache.storeAllDirty(function () {
			app.xmpp.send(context.jid, msg);
		});	
	}

	public function sendToUser(user:User, msg:String) {
		app.xmpp.send(user.lastUsedJid, msg);
	}

}