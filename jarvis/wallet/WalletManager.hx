package jarvis.wallet;

import yawf.redis.RedisLayer;

class WalletManager
{
	@inject
	public var redis:RedisLayer;

	public function new() {
		//...
	}

	public function getUserWallet(userId:String):Wallet {
		return redis.create(Wallet, [userId]);
	}

	public function getBankerWallet():Wallet {
		return redis.create(Wallet, ["banker.global"]); //XXX asuming that noone can create id with "." since id cannot contain it
	}

	public function getUserTransactions(userId:String):WalletTransactions {
		return redis.create(WalletTransactions, [userId]);
	}

	public function getGlobalTransactions():WalletGlobalTransactions {
		return redis.create(WalletGlobalTransactions);
	}

	public function transfer(fromUserId:String, toUserId:String, amount:Int, message:String,  cb:String -> Int -> Int -> Void) {
		var w1:Wallet = getUserWallet(fromUserId);
		var w2:Wallet = getUserWallet(toUserId);
		w1.removeFunds(amount, function (balance:Int) {
			if (balance < 0) {
				w1.addFunds(amount, function (ignore:Int) {
					cb("Insufficient funds", null, null);
					return;
				});
			} else {
				w2.addFunds(amount, function (balance2:Int) {
					getUserTransactions(fromUserId).send(toUserId, amount, message);
					getUserTransactions(toUserId).received(fromUserId, amount, message);
					getGlobalTransactions().transfered(fromUserId, toUserId, amount, message);
					cb(null, balance, balance2);
				});
			}
		});
	}

	public function grant(userId:String, bankerId:String, amount:Int, cb:Int -> Void) {
		var w:Wallet = getUserWallet(userId);
		w.addFunds(amount, function (balance:Int) {
			getBankerWallet().addFunds(amount, function (igonre:Int) {
				getUserTransactions(userId).granted(bankerId, amount);
				getGlobalTransactions().deposited(userId, bankerId, amount);
				cb(balance);
			});
		});
	}

	public function take(userId:String, bankerId:String, amount:Int, cb:Int -> Void) {
		var w:Wallet = getUserWallet(userId);
		w.removeFunds(amount, function (balance:Int) {
			getBankerWallet().removeFunds(amount, function (igonre:Int) {
				getUserTransactions(userId).taken(bankerId, amount);
				getGlobalTransactions().withdrawn(userId, bankerId, amount);
				cb(balance);
			});
		});
	}
}