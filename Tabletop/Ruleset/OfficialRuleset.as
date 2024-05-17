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

	bool canPlayCard(Game@ game, CPlayer@ player, u16 card)
	{
		u16[] discardPile = game.getDiscardPile();
		u16 discardPileCard = discardPile[discardPile.size() - 1];

		return (
			Card::isSameColor(card, discardPileCard) ||
			Card::isSameValue(card, discardPileCard) ||
			Card::isFlag(card, Card::Flag::Wild)
		);
	}
}
