class Ruleset
{
	void OnStart(Game@ game, string[] players) {}
	void OnEnd(Game@ game) {}

	void OnSync(Game@ game, string player) {}
	void OnLeave(Game@ game, string player) {}

	void OnPlayCard(Game@ game, string player, u16 card) {}
	void OnDrawCard(Game@ game, string player, u16 card) {}

	void OnSwapHands(Game@ game, string player1, string player2) {}

	void OnNextTurn(Game@ game, string prevPlayer, string nextPlayer) {}
	void OnSkipTurn(Game@ game, string skippedPlayer) {}
	void OnReverseDirection(Game@ game, s8 direction) {}

	void OnReplenishDrawPile(Game@ game) {}

	bool canPlayCard(Game@ game, string player, u16 card) { return true; }
	bool canDrawCard(Game@ game, string player) { return true; }
}
