package jarvis.wallet;

class TakenLogItem extends WalletLogItem
{
	public function new(amount:Int, userId:String) {
		super('taken', amount, "real world currency withdrawn", userId);
	}

	public override function toString():String {
		return super.toString() +  " " + amount/100 + " (by the bank)";
	}
}