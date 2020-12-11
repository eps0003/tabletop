#include "Stack.as"
#include "Hand.as"
#include "Utilities.as"

#define CLIENT_ONLY

void onTick(CRules@ this)
{
	if (!isReady()) return;

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();
	Hand@ hand = getHand(getLocalPlayer());

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

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("s_sync_hand"))
	{
		Hand@ hand = Hand(params);
		hand.player.set("hand", @hand);
	}
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
	Stack@ drawPile;
	if (!this.get("draw_pile", @drawPile)) return;

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
