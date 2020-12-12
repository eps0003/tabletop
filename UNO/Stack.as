#include "Card.as"

class Stack
{
	string name;
	Vec2f position;

	Card@[] cards;

	Stack(string name, Vec2f position)
	{
		this.name = name;
		this.position = position;
	}

	Stack(CBitStream@ bs)
	{
		name = bs.read_string();
		position.x = bs.read_f32();
		position.y = bs.read_f32();

		u16 n = bs.read_u16();
		for (uint i = 0; i < n; i++)
		{
			Card@ card = Card(bs);
			card.position = position;
			PushCard(card);
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

	void Shuffle(uint seed = Time())
	{
		Random rand(seed);
		uint n = cards.size();

		//https://stackoverflow.com/a/12646864
		for (int i = n - 1; i > 0; i--)
		{
			uint j = rand.NextRanged(i + 1);

			Card@ tempCard = cards[i];
			@cards[i] = cards[j];
			@cards[j] = tempCard;

			Vec2f tempPos = cards[i].position;
			cards[i].position = cards[j].position;
			cards[j].position = tempPos;
		}

		//align cards
		for (uint i = 0; i < n; i++)
		{
			Card@ card = cards[i];
			// card.position = position;
			card.targetRotation = 0;
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
		bs.write_string(name);
		bs.write_f32(position.x);
		bs.write_f32(position.y);

		uint n = cards.size();
		bs.write_u16(n);

		for (uint i = 0; i < n; i++)
		{
			cards[i].Serialize(bs);
		}
	}
}
