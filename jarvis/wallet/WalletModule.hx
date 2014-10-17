package jarvis.wallet;

import jarvis.users.UsersManager;
import jarvis.users.User;


@module("Wallet")
class WalletModule extends Module
{
	public var walletManager:WalletManager;

	public function new() {
		super();
	}

	@post
	public function init():Void {
		walletManager = injector.instantiate(WalletManager);
	}

	@requireUser
	@command("^wallet balance$")
	public function getBalance():Void {
		walletManager.getUserWallet(context.user.id).getBalance(function (balance:Int) {
			reply("wallet balance: " + balance/100);
		});
	}

	@requireUser
	@command("^wallet history$", "^wallet log$")
	public function getHistory():Void {
		walletManager.getUserTransactions(context.user.id).getAll(function (logItems:Array<WalletLogItem>) {
			var tmp:String = "";
			for (logItem in logItems) {
				tmp += logItem + "\n";
			}
			reply(tmp);
		});
	}

	@requireUser("banker")
	@command("^wallet transactions$")
	public function getGlobalHistory():Void {
		walletManager.getGlobalTransactions().getAll(function (logItems:Array<WalletLogItem>) {
			var tmp:String = "";
			for (logItem in logItems) {
				tmp += logItem + "\n";
			}
			reply(tmp);
		});
	}

	@requireUser("banker")
	@command("^wallet grant (\\w+) (\\d+(?:\\.\\d{1,2})?)$")
	public function grant(userId:String, amount:Float) {
		usersManager.getById(userId, function (user:User) {
			if (user == null) {
				reply("no such user: " + userId);
				return;
			}
			walletManager.grant(userId, context.user.id, Math.floor(amount*100), function (balance:Int) {
				reply("granted, user " + userId + " current balance: " + balance/100);
				sendToUser(user, "bank granted You " + amount + ", your current balance is " + balance/100);
			});
		});
	}

	@requireUser("banker")
	@command("^wallet take (\\w+) (\\d+(?:\\.\\d{1,2})?)$")
	public function take(userId:String, amount:Float) {
		usersManager.getById(userId, function (user:User) {
			if (user == null) {
				reply("no such user: " + userId);
				return;
			}
			walletManager.take(userId, context.user.id, Math.floor(amount*100), function (balance:Int) {
				reply("taken, user " + userId + " current balance: " + balance/100);
				sendToUser(user, "bank taken from You " + amount + ", your current balance is " + balance/100);
			});
		});
	}

	@requireUser
	@command("^wallet transfer (\\w+) (\\d+(?:\\.\\d{1,2})?)\\s?(.*)$")
	public function transfer(userId:String, amount:Float, message:String):Void {
		usersManager.getById(userId, function (user:User) {
			if (user == null) {
				reply("no such user: " + userId);
				return;
			}
			walletManager.transfer(context.user.id, userId, Math.floor(amount*100), message, function (err:String, balance:Int, balance2:Int) {
				reply("sent " + amount + " to " + userId + ", current balance: " + balance/100);
				sendToUser(user, "You have received " + amount + " from " + context.user.id + ", your current balance is " + balance2/100);
			});
		});
	}
}