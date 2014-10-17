package jarvis;

extern class SimpleXmpp {

	function on(event:String, ?opt:Dynamic):Void;
	function connect(opts:Dynamic):Void;
	function disconnect():Void;
	function subscribe(friendJid:String):Void;
	function getRoster():Void;
	function send(to:String, message:String, ?group:String):Void;
	function acceptSubscription(from:String):Void;
	function unsubscribe(to:String):Void;
	function setPresence(show:String, status:String):Void;
	function probe(jid:String, cb:Dynamic -> Void):Void;
	function getVCard(jid:String, cb:Dynamic -> Void):Void;

}