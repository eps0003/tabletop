#include "ChatCommand.as"

class CardDrawCommand : ChatCommand
{
	CardDrawCommand()
	{
		super("draw", "Draw a card");
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

		if (!game.isPlayersTurn(player))
		{
			server_AddToChat(getTranslatedString("It is not currently your turn"), ConsoleColour::ERROR, player);
			return;
		}

		game.drawCard();
	}
}
