package jarvis.wallet;

import yawf.redis.RedisObjectListKey;

class WalletTransactions extends RedisObjectListKey<WalletLogItem>
{
	public function new(userId:String) {
		super("wallet.transactions." + userId);
	}

	public function send(userId:String, amount:Int, message:String):Void {
		this.pushFront(new SendLogItem(amount, message, userId), function () {});
	}

	public function received(userId:String, amount:Int, message:String):Void {
		this.pushFront(new ReceivedLogItem(amount, message, userId), function () {});
	}

	public function granted(userId:String, amount:Int):Void {
		this.pushFront(new GrantedLogItem(amount, userId), function () {});
	}

	public function taken(userId:String, amount:Int):Void {
		this.pushFront(new TakenLogItem(amount, userId), function () {});
	}
}