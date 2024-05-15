#include "ChatCommand.as"

class CardPlayCommand : ChatCommand
{
	CardPlayCommand()
	{
		super("play", "Play the specified card");
		SetUsage("<card> [wild_color]");
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

		if (!game.playerHasCard(player, card))
		{
			server_AddToChat(getTranslatedString("This card is not in your hand"), ConsoleColour::ERROR, player);
			return;
		};

		if (!game.canPlayCard(player, card))
		{
			server_AddToChat(getTranslatedString("You are unable to play this card"), ConsoleColour::ERROR, player);
			return;
		};

		if (Card::isFlag(card, Card::Flag::Wild))
		{
			if (args.size() < 2)
			{
				server_AddToChat(getTranslatedString("Specify a colour to change to"), ConsoleColour::ERROR, player);
				return;
			}

			string color = args[1];
			if (color == "red")
			{
				card |= Card::Color::Red;
			}
			else if (color == "yellow")
			{
				card |= Card::Color::Yellow;
			}
			else if (color == "green")
			{
				card |= Card::Color::Green;
			}
			else if (color == "blue")
			{
				card |= Card::Color::Blue;
			}
			else
			{
				server_AddToChat(getTranslatedString("Specify a valid color: red, yellow, green, blue"), ConsoleColour::ERROR, player);
				return;
			}
		}

		if (!game.playCard(player, card))
		{
			server_AddToChat(getTranslatedString("You are unable to play this card"), ConsoleColour::ERROR, player);
			return;
		};
	}
}
