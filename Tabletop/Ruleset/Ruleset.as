class Ruleset
{
	void OnStart(Game@ game, CPlayer@[] players) {}
	void OnEnd(Game@ game) {}

	void OnSync(Game@ game, CPlayer@ player) {}
	void OnLeave(Game@ game, CPlayer@ player) {}

	void OnPlayCard(Game@ game, CPlayer@ player, u16 card) {}
	void OnDrawCard(Game@ game, CPlayer@ player, u16 card) {}

	void OnSwapHands(Game@ game, CPlayer@ player1, CPlayer@ player2) {}

	void OnNextTurn(Game@ game, CPlayer@ prevPlayer, CPlayer@ nextplayer) {}
	void OnSkipTurn(Game@ game, CPlayer@ skippedPlayer) {}
	void OnReverseDirection(Game@ game, s8 direction) {}

	void OnReplenishDrawPile(Game@ game) {}

	bool canPlayCard(Game@ game, CPlayer@ player, u16 card) { return true; }
	bool canDrawCard(Game@ game, CPlayer@ player) { return true; }
}
