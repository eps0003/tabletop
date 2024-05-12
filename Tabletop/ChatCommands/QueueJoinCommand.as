#include "ChatCommand.as"

class QueueJoinCommand : ChatCommand
{
	QueueJoinCommand()
	{
		super("join", "Join the queue");
		AddAlias("add");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (!isServer()) return;

		PlayerQueue@ queue = PlayerQueue::get();

		if (queue.contains(player))
		{
			server_AddToChat(getTranslatedString("You are already in the queue"), ConsoleColour::ERROR, player);
			return;
		}

		queue.Add(player);

		string message = getTranslatedString("{PLAYER} has joined the queue")
			.replace("{PLAYER}", player.getUsername());
		server_AddToChat(message, ConsoleColour::INFO);
	}
}
