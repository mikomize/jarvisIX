package jarvis.wallet;

class WalletLogItem extends LogItem
{
	@param
	public var userId:String;

	@param
	public var amount:Int;

	@param
	public var message:String;

	public function new(type:String, amount:Int, message:String, userId:String = null) {
		this.userId = userId;
		this.amount = amount;
		this.message = message;
		super(type);
	}

}