package jarvis.wallet;

class GrantedLogItem extends WalletLogItem
{
	public function new(amount:Int, userId:String) {
		super('granted', amount, "real world currency deposit", userId);
	}

	public override function toString():String {
		return super.toString() +  " " + amount/100 + " (by the bank)";
	}
}