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

		u16 cards = game.getCardsToDraw(player);

		if (!game.drawCards(player))
		{
			server_AddToChat(getTranslatedString("You are unable to draw cards"), ConsoleColour::ERROR, player);
			return;
		};

		string message = getTranslatedString("{PLAYER} drew {CARDS} " + plural("card", "cards", cards))
			.replace("{PLAYER}", player.getUsername())
			.replace("{CARDS}", "" + cards);
		server_AddToChat(message, ConsoleColour::INFO);

		game.NextTurn();
	}
}
