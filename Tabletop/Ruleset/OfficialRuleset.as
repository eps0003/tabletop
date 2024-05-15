#include "Ruleset.as"

class OfficialRuleset : Ruleset
{
	void OnStart(Game@ game, CPlayer@[] players)
	{
		print("Official ruleset");
	}

	void OnPlayCard(Game@ game, CPlayer@ player, u16 card)
	{
		if (isServer())
		{
			Game@ game = GameManager::get();
			if (game is null) return;

			if (Card::isValue(card, Card::Value::Reverse))
			{
				game.ReverseDirection();
			}

			if (Card::isValue(card, Card::Value::Skip))
			{
				game.SkipTurn();
			}
			else
			{
				game.NextTurn();
			}
		}
	}
}
