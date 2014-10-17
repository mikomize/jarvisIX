package jarvis;

@:rtti
class LogItem
{

	@param
	public var type:String;

	@param
	public var time:Float;

	public function new(type:String) {
		this.type = type;
		time = Date.now().getTime();
	}

	public function toString():String {
		return "[" + time + "](" + type + ")";
	}
}