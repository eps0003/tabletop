#include "Card.as"

shared class Hand
{
	CPlayer@ player;
	Card@[] cards;

	Hand(CPlayer@ player)
	{
		@this.player = player;
	}

	Hand(CBitStream@ bs)
	{
		@player = getPlayerByNetworkId(bs.read_u16());

		u16 n = bs.read_u16();
		for (uint i = 0; i < n; i++)
		{
			u16 index = bs.read_u16();
			PushCard(Card(index, Vec2f_zero));
		}
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

	void Render(float y)
	{
		Vec2f screenDim = getDriver().getScreenDimensions();
		uint n = cards.size();

		for (uint i = 0; i < n; i++)
		{
			Card@ card = cards[i];

			float x = (i - (n - 1) / 2.0f) * 60;
			card.targetPosition = Vec2f(screenDim.x / 2 + x, y);

			card.Render();
		}
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u16(player.getNetworkID());

		uint n = cards.size();
		bs.write_u16(n);

		for (uint i = 0; i < n; i++)
		{
			cards[i].Serialize(bs);
		}
	}
}
