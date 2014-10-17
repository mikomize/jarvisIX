package jarvis.users;

@:rtti
class User
{
	@param	
	public var id:String;

	@param
	public var secret:String;

	@param 
	public var name:String;

	@param @notNull
	public var roles:Array<String>;

	@param
	public var lastUsedJid:String;

	public function new(id:String, name:String) {
		this.id = id;
		this.name = name;
		roles = new Array<String>();
	}
}