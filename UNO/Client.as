#include "Stack.as"
#include "Hand.as"

#define CLIENT_ONLY

bool ready;
Stack@ drawPile;
Stack@ discardPile;
Hand@ hand;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	ready = false;
	@hand = Hand(getLocalPlayer());
}

void onTick(CRules@ this)
{
	if (getLocalPlayer() is null || !ready) return;

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
	if (ready)
	{
		drawPile.Render();
		discardPile.Render();
	}

	hand.Render();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("s_sync"))
	{
		@drawPile = Stack(params);
		@discardPile = Stack(params);

		ready = true;
	}
	else if (cmd == this.getCommandID("c_draw"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		CPlayer@ player = getPlayerByNetworkId(id);
		if (player is null) return;

		Card@ card = drawPile.popCard();
		discardPile.PushCard(card);
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
