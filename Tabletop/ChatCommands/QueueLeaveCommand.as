#include "ChatCommand.as"

class QueueLeaveCommand : ChatCommand
{
	private PlayerQueue@ queue;

	QueueLeaveCommand(PlayerQueue@ queue)
	{
		super("leave", "Leave the queue");
		AddAlias("remove");
		AddAlias("rem");

		@this.queue = queue;
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (!isServer()) return;

		if (!queue.contains(player))
		{
			server_AddToChat(getTranslatedString("You are already not in the queue"), ConsoleColour::ERROR, player);
			return;
		}

		queue.Remove(player);

		string message = getTranslatedString("{PLAYER} has left the queue")
			.replace("{PLAYER}", player.getUsername());
		server_AddToChat(message, ConsoleColour::INFO);
	}
}
