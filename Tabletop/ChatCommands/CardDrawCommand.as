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

		if (!game.drawCards(player, 1))
		{
			server_AddToChat(getTranslatedString("You are unable to draw a card"), ConsoleColour::ERROR, player);
			return;
		};

		game.NextTurn();

		string message = getTranslatedString("{PLAYER} drew a card")
			.replace("{PLAYER}", player.getUsername());
		server_AddToChat(message, ConsoleColour::INFO);
	}
}
