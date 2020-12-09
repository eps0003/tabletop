#include "Stack.as"

#define SERVER_ONLY

Stack@ drawPile;
Stack@ discardPile;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	Vec2f screenCenter = getDriver().getScreenCenterPos();

	@drawPile = Stack(screenCenter - Vec2f(100, 0));
	@discardPile = Stack(screenCenter + Vec2f(100, 0));

	for (uint i = 0; i < 108; i++)
	{
		drawPile.PushCard(Card(drawPile.position));
	}

	this.SendCommand(this.getCommandID("s_sync"), Serialize(), true);
}

void onTick(CRules@ this)
{

}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	this.SendCommand(this.getCommandID("s_sync"), Serialize(), player);
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
		// hand.PushCard(card);
	}
	else if (cmd == this.getCommandID("c_discard"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		CPlayer@ player = getPlayerByNetworkId(id);
		if (player is null) return;

		uint index;
		if (!params.saferead_u16(index)) return;

		// Card@ card = hand.takeCard(index);
		// discardPile.PushCard(card);
	}
	else if (cmd == this.getCommandID("c_shuffle_draw_pile"))
	{
		drawPile.Shuffle();
	}
	else if (cmd == this.getCommandID("c_reset"))
	{
		LoadNextMap();
	}
}

CBitStream Serialize()
{
	CBitStream bs;
	drawPile.Serialize(bs);
	discardPile.Serialize(bs);
	return bs;
}
