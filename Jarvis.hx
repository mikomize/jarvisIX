package ;

import jarvis.Client;
import jarvis.food.FoodModule;
import jarvis.wallet.WalletModule;

class Jarvis {
	public static function main() {
		var cl:Client = new Client();

		cl.registerModule(FoodModule);
		cl.registerModule(WalletModule);

		cl.start(function () {});
	}
}