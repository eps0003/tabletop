#include "Stack.as"
#include "Hand.as"

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

	for (uint i = 0; i < 52; i++)
	{
		drawPile.PushCard(Card(i, drawPile.position));
	}

	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null) continue;

		player.set("hand", Hand(player));
	}
}

void onTick(CRules@ this)
{
	//this needs to be done here instead of in onInit to avoid the following error:
	//SendCmd rules scripts not initialised for cmd 420
	if (getGameTime() == 1)
	{
		Sync(this);
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	player.set("hand", Hand(player));
	Sync(this);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("c_reset"))
	{
		LoadNextMap();
	}
}

void Sync(CRules@ this)
{
	CBitStream bs;

	//serialize piles
	drawPile.Serialize(bs);
	discardPile.Serialize(bs);

	//collect all hands into an array
	Hand@[] hands;

	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null) continue;

		Hand@ hand;
		if (!player.get("hand", @hand)) continue;

		hands.push_back(hand);
	}

	//serialize hands
	uint n = hands.size();
	bs.write_u16(n);

	for (uint i = 0; i < n; i++)
	{
		hands[i].Serialize(bs);
	}

	this.SendCommand(this.getCommandID("s_sync"), bs, true);
}
