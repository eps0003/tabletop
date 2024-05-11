#include "ChatCommand.as"

const u8 MINIMUM_PLAYER_COUNT = 1; // TODO: Change to 2
const u8 MAXIMUM_PLAYER_COUNT = 6;

class GameStartCommand : ChatCommand
{
	private PlayerQueue@ queue;

	GameStartCommand(PlayerQueue@ queue)
	{
		super("start", "Start the game");

		@this.queue = queue;
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (!isServer()) return;

		if (queue.size() < MINIMUM_PLAYER_COUNT)
		{
			server_AddToChat(getTranslatedString("There are not enough players in the queue to start a game"), ConsoleColour::ERROR, player);
			return;
		}

		CPlayer@[] players = queue.remove(MAXIMUM_PLAYER_COUNT);
		GameManager::Set(Game(players));

		string message = getTranslatedString("A game has started with {PLAYERS} players!")
			.replace("{PLAYERS}", "" + players.size());
		server_AddToChat(message, ConsoleColour::GAME);
	}
}
