#include "Game.as"
#include "PlayerQueue.as"
#include "Utilities.as"

#include "QueueJoinCommand.as"
#include "QueueLeaveCommand.as"
#include "GameStartCommand.as"
#include "GameEndCommand.as"
#include "TurnNextCommand.as"
#include "CardDrawCommand.as"
#include "CardPlayCommand.as"

void onInit(CRules@ this)
{
	this.addCommandID("init game");
	this.addCommandID("sync game");
	this.addCommandID("end game");
	this.addCommandID("remove player");
	this.addCommandID("next turn");
	this.addCommandID("skip turn");
	this.addCommandID("reverse direction");
	this.addCommandID("draw card");
	this.addCommandID("play card");
	this.addCommandID("swap hands");
	this.addCommandID("replenish draw pile");

	ChatCommands::RegisterCommand(QueueJoinCommand());
	ChatCommands::RegisterCommand(QueueLeaveCommand());
	ChatCommands::RegisterCommand(GameStartCommand());
	ChatCommands::RegisterCommand(GameEndCommand());
	ChatCommands::RegisterCommand(TurnNextCommand());
	ChatCommands::RegisterCommand(CardDrawCommand());
	ChatCommands::RegisterCommand(CardPlayCommand());
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Game@ game = GameManager::get();
	if (game is null) return;

	game.Sync(player);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if (!isServer()) return;

	Game@ game = GameManager::get();
	if (game is null) return;

	game.RemovePlayer(player.getUsername());
}
