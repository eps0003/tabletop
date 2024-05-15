#include "Game.as"

#define CLIENT_ONLY

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("init game"))
	{
		u32 seed;
		if (!params.saferead_u32(seed)) return;

		u16 playerCount;
		if (!params.saferead_u16(playerCount)) return;

		string message = getTranslatedString("A game has started with {PLAYERS} " + plural("player!", "players!", playerCount))
			.replace("{PLAYERS}", "" + playerCount);
		client_AddToChat(message, ConsoleColour::CRAZY);
	}
	else if (cmd == this.getCommandID("end game"))
	{
		string message = getTranslatedString("The game has ended");
		client_AddToChat(message, ConsoleColour::CRAZY);
	}
	else if (cmd == this.getCommandID("play card"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		u16 card;
		if (!params.saferead_u16(card)) return;

		string message = getTranslatedString("{PLAYER} played a {CARD}")
			.replace("{PLAYER}", player.getUsername())
			.replace("{CARD}", Card::getName(card));
		client_AddToChat(message, ConsoleColour::INFO);
	}
	else if (cmd == this.getCommandID("draw card"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		string message = getTranslatedString("{PLAYER} drew a card")
			.replace("{PLAYER}", player.getUsername());
		client_AddToChat(message, ConsoleColour::INFO);
	}
	else if (cmd == this.getCommandID("next turn"))
	{
		Game@ game = GameManager::get();
		if (game is null) return;

		string message = getTranslatedString("{PLAYER}'s turn")
			.replace("{PLAYER}", game.getTurnPlayer().getUsername());
		client_AddToChat(message, ConsoleColour::INFO);
	}
}
