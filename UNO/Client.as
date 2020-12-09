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
	Vec2f screenDim = getDriver().getScreenDimensions();
	GUI::DrawRectangle(Vec2f(0, 0), screenDim, SColor(255, 36, 115, 69));

	if (ready)
	{
		drawPile.Render();
		discardPile.Render();
	}

	hand.Render(screenDim.y - 100);

	uint index = 0;

	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null || player.isMyPlayer()) continue;

		Hand@ tempHand;
		if (!player.get("hand", @tempHand)) continue;

		tempHand.Render(100 + index * 40);

		index++;
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("s_sync"))
	{
		@drawPile = Stack(params);
		@discardPile = Stack(params);

		this.set("draw_pile", @drawPile);
		this.set("discard_pile", @discardPile);

		u16 n = params.read_u16();

		for (uint i = 0; i < n; i++)
		{
			Hand@ tempHand = Hand(params);
			tempHand.player.set("hand", @tempHand);

			if (tempHand.player.isMyPlayer())
			{
				@hand = tempHand;
			}
		}

		ready = true;
	}
}
