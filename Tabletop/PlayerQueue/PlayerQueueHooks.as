#include "PlayerQueue.as"
#include "Game.as"

PlayerQueue@ queue;

void onInit(CRules@ this)
{
	@queue = PlayerQueue::get();

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
