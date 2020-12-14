#include "Card.as"
#include "Grab.as"
#include "Utilities.as"

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
			card.flipped = true;
			card.hidden = !player.isMyPlayer();
			cards.push_back(card);
		}
	}

	void InsertCard(uint index, Card@ card)
	{
		if (card !is null && index <= cards.size())
		{
			card.hidden = !player.isMyPlayer();
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
			card.hidden = false;
		}
		return card;
	}

	Card@ getCard(uint index)
	{
		Card@ card;
		if (index < cards.size())
		{
			@card = cards[index];
		}
		return card;
	}

	void Render(uint index)
	{
		float scale = smallestScreenDim();

		Vec2f mousePos = getControls().getInterpMouseScreenPos();
		Vec2f screenDim = getDriver().getScreenDimensions();

		float angle = float(index) / Hand::getHandCount() * 360;
		Vec2f position = screenDim / 2.0f + Vec2f_lengthdir(scale / 2.5f, angle + 90);

		uint n = cards.size();
		bool hover = false;

		for (int i = n - 1; i >= 0; i--)
		{
			Card@ card = cards[i];

			float hoverOffset = 0;
			if (!hover && player.isMyPlayer() && card.contains(mousePos) && (!Grab::isGrabbing() || Grab::isGrabbing(card)))
			{
				hoverOffset += scale / 32.0f;
				hover = true;
			}

			float x = i - (n - 1) / 2.0f;

			card.targetPosition = position + Vec2f(x * 40, Maths::Abs(Maths::Sin(x / 20.0f)) * 200 - hoverOffset).RotateBy(angle);
			card.targetRotation = angle + x * 2;

			// float len = scale / 1.5f + hoverOffset;
			// Vec2f offset = Vec2f_lengthdir(len, (angle + 180) + (x * len / 60.0f));
			// card.targetPosition = position + offset;
			// card.targetRotation = 90 - offset.Angle();
		}

		for (uint i = 0; i < n; i++)
		{
			cards[i].Render();
		}

		if (!player.isMyPlayer())
		{
			GUI::SetFont("name");

			GUI::DrawTextCentered(player.getUsername(), position + Vec2f(0, 2), color_black);
			GUI::DrawTextCentered(player.getUsername(), position - Vec2f(0, 2), color_black);
			GUI::DrawTextCentered(player.getUsername(), position + Vec2f(2, 0), color_black);
			GUI::DrawTextCentered(player.getUsername(), position - Vec2f(2, 0), color_black);

			GUI::DrawTextCentered(player.getUsername(), position, color_white);
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
