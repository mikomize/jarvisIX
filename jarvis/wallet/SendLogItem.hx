package jarvis.wallet;

class SendLogItem extends WalletLogItem
{
	public function new(amount:Int, message:String, userId:String) {
		super('send', amount, message, userId);
	}

	public override function toString():String {
		return super.toString() +  " " + amount/100 + " to user: " + userId + " (" + message + ")";
	}
}