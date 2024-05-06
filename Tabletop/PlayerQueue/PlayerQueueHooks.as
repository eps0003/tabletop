#include "PlayerQueue.as"
#include "QueueJoinCommand.as"
#include "QueueLeaveCommand.as"

PlayerQueue@ queue;

void onInit(CRules@ this)
{
	@queue = PlayerQueue::get();

	ChatCommands::RegisterCommand(QueueJoinCommand(queue));
	ChatCommands::RegisterCommand(QueueLeaveCommand(queue));

	onRestart(this);
}

void onRestart(CRules@ this)
{
	queue.Clear();
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	queue.Remove(player);
}
