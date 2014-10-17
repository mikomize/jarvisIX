package jarvis.wallet;

class GlobalDepositedLogItem extends WalletLogItem
{
	@param
	private var bankerId:String;

	public function new(amount:Int, userId:String, bankerId:String) {
		super("deposited", amount, "real money deposit", userId);
		this.bankerId = bankerId;
	}

	public override function toString():String {
		return super.toString() +  userId + " deposited " + amount/100 + " (" + bankerId + ")";
	}
}