#include "ChatCommand.as"

class TurnPrevCommand : ChatCommand
{
	private TurnManager@ turns;

	TurnPrevCommand(TurnManager@ turns)
	{
		super("prev", "Proceed with the previous player's turn");
		AddAlias("previous");
		AddAlias("back");

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
