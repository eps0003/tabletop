#include "RenderState.as"

class TurnNext : RenderState
{
	private Game@ game;

	TurnNext(Game@ game)
	{
		@this.game = game;
	}

	void Start()
	{
		game.NextTurn();
	}
}
