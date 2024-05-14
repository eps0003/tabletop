#include "ChatCommand.as"

class GameEndCommand : ChatCommand
{
	GameEndCommand()
	{
		super("end", "End the game");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (!isServer()) return;

		Game@ game = GameManager::get();

		if (game is null)
		{
			server_AddToChat(getTranslatedString("There is no game in progress"), ConsoleColour::ERROR, player);
			return;
		}

		game.End();

		string message = getTranslatedString("The game has been ended by {PLAYER}")
			.replace("{PLAYER}", player.getUsername());
		server_AddToChat(message, ConsoleColour::GAME);
	}
}
