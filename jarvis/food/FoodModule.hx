package jarvis.food;


@module("Food")
class FoodModule extends Module
{
	public var foodManager:FoodManager;

	public function new() {
		super();
	}

	@post
	public function init() {
		foodManager = injector.instantiate(FoodManager);
	}

	@command("^food channels$")
	public function getChannelsList():Void {
		foodManager.getChannels(function(channels:Array<String>) {
			reply("available channels:\n" + channels.join(", "));
		});
	}

	@requireUser
	@command("^food status$")
	public function myChannelsList():Void {
		foodManager.getUser(context.user.id, function (foodUser:FoodUser) {
			if (foodUser.channels.length == 0) {
				reply("You have not subscribed to any channels! Type food channels fot available channels.");
			} else {
				reply("You have subscribed to channels:\n" + foodUser.channels.join(", "));
			}
		});
	}

	@command("^food channels add (\\w+)$")
	public function addChannel(channel:String):Void {
		foodManager.addChannel(channel, function(res:Bool) {
			if(res) {
				reply("added channel '" + channel + "'");
			} else {
				reply("channel already exists");
			}
		});
	}

	@requireUser
	@command("^food subscribe (\\w+)$")
	public function subscribe(channel:String):Void {
		foodManager.getUser(context.user.id, function (foodUser:FoodUser) {
			foodManager.subscribe(foodUser, channel, function (err:String) {
				if (err == null) {
					reply("subscribed to '" + channel + "'");
				} else {
					reply(err);
				}
			});
		});
	}
}