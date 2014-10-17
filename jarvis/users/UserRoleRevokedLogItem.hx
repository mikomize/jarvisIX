package jarvis.users;

import jarvis.LogItem;

class UserRoleRevokedLogItem extends LogItem
{
	@param
	public var who:String;

	@param
	public var userId:String;

	@param
	public var role:String;

	public function new(who:String, userId:String, role:String) {
		super('roleRevoked');
		this.who = who;
		this.userId = userId;
		this.role = role;
	}

	public override function toString():String {
		return super.toString() + " " + who + " revoked " + userId + " role " + role;
	}
}