#include "Ruleset.as"

class OfficialRuleset : Ruleset
{
	private u16 pickup = 0;

	void OnStart(Game@ game, CPlayer@[] players)
	{
		print("Official ruleset");
	}

	void OnPlayCard(Game@ game, CPlayer@ player, u16 card)
	{
		if (Card::isValue(card, Card::Value::Reverse))
		{
			if (isServer())
			{
				game.ReverseDirection();
				game.NextTurn();
			}
			return;
		}

		if (Card::isValue(card, Card::Value::Skip))
		{
			if (isServer())
			{
				game.SkipTurn();
			}
			return;
		}

		if (Card::isValue(card, Card::Value::Draw2))
		{
			pickup += 2;

			if (isServer())
			{
				game.NextTurn();
				game.DrawCard();
				game.DrawCard();
				game.NextTurn();
			}
			return;
		}

		if (Card::isValue(card, Card::Value::Draw4))
		{
			pickup += 4;

			if (isServer())
			{
				game.NextTurn();
				game.DrawCard();
				game.DrawCard();
				game.DrawCard();
				game.DrawCard();
				game.NextTurn();
			}
			return;
		}
	}

	void OnDrawCard(Game@ game, CPlayer@ player, u16 card)
	{
		if (isServer())
		{
			if (game.getDrawPile().empty())
			{
				game.ReplenishDrawPile();
			}

			if (canPlayCard(game, player, card))
			{
				// TODO: Pick colour if wild
				game.PlayCard(player, card);
			}
			else if (pickup == 0)
			{
				game.NextTurn();
			}
		}

		if (pickup > 0)
		{
			pickup--;
		}
	}

	bool canPlayCard(Game@ game, CPlayer@ player, u16 card)
	{
		if (pickup > 0)
		{
			return false;
		}

		u16[] discardPile = game.getDiscardPile();
		u16 discardPileCard = discardPile[discardPile.size() - 1];

		return (
			Card::isSameColor(card, discardPileCard) ||
			Card::isSameValue(card, discardPileCard) ||
			Card::hasFlags(card, Card::Flag::Wild)
		);
	}
}
