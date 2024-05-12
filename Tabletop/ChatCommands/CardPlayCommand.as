#include "ChatCommand.as"

class CardPlayCommand : ChatCommand
{
	CardPlayCommand()
	{
		super("play", "Play the specified card");
		SetUsage("<card>");
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

		if (args.size() < 1)
		{
			server_AddToChat(getTranslatedString("Specify a card to play"), ConsoleColour::ERROR, player);
			return;
		}

		u16 card = parseInt(args[0]);

		if (!game.playCard(player, card))
		{
			server_AddToChat(getTranslatedString("You are unable to play the card"), ConsoleColour::ERROR, player);
			return;
		};

		game.NextTurn();

		string message = getTranslatedString("{PLAYER} played a {CARD} card")
			.replace("{PLAYER}", player.getUsername())
			.replace("{CARD}", "" + card);
		server_AddToChat(message, ConsoleColour::INFO);
	}
}
