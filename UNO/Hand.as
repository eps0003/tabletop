#include "Card.as"
#include "Grab.as"

Hand@ getHand(CPlayer@ player)
{
	Hand@ hand;
	player.get("hand", @hand);
	return hand;
}

void SetHand(CPlayer@ player, Hand@ hand)
{
	player.set("hand", @hand);
}

class Hand
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
			if (!hover && player.isMyPlayer() && card.contains(mousePos) && (!Grab::isGrabbing() || Grab::isGrabbing(card)))
			{
				hoverOffset -= 30;
				hover = true;
			}

			float x = i - (n - 1) / 2.0f;

			card.targetPosition = Vec2f(screenDim.x / 2 + x * 40, y + hoverOffset + Maths::Abs(Maths::Sin(x / 20.0f)) * 200);
			card.targetRotation = x * 2;
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
