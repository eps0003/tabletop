#include "Stack.as"
#include "Hand.as"
#include "Grab.as"
#include "Utilities.as"
#include "StackManager.as"

#define CLIENT_ONLY

Hand@ hand;

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
	onRestart(this);
}

void onRestart(CRules@ this)
{
	SetReady(false);
	Stack::Init();
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

	if (Grab::isGrabbing())
	{
		OrganiseHeldCards(this, hand);
	}
	else if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION1)))
	{
		DiscardHeldCard(this, hand, mousePos);
		DrawCard(this, mousePos);
	}
	else if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION2)))
	{
		GrabCardInHand(hand, mousePos);
	}

	if (!controls.isKeyPressed(controls.getActionKeyKey(AK_ACTION2)))
	{
		Grab::Drop();
	}
}

void Render(int id)
{
	Vec2f screenDim = getDriver().getScreenDimensions();
	DrawBackground(screenDim);

	if (!isReady()) return;

	Render::SetAlphaBlend(true);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();
	Render::SetTransformScreenspace();

	//render stacks
	Stack@[] stacks = Stack::getStacks();
	for (uint i = 0; i < stacks.size(); i++)
	{
		stacks[i].Render();
	}

	//render hands of other players
	uint index = 1;
	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null) continue;

		Hand@ tempHand = Hand::getHand(player);
		if (tempHand is null) continue;

		tempHand.Render(player.isMyPlayer() ? 0 : index);

		if (!player.isMyPlayer())
		{
			index++;
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("s_sync_all"))
	{
		u16 stackCount = params.read_u16();
		for (uint i = 0; i < stackCount; i++)
		{
			string name = params.read_string();
			Stack@ stack = Stack(params);
			Stack::AddStack(name, @stack);
		}

		u16 handCount = params.read_u16();
		for (uint i = 0; i < handCount; i++)
		{
			Hand@ tempHand = Hand(params);
			Hand::SetHand(tempHand.player, tempHand);

			if (tempHand.player.isMyPlayer())
			{
				@hand = tempHand;
			}
		}

		SetReady(true);
	}
	else if (cmd == this.getCommandID("s_sync_hand"))
	{
		Hand@ hand = Hand(params);
		Hand::SetHand(hand.player, hand);
	}
	else if (cmd == this.getCommandID("s_shuffle_draw_pile"))
	{
		Stack@ drawPile = Stack(params);
		Stack::AddStack("draw", @drawPile);
	}
}

void DealCardsUsingNumberKeys(CRules@ this)
{
	Card@ topDrawCard = Stack::getStack("draw").getTopCard();
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

	Card@ topDrawCard = Stack::getStack("draw").getTopCard();
	if (topDrawCard !is null && topDrawCard.contains(mousePos))
	{
		CBitStream bs;
		this.SendCommand(this.getCommandID("c_shuffle_draw_pile"), bs, true);
	}

	Card@ topDiscardCard = Stack::getStack("discard").getTopCard();
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
	// GUI::DrawRectangle(Vec2f(0, 0), screenDim, SColor(255, 36, 115, 69));

	GUI::DrawIcon("woodFloor.png", Vec2f_zero, 0.5f);
	GUI::DrawIcon("woodFloor.png", Vec2f(1000, 0), 0.5f);
	GUI::DrawIcon("woodFloor.png", Vec2f(1000, 666), 0.5f);
	GUI::DrawIcon("woodFloor.png", Vec2f(0, 666), 0.5f);

	GUI::DrawIcon("table.png", screenDim / 2.0f - Vec2f(500, 500), 0.5f);
}

void GrabCardInHand(Hand@ hand, Vec2f mousePos)
{
	//rearrange cards in hand
	for (int i = hand.cards.size() - 1; i >= 0; i--)
	{
		Card@ card = hand.cards[i];
		if (!card.contains(mousePos)) continue;

		Grab::Grab(card);

		break;
	}
}

void OrganiseHeldCards(CRules@ this, Hand@ hand)
{
	Card@ grabCard = Grab::getGrabbed();
	if (grabCard is null) return;

	uint index;

	//find index of grabbed card
	for (uint i = 0; i < hand.cards.size(); i++)
	{
		Card@ card = hand.cards[i];
		if (card is grabCard)
		{
			index = i;
			break;
		}
	}

	//move to left
	for (uint i = 0; i < index; i++)
	{
		Card@ card = hand.cards[i];
		if (card is grabCard) break;

		if (grabCard.position.x < card.position.x)
		{
			uint newIndex = Maths::Max(0, i);
			@grabCard = hand.takeCard(index);
			hand.InsertCard(newIndex, grabCard);
			SyncOrdaniseHand(this, index, newIndex);
			break;
		}
	}

	//move to right
	for (int i = hand.cards.size() - 1; i > index; i--)
	{
		Card@ card = hand.cards[i];
		if (card is grabCard) break;

		if (grabCard.position.x > card.position.x)
		{
			@grabCard = hand.takeCard(index);
			hand.InsertCard(i, grabCard);
			SyncOrdaniseHand(this, index, i);
			break;
		}
	}
}

void SyncOrdaniseHand(CRules@ this, uint oldIndex, uint newIndex)
{
	CPlayer@ player = getLocalPlayer();
	if (player is null) return;

	CBitStream bs;
	bs.write_u16(player.getNetworkID());
	bs.write_u16(oldIndex);
	bs.write_u16(newIndex);

	this.SendCommand(this.getCommandID("c_organise_hand"), bs, true);
}

void DiscardHeldCard(CRules@ this, Hand@ hand, Vec2f mousePos)
{
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

void DrawCard(CRules@ this, Vec2f mousePos)
{
	Stack@ drawPile = Stack::getStack("draw");
	if (drawPile is null) return;

	//draw cards from draw pile
	Card@ topDrawCard = drawPile.getTopCard();
	if (topDrawCard !is null && topDrawCard.contains(mousePos))
	{
		CBitStream bs;
		bs.write_u16(getLocalPlayer().getNetworkID());
		bs.write_u8(1);
		this.SendCommand(this.getCommandID("c_draw"), bs, true);
	}
}
