#include "RenderState.as"

class GameStart : RenderState
{
	private Game@ game;

	GameStart(Game@ game)
	{
		@this.game = game;
	}

	void Start()
	{
		GameManager::Set(game);
	}
}
