#include "Card.as"

shared class Hand
{
	private Card@[] cards;

	Hand(CPlayer@ player)
	{

	}

	void AddCard(Card@ card)
	{
		cards.push_back(card);
	}

	Card@ takeCard(uint index)
	{
		return (index < cards.size()) ? cards[index] : null;
	}

	void Render()
	{
		Vec2f screenDim = getDriver().getScreenDimensions();
		uint n = cards.size();

		for (uint i = 0; i < n; i++)
		{
			Card@ card = cards[i];

			float x = (i - (n - 1) / 2.0f) * 60;
			card.targetPosition = Vec2f(screenDim.x / 2 + x, screenDim.y - 100);

			card.Render();
		}
	}
}
