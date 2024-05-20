#include "RenderState.as"

class TurnSkip : RenderState
{
	private Game@ game;

	TurnSkip(Game@ game)
	{
		@this.game = game;
	}

	void Start()
	{
		game.SkipTurn();
	}
}
