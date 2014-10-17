package jarvis;

class Prompt
{
	public var jid:String;
	public var module:String;
	public var name:String;
	public var data:Dynamic;

	public function new(jid:String, module:String, data:Dynamic = null, name:String = null) {
		this.jid = jid;
		this.module = module;
		this.name = name;
		this.data = data;
	}
}