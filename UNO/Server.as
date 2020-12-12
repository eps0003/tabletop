#include "Stack.as"
#include "Hand.as"
#include "StackManager.as"
#include "GameManager.as"

#define SERVER_ONLY

void onInit(CRules@ this)
{
	Game::SetScript("PlayingCards.as");
	onRestart(this);
}

void onRestart(CRules@ this)
{
	Stack::Init();
	InitHands();
	this.AddScript(Game::getScript());
}

void onTick(CRules@ this)
{
	//this needs to be done here instead of in onInit to avoid the following error:
	//SendCmd rules scripts not initialised for cmd 420
	if (getGameTime() == 1)
	{
		Stack@[] stacks = Stack::getStacks();
		uint n = stacks.size();

		CBitStream bs;
		Stack::Serialize(bs);
		SerializeHands(bs);
		this.SendCommand(this.getCommandID("s_sync_all"), bs, true);
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Hand@ hand = Hand(player);
	Hand::SetHand(player, hand);

	CBitStream bsAll;
	Stack::Serialize(bsAll);
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
	else if (cmd == this.getCommandID("c_shuffle_stack"))
	{
		string name;
		if (!params.saferead_string(name)) return;

		Stack@ stack = Stack::getStack(name);
		if (stack is null) return;

		uint seed = Time();
		stack.Shuffle(seed);

		CBitStream bs;
		bs.write_string(name);
		bs.write_u32(seed);
		this.SendCommand(this.getCommandID("s_shuffle_stack"), bs, true);
	}
}

void InitHands()
{
	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null) continue;

		Hand::SetHand(player, Hand(player));
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

		Hand@ hand = Hand::getHand(player);
		if (hand is null) continue;

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
