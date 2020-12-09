#include "Card.as"

shared class Hand
{
	Card@[] cards;

	Hand(CPlayer@ player)
	{

	}

	void PushCard(Card@ card)
	{
		if (card !is null)
		{
			cards.push_back(card);
		}
	}

	Card@ takeCard(uint index)
	{
		Card@ card;
		if (index < cards.size())
		{
			@card = cards[index];
			cards.removeAt(index);
		}
		return card;
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
