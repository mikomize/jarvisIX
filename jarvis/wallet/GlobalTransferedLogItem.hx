package jarvis.wallet;

class GlobalTransferedLogItem extends WalletLogItem
{
	@param
	private var toWhoId:String;

	public function new(amount:Int, message:String, userId:String, userId2:String) {
		super("transfer", amount, message, userId);
		toWhoId = userId2;
	}

	public override function toString():String {
		return super.toString() +  userId + " transfered " + amount/100 + " to " + toWhoId + " (" + message + ")";
	}
}