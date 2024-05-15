#include "ChatCommand.as"

class TurnNextCommand : ChatCommand
{
	TurnNextCommand()
	{
		super("next", "Proceed with the next player's turn");
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

		game.NextTurn();
	}
}
