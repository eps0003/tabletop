#include "Stack.as"
#include "Hand.as"

#define CLIENT_ONLY

bool ready;
Stack@ drawPile;
Stack@ discardPile;
Hand@ hand;

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
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

	Card@ topDrawCard = drawPile.getTopCard();
	bool mouseOnTopDrawCard = topDrawCard !is null && topDrawCard.contains(mousePos);

	Card@ topDiscardCard = discardPile.getTopCard();
	bool mouseOnTopDiscardCard = topDiscardCard !is null && topDiscardCard.contains(mousePos);

	if (controls.isKeyJustPressed(KEY_LBUTTON))
	{
		//draw cards from draw pile
		if (mouseOnTopDrawCard)
		{
			CBitStream bs;
			bs.write_u16(getLocalPlayer().getNetworkID());
			bs.write_u8(1);
			this.SendCommand(this.getCommandID("c_draw"), bs, true);
		}

		//click on card in hand to put card on discard pile
		for (int i = hand.cards.size() - 1; i >= 0; i--)
		{
			Card@ card = hand.cards[i];
			if (!card.contains(mousePos)) continue;

			CBitStream bs;
			bs.write_u16(getLocalPlayer().getNetworkID());
			bs.write_u16(i);
			this.SendCommand(this.getCommandID("c_discard"), bs, true);

			break;
		}
	}

	//deal cards using number keys
	for (uint key = KEY_KEY_1; key <= KEY_KEY_9; key++)
	{
		if (mouseOnTopDrawCard && controls.isKeyJustPressed(key))
		{
			CBitStream bs;
			bs.write_u16(getLocalPlayer().getNetworkID());
			bs.write_u8(key - KEY_KEY_0);
			this.SendCommand(this.getCommandID("c_draw"), bs, true);
		}
	}

	//shuffle the draw pile
	if (controls.isKeyJustPressed(KEY_KEY_S))
	{
		if (mouseOnTopDrawCard)
		{
			CBitStream bs;
			this.SendCommand(this.getCommandID("c_shuffle_draw_pile"), bs, true);
		}

		if (mouseOnTopDiscardCard)
		{
			CBitStream bs;
			this.SendCommand(this.getCommandID("c_restock_draw_pile"), bs, true);
		}
	}

	//reset keybind (FOR DEBUGGING)
	if (controls.isKeyJustPressed(KEY_KEY_R))
	{
		CBitStream bs;
		this.SendCommand(this.getCommandID("c_reset"), bs, false);
	}
}

void onRender(CRules@ this)
{

}

void Render(int id)
{
	//background colour
	Vec2f screenDim = getDriver().getScreenDimensions();
	GUI::DrawRectangle(Vec2f(0, 0), screenDim, SColor(255, 36, 115, 69));

	Render::SetAlphaBlend(false);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();
	Render::SetTransformScreenspace();

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
	if (cmd == this.getCommandID("s_sync_all"))
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
	else if (cmd == this.getCommandID("s_sync_hand"))
	{
		Hand@ tempHand = Hand(params);
		tempHand.player.set("hand", @tempHand);
	}
}
