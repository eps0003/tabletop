#include "Stack.as"
#include "Hand.as"

#define CLIENT_ONLY

Stack@ drawPile;
Stack@ discardPile;
Hand@ hand;

void onInit(CRules@ this)
{
	onRestart();
}

void onRestart()
{
	Vec2f screenCenter = getDriver().getScreenCenterPos();

	@drawPile = Stack(screenCenter - Vec2f(100, 0));
	@discardPile = Stack(screenCenter + Vec2f(100, 0));
	@hand = Hand(getLocalPlayer());

	for (uint i = 0; i < 108; i++)
	{
		drawPile.PushCard(Card(drawPile.position));
	}
}

void onTick(CRules@ this)
{
	if (getLocalPlayer() is null) return;

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();

	if (controls.isKeyJustPressed(KEY_LBUTTON))
	{
		{
			Card@ card = drawPile.getTopCard();
			if (card !is null && card.contains(mousePos))
			{
				CBitStream bs;
				bs.write_u16(getLocalPlayer().getNetworkID());
				this.SendCommand(this.getCommandID("c_draw"), bs, true);
			}
		}

		{
			for (int i = hand.cards.size() - 1; i >= 0; i--)
			{
				Card@ card = hand.cards[i];

				if (card.contains(mousePos))
				{
					CBitStream bs;
					bs.write_u16(getLocalPlayer().getNetworkID());
					bs.write_u16(i);
					this.SendCommand(this.getCommandID("c_discard"), bs, true);

					break;
				}
			}
		}
	}

	if (controls.isKeyJustPressed(KEY_KEY_S))
	{
		Card@ card = drawPile.getTopCard();
		if (card !is null && card.contains(mousePos))
		{
			CBitStream bs;
			this.SendCommand(this.getCommandID("c_shuffle_draw_pile"), bs, true);
		}
	}

	if (controls.isKeyJustPressed(KEY_KEY_R))
	{
		CBitStream bs;
		this.SendCommand(this.getCommandID("c_reset"), bs, false);
	}
}

void onRender(CRules@ this)
{
	drawPile.Render();
	discardPile.Render();
	hand.Render();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("c_draw"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		CPlayer@ player = getPlayerByNetworkId(id);
		if (player is null) return;

		Card@ card = drawPile.popCard();
		hand.PushCard(card);
	}
	else if (cmd == this.getCommandID("c_discard"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		CPlayer@ player = getPlayerByNetworkId(id);
		if (player is null) return;

		uint index;
		if (!params.saferead_u16(index)) return;

		Card@ card = hand.takeCard(index);
		discardPile.PushCard(card);
	}
	else if (cmd == this.getCommandID("c_shuffle_draw_pile"))
	{
		drawPile.Shuffle();
	}
}
