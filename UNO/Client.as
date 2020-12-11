#include "Stack.as"
#include "Hand.as"
#include "Grab.as"
#include "Utilities.as"

#define CLIENT_ONLY

Stack@ drawPile;
Stack@ discardPile;
Hand@ hand;

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
}

void onTick(CRules@ this)
{
	if (!isReady()) return;

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();

	//controls and keybinds
	DealCardsUsingNumberKeys(this);
	ShufflePiles(this, mousePos);
	ResetKeybind(this);
}

void Render(int id)
{
	Vec2f screenDim = getDriver().getScreenDimensions();
	DrawBackground(screenDim);

	Render::SetAlphaBlend(true);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();
	Render::SetTransformScreenspace();

	if (isReady())
	{
		discardPile.Render();
		drawPile.Render();
		hand.Render(screenDim.y - 100);
	}

	uint index = 0;

	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null || player.isMyPlayer()) continue;

		Hand@ tempHand = getHand(player);
		if (tempHand is null) continue;

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
			SetHand(tempHand.player, tempHand);

			if (tempHand.player.isMyPlayer())
			{
				@hand = tempHand;
			}
		}

		SetReady(true);
	}
}

void DealCardsUsingNumberKeys(CRules@ this)
{
	Card@ topDrawCard = drawPile.getTopCard();
	if (topDrawCard is null) return;

	CControls@ controls = getControls();
	Vec2f mousePos = getControls().getMouseScreenPos();

	for (uint key = KEY_KEY_1; key <= KEY_KEY_9; key++)
	{
		if (controls.isKeyJustPressed(key) && topDrawCard.contains(mousePos))
		{
			CBitStream bs;
			bs.write_u16(getLocalPlayer().getNetworkID());
			bs.write_u8(key - KEY_KEY_0);
			this.SendCommand(this.getCommandID("c_draw"), bs, true);
		}
	}
}

void ShufflePiles(CRules@ this, Vec2f mousePos)
{
	CControls@ controls = getControls();
	if (!controls.isKeyJustPressed(KEY_KEY_S)) return;

	Card@ topDrawCard = drawPile.getTopCard();
	if (topDrawCard !is null && topDrawCard.contains(mousePos))
	{
		CBitStream bs;
		this.SendCommand(this.getCommandID("c_shuffle_draw_pile"), bs, true);
	}

	Card@ topDiscardCard = discardPile.getTopCard();
	if (topDiscardCard !is null && topDiscardCard.contains(mousePos))
	{
		CBitStream bs;
		this.SendCommand(this.getCommandID("c_restock_draw_pile"), bs, true);
	}
}

void ResetKeybind(CRules@ this)
{
	CControls@ controls = getControls();
	if (controls.isKeyJustPressed(KEY_KEY_R))
	{
		CBitStream bs;
		this.SendCommand(this.getCommandID("c_reset"), bs, false);
	}
}

void DrawBackground(Vec2f screenDim)
{
	GUI::DrawRectangle(Vec2f(0, 0), screenDim, SColor(255, 36, 115, 69));
}
