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

	// for (uint i = 0; i < 41; i++) //exploding kittens
	for (uint i = 0; i < 52; i++) //standard playing cards
	{
		drawPile.PushCard(Card(i, drawPile.position));
	}

	drawPile.Shuffle();

	Card@ card = drawPile.popCard();
	card.Flip();
	discardPile.PushCard(card);

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
		CBitStream bs;
		drawPile.Serialize(bs);
		discardPile.Serialize(bs);
		SerializeHands(bs);
		this.SendCommand(this.getCommandID("s_sync_all"), bs, true);
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Hand@ hand = Hand(player);
	player.set("hand", @hand);

	CBitStream bsAll;
	drawPile.Serialize(bsAll);
	discardPile.Serialize(bsAll);
	SerializeHands(bsAll);

	CBitStream bsHand;
	hand.Serialize(bsHand);

	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ tempPlayer = getPlayer(i);
		if (tempPlayer is null) continue;

		if (tempPlayer is player)
		{
			this.SendCommand(this.getCommandID("s_sync_all"), bsAll, tempPlayer);
		}
		else
		{
			this.SendCommand(this.getCommandID("s_sync_hand"), bsHand, tempPlayer);
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("c_reset"))
	{
		LoadNextMap();
	}
}

void SerializeHands(CBitStream@ bs)
{
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
}
