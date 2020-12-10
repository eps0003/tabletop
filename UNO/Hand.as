#include "Card.as"
#include "Drag.as"

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
		u16 id = bs.read_u16();
		@player = getPlayerByNetworkId(id);

		u16 n = bs.read_u16();
		for (uint i = 0; i < n; i++)
		{
			PushCard(Card(bs));
		}
	}

	void PushCard(Card@ card)
	{
		if (card !is null)
		{
			cards.push_back(card);
		}
	}

	void InsertCard(uint index, Card@ card)
	{
		if (card !is null && index <= cards.size())
		{
			cards.insertAt(index, card);
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
		Vec2f mousePos = getControls().getInterpMouseScreenPos();
		Vec2f screenDim = getDriver().getScreenDimensions();
		uint n = cards.size();

		bool hover = false;

		for (int i = n - 1; i >= 0; i--)
		{
			Card@ card = cards[i];

			float hoverOffset = 0;
			if (!hover && player.isMyPlayer() && card.contains(mousePos) && (!isGrabbing() || isGrabbing(card)))
			{
				hoverOffset -= 30;
				hover = true;
			}

			float x = (i - (n - 1) / 2.0f) * 40;

			card.targetPosition = Vec2f(screenDim.x / 2 + x, y + hoverOffset);
		}

		for (uint i = 0; i < n; i++)
		{
			cards[i].Render();
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
