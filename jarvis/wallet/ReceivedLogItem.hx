package jarvis.wallet;

class ReceivedLogItem extends WalletLogItem
{
	public function new(amount:Int, message:String, userId:String) {
		super('received', amount, message, userId);
	}

	public override function toString():String {
		return super.toString() +  " " + amount/100 + " to user: " + userId + " (" + message + ")";
	}
}