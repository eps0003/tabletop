#include "PlayerQueue.as"
#include "Turns.as"
#include "GameStartCommand.as"
#include "TurnNextCommand.as"
#include "TurnPrevCommand.as"

PlayerQueue@ queue;
TurnManager@ turns;

void onInit(CRules@ this)
{
	@queue = PlayerQueue::get();
	@turns = TurnManager::get();

	ChatCommands::RegisterCommand(GameStartCommand(queue, turns));
	ChatCommands::RegisterCommand(TurnPrevCommand(turns));
	ChatCommands::RegisterCommand(TurnNextCommand(turns));
}
