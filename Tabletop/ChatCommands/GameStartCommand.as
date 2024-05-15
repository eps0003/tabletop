#include "ChatCommand.as"

const u8 MINIMUM_PLAYER_COUNT = 1; // TODO: Set to 2
const u8 MAXIMUM_PLAYER_COUNT = 6;

class GameStartCommand : ChatCommand
{
	GameStartCommand()
	{
		super("start", "Start the game");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (!isServer()) return;

		PlayerQueue@ queue = PlayerQueue::get();

		if (queue.size() < MINIMUM_PLAYER_COUNT)
		{
			server_AddToChat(getTranslatedString("There are not enough players in the queue to start a game"), ConsoleColour::ERROR, player);
			return;
		}

		CPlayer@[] players = queue.remove(MAXIMUM_PLAYER_COUNT);
		GameManager::Set(Game(players));
	}
}
