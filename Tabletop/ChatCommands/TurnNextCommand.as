#include "ChatCommand.as"

class TurnNextCommand : ChatCommand
{
	private TurnManager@ turns;

	TurnNextCommand(TurnManager@ turns)
	{
		super("next", "Proceed with the next player's turn");

		@this.turns = turns;
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (!isServer()) return;

		if (turns.isEmpty())
		{
			server_AddToChat(getTranslatedString("There are no players participating"), ConsoleColour::ERROR, player);
			return;
		}

		turns.NextPlayer();

		string message = getTranslatedString("{PLAYER}'s turn")
			.replace("{PLAYER}", turns.getPlayer().getUsername());
		server_AddToChat(message, ConsoleColour::INFO);
	}
}
