#include "Stack.as"
#include "Hand.as"
#include "Grab.as"
#include "Utilities.as"
#include "StackManager.as"
#include "HandManager.as"
#include "TurnManager.as"

#define CLIENT_ONLY

Random rand(Time());

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
	GUI::LoadFont("name", "GUI/Fonts/AveriaSerif-Bold.ttf", 20, true);
	onRestart(this);
}

void onRestart(CRules@ this)
{
	SetReady(false);
	Stack::Init();
	Hand::Init();
}

void onTick(CRules@ this)
{
	if (!isReady()) return;

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();
	Vec2f screenDim = getDriver().getScreenDimensions();

	Hand@ hand = Hand::getHand(getLocalPlayer());
	bool myTurn = Turn::isMyTurn();

	ResetKeybind(this);
	ShufflePiles(this, mousePos);

	if (myTurn)
	{
		EndTurnKeybind(this);
		DealCardsUsingNumberKeys(this);
	}

	if (Grab::isGrabbing())
	{
		Card@ grabCard = Grab::getGrabbed();

		if (Grab::getGrabbedPosition().y > screenDim.y - smallestScreenDim() / 4.0f)
		{
			OrganiseHeldCards(this, hand);
			Hand::Update();
		}
		else
		{
			Grab::Update();
		}

		if (!controls.isKeyPressed(controls.getActionKeyKey(AK_ACTION1)))
		{
			if (myTurn)
			{
				float len;
				Stack@ stack = Stack::getNearestStack(Grab::getGrabbedPosition(), len);
				if (stack !is null && len <= smallestScreenDim() / 10.0f)
				{
					DiscardHeldCard(this, hand, grabCard, stack);
				}
			}

			Grab::Drop();
		}
	}
	else
	{
		if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION1)))
		{
			if (myTurn)
			{
				DrawCards(this, mousePos, 1);
			}

			GrabCardInHand(hand, mousePos);
		}

		Hand::Update();
	}

	if (controls.isKeyJustPressed(KEY_KEY_F))
	{
		FlipCardInHand(this, hand, mousePos);
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	Hand::RemoveHand(player);
}

void Render(int id)
{
	DrawBackground();

	if (!isReady()) return;

	Render::SetAlphaBlend(true);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();
	Render::SetTransformScreenspace();

	Stack::Render();
	Hand::Render();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("s_sync_all"))
	{
		Stack::Deserialize(params);
		Hand::Deserialize(params);
		SetReady(true);
	}
	else if (cmd == this.getCommandID("s_sync_hand"))
	{
		Hand::AddHand(Hand(params));
	}
	else if (cmd == this.getCommandID("s_shuffle_stack"))
	{
		string name = params.read_string();
		uint seed = params.read_u32();

		Stack@ stack = Stack::getStack(name);
		if (stack is null) return;

		stack.Shuffle(seed);

		Sound::Play("cardSlide" + (XORRandom(3) + 1) + ".ogg");
	}
}

void DealCardsUsingNumberKeys(CRules@ this)
{
	CControls@ controls = getControls();
	Vec2f mousePos = getControls().getMouseScreenPos();

	for (uint key = KEY_KEY_1; key <= KEY_KEY_9; key++)
	{
		if (!controls.isKeyJustPressed(key)) continue;

		DrawCards(this, mousePos, key - KEY_KEY_0);
	}
}

void ShufflePiles(CRules@ this, Vec2f mousePos)
{
	CControls@ controls = getControls();
	if (!controls.isKeyJustPressed(KEY_KEY_S)) return;

	Stack@[] stacks = Stack::getStacks();
	for (uint i = 0; i < stacks.size(); i++)
	{
		Stack@ stack = stacks[i];

		Card@ topCard = stack.getTopCard();
		if (topCard is null || !topCard.contains(mousePos)) continue;

		CBitStream bs;
		bs.write_string(stack.name);
		this.SendCommand(this.getCommandID("c_shuffle_stack"), bs, true);
	}

	// Card@ topDiscardCard = Stack::getStack("discard").getTopCard();
	// if (topDiscardCard !is null && topDiscardCard.contains(mousePos))
	// {
	// 	CBitStream bs;
	// 	this.SendCommand(this.getCommandID("c_restock_draw_pile"), bs, true);
	// }
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

void EndTurnKeybind(CRules@ this)
{
	CControls@ controls = getControls();
	if (controls.isKeyJustPressed(KEY_SPACE))
	{
		CBitStream bs;
		this.SendCommand(this.getCommandID("c_end_turn"), bs, false);
	}
}

void DrawBackground()
{
	Vec2f screenDim = getDriver().getScreenDimensions();

	GUI::DrawRectangle(Vec2f(0, 0), screenDim, SColor(255, 36, 115, 69));

	// GUI::DrawIcon("woodFloor.png", Vec2f_zero, 0.5f);
	// GUI::DrawIcon("woodFloor.png", Vec2f(1000, 0), 0.5f);
	// GUI::DrawIcon("woodFloor.png", Vec2f(1000, 666), 0.5f);
	// GUI::DrawIcon("woodFloor.png", Vec2f(0, 666), 0.5f);

	// GUI::DrawIcon("table.png", screenDim / 2.0f - Vec2f(500, 500), 0.5f);
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

	int index = -1;

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

	if (index == -1) return;

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

void DiscardHeldCard(CRules@ this, Hand@ hand, Card@ card, Stack@ stack)
{
	for (int i = 0; i < hand.cards.size(); i++)
	{
		Card@ card2 = hand.cards[i];
		if (card2 !is card) continue;

		@card = hand.takeCard(i);
		card.targetRotation = rand.NextFloat() * 20 - 10;
		stack.PushCard(card);
		Sound::Play("cardPlace2.ogg");

		CBitStream bs;
		bs.write_u16(getLocalPlayer().getNetworkID());
		bs.write_u16(i);
		bs.write_string(stack.name);
		this.SendCommand(this.getCommandID("c_discard"), bs, true);

		break;
	}
}

void DrawCards(CRules@ this, Vec2f mousePos, uint count)
{
	Stack@[] stacks = Stack::getStacks();
	for (uint i = 0; i < stacks.size(); i++)
	{
		Stack@ stack = stacks[i];

		Card@ topCard = stack.getTopCard();
		if (topCard is null || !topCard.contains(mousePos)) continue;

		CBitStream bs;
		bs.write_u16(getLocalPlayer().getNetworkID());
		bs.write_string(stack.name);
		bs.write_u8(count);
		this.SendCommand(this.getCommandID("c_draw"), bs, true);
	}
}

void FlipCardInHand(CRules@ this, Hand@ hand, Vec2f mousePos)
{
	for (int i = hand.cards.size() - 1; i >= 0; i--)
	{
		Card@ card = hand.cards[i];
		if (!card.contains(mousePos)) continue;
		if (Grab::isGrabbing() && !Grab::isGrabbing(card)) continue;

		card.Flip();

		CBitStream bs;
		bs.write_u16(hand.player.getNetworkID());
		bs.write_u16(i);
		this.SendCommand(this.getCommandID("c_flip_card"), bs, true);

		break;
	}
}
