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

	this.set("draw_pile", @drawPile);
	this.set("discard_pile", @discardPile);

	for (uint i = 0; i < 107; i++)
	{
		drawPile.PushCard(Card(drawPile.position));
	}

	discardPile.PushCard(Card(drawPile.position));

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
	if (cmd == this.getCommandID("c_reset"))
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
