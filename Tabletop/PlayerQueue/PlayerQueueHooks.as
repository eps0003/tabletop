#include "PlayerQueue.as"
#include "Game.as"
#include "QueueJoinCommand.as"
#include "QueueLeaveCommand.as"
#include "GameStartCommand.as"
#include "TurnPrevCommand.as"
#include "TurnNextCommand.as"
#include "CardDrawCommand.as"
#include "CardPlayCommand.as"

PlayerQueue@ queue;

void onInit(CRules@ this)
{
	@queue = PlayerQueue::get();

	ChatCommands::RegisterCommand(QueueJoinCommand(queue));
	ChatCommands::RegisterCommand(QueueLeaveCommand(queue));
	ChatCommands::RegisterCommand(GameStartCommand(queue));
	ChatCommands::RegisterCommand(TurnPrevCommand());
	ChatCommands::RegisterCommand(TurnNextCommand());
	ChatCommands::RegisterCommand(CardDrawCommand());
	ChatCommands::RegisterCommand(CardPlayCommand());

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
