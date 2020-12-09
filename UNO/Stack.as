#include "Card.as"

shared class Stack
{
	Vec2f position;

	Card@[] cards;

	private Random rand(Time());

	Stack(Vec2f position)
	{
		this.position = position;
	}

	Stack(CBitStream@ bs)
	{
		position.x = bs.read_f32();
		position.y = bs.read_f32();

		uint n = bs.read_u16();
		for (uint i = 0; i < n; i++)
		{
			PushCard(Card(position));
		}
	}

	void PushCard(Card@ card)
	{
		if (card !is null)
		{
			cards.push_back(card);
		}
	}

	Card@ popCard()
	{
		Card@ card;
		if (!isEmpty())
		{
			@card = cards[cards.size() - 1];
			cards.removeLast();
		}
		return card;
	}

	Card@ getTopCard()
	{
		return !isEmpty() ? cards[cards.size() - 1] : null;
	}

	bool isEmpty()
	{
		return cards.isEmpty();
	}

	void Shuffle()
	{
		//https://stackoverflow.com/a/12646864
		for (int i = cards.size() - 1; i > 0; i--)
		{
			uint j = rand.NextRanged(i + 1);

			Card@ tempCard = cards[i];
			@cards[i] = cards[j];
			@cards[j] = tempCard;

			Vec2f tempPos = cards[i].position;
			cards[i].position = cards[j].position;
			cards[j].position = tempPos;
		}
	}

	void Render()
	{
		for (uint i = 0; i < cards.size(); i++)
		{
			Card@ card = cards[i];
			card.targetPosition = position - Vec2f(0, i / 2.0f);
			card.Render();
		}
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_f32(position.x);
		bs.write_f32(position.y);
		bs.write_u16(cards.size());
	}
}
