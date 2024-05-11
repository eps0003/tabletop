#include "ChatCommand.as"

class TurnPrevCommand : ChatCommand
{
	TurnPrevCommand()
	{
		super("prev", "Proceed with the previous player's turn");
		AddAlias("previous");
		AddAlias("back");
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

		string message = getTranslatedString("{PLAYER}'s turn")
			.replace("{PLAYER}", game.getTurnPlayer().getUsername());
		server_AddToChat(message, ConsoleColour::INFO);
	}
}
