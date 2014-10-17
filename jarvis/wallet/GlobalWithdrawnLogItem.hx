package jarvis.wallet;

class GlobalWithdrawnLogItem extends WalletLogItem
{
	@param
	private var bankerId:String;

	public function new(amount:Int, userId:String, bankerId:String) {
		super("transfer", amount, "real money withdraw", userId);
		this.bankerId = bankerId;
	}

	public override function toString():String {
		return super.toString() +  userId + " withdrawn " + amount/100 + " (" + bankerId + ")";
	}
}