#include "Game.as"
#include "PlayerQueue.as"
#include "Utilities.as"

#include "QueueJoinCommand.as"
#include "QueueLeaveCommand.as"
#include "GameStartCommand.as"
#include "TurnPrevCommand.as"
#include "TurnNextCommand.as"
#include "CardDrawCommand.as"
#include "CardPlayCommand.as"

void onInit(CRules@ this)
{
	this.addCommandID("init game");
	this.addCommandID("sync game");
	this.addCommandID("remove player");
	this.addCommandID("next turn");
	this.addCommandID("reverse direction");
	this.addCommandID("draw card");
	this.addCommandID("play card");
	this.addCommandID("trade hands");
	this.addCommandID("discard hand");
	this.addCommandID("shuffle draw pile");
	this.addCommandID("replenish draw pile");

	ChatCommands::RegisterCommand(QueueJoinCommand());
	ChatCommands::RegisterCommand(QueueLeaveCommand());
	ChatCommands::RegisterCommand(GameStartCommand());
	ChatCommands::RegisterCommand(TurnPrevCommand());
	ChatCommands::RegisterCommand(TurnNextCommand());
	ChatCommands::RegisterCommand(CardDrawCommand());
	ChatCommands::RegisterCommand(CardPlayCommand());
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Game@ game = GameManager::get();
	if (game !is null)
	{
		game.Sync(player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init game"))
	{
		u16 playerCount;
		if (!params.saferead_u16(playerCount)) return;

		CPlayer@[] players;

		for (uint i = 0; i < playerCount; i++)
		{
			CPlayer@ player;
			if (!saferead_player(params, @player)) return;

			players.push_back(player);
		}

		GameManager::Set(Game(players));
	}
	else if (!isServer() && cmd == this.getCommandID("sync game"))
	{
		GameManager::Set(Game(params));
	}
	else if (!isServer() && cmd == this.getCommandID("remove player"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		game.RemovePlayer(player);
	}
	else if (!isServer() && cmd == this.getCommandID("next turn"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		game.NextTurn();
	}
	else if (!isServer() && cmd == this.getCommandID("reverse direction"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		game.ReverseDirection();
	}
	else if (!isServer() && cmd == this.getCommandID("draw card"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		game.drawCard(player);
	}
	else if (!isServer() && cmd == this.getCommandID("play card"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		u16 card;
		if (!params.saferead_u16(card)) return;

		game.playCard(player, card);
	}
	else if (!isServer() && cmd == this.getCommandID("trade hands"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		CPlayer@ player1;
		if (!saferead_player(params, @player1)) return;

		CPlayer@ player2;
		if (!saferead_player(params, @player2)) return;

		game.tradeHands(player1, player2);
	}
	else if (!isServer() && cmd == this.getCommandID("discard hand"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		game.discardHand(player);
	}
	else if (!isServer() && cmd == this.getCommandID("shuffle draw pile"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		u32 seed;
		if (!params.saferead_u32(seed)) return;

		game.ShuffleDrawPile(seed);
	}
	else if (!isServer() && cmd == this.getCommandID("replenish draw pile"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		game.replenishDrawPile();
	}
}