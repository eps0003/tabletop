#include "Card.as"

shared class Stack
{
	Vec2f position;

	private Card@[] cards;
	private Random rand(Time());

	Stack(Vec2f position)
	{
		this.position = position;
	}

	void PushCard(Card@ card)
	{
		cards.push_back(card);
	}

	Card@ popCard()
	{
		Card@ card;
		if (!cards.isEmpty())
		{
			@card = cards[cards.size() - 1];
			cards.removeLast();
		}
		return card;
	}

	void Shuffle()
	{
		//https://stackoverflow.com/a/12646864
		for (int i = cards.size() - 1; i > 0; i--)
		{
			uint j = rand.NextRanged(i + 1);
			Card@ temp = cards[i];
			cards[i] = cards[j];
			cards[j] = temp;
		}
	}

	void Render()
	{
		for (uint i = 0; i < cards.size(); i++)
		{
			Card@ card = cards[i];
			card.targetPosition = position - Vec2f(0, i);
			card.Render();
		}
	}
}
