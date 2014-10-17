package jarvis.wallet;

import yawf.redis.RedisObjectListKey;

class WalletGlobalTransactions extends RedisObjectListKey<WalletLogItem>
{
	public function new() {
		super("wallet.global.transactions");
	}

	public function transfered(userId:String, userId2:String, amount:Int, message:String):Void {
		this.pushFront(new GlobalTransferedLogItem(amount, message, userId, userId2), function () {});
	}

	public function deposited(userId:String, bankerId:String, amount:Int):Void {
		this.pushFront(new GlobalDepositedLogItem(amount, userId, bankerId), function () {});
	}

	public function withdrawn(userId:String, bankerId:String, amount:Int):Void {
		this.pushFront(new GlobalWithdrawnLogItem(amount, userId, bankerId), function () {});
	}
}