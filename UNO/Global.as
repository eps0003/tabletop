#include "Stack.as"
#include "Hand.as"
#include "Grab.as"
#include "StackManager.as"
#include "HandManager.as"

Random rand(Time());

void onInit(CRules@ this)
{
	this.addCommandID("s_sync_all");
	this.addCommandID("s_sync_hand");
	this.addCommandID("c_draw");
	this.addCommandID("c_discard");
	this.addCommandID("c_shuffle_stack");
	this.addCommandID("s_shuffle_stack");
	this.addCommandID("c_restock_draw_pile");
	this.addCommandID("c_organise_hand");
	this.addCommandID("c_reset");
	this.addCommandID("c_deal");
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	Stack@ drawPile = Stack::getStack("draw");
	Stack@ discardPile = Stack::getStack("discard");

	if (drawPile is null || discardPile is null) return;

	if (cmd == this.getCommandID("c_draw"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		CPlayer@ player = getPlayerByNetworkId(id);
		if (player is null) return;

		Hand@ hand = Hand::getHand(player);
		if (hand is null) return;

		u8 count;
		if (!params.saferead_u8(count)) return;

		for (uint i = 0; i < count; i++)
		{
			Card@ card = drawPile.popCard();
			if (card is null) return;

			hand.PushCard(card);
			card.Flip();
		}

		if (isClient())
		{
			Sound::Play("cardSlide" + (XORRandom(3) + 1) + ".ogg");
		}
	}
	else if (cmd == this.getCommandID("c_discard"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		CPlayer@ player = getPlayerByNetworkId(id);
		if (player is null) return;

		Hand@ hand = Hand::getHand(player);
		if (hand is null) return;

		uint index;
		if (!params.saferead_u16(index)) return;

		Card@ card = hand.takeCard(index);
		card.targetRotation = rand.NextFloat() * 20 - 10;
		discardPile.PushCard(card);

		if (isClient())
		{
			Sound::Play("cardPlace2.ogg");
		}
	}
	else if (cmd == this.getCommandID("c_restock_draw_pile"))
	{
		if (discardPile.cards.size() < 2) return;

		//grab the top card on the discard pile
		Card@ topCard = discardPile.popCard();

		//add all cards in the discard pile to the draw pile
		for (uint i = 0; i < discardPile.cards.size(); i++)
		{
			Card@ card = discardPile.cards[i];
			card.flipped = false;
			card.targetRotation = 0;
			drawPile.PushCard(card);
		}

		//shuffle the draw pile
		drawPile.Shuffle();

		//clear the cards from the discard pile and add back the top card
		discardPile.cards.clear();
		discardPile.PushCard(topCard);

		if (isClient())
		{
			Sound::Play("cardSlide" + (XORRandom(3) + 1) + ".ogg");
		}
	}
	else if (cmd == this.getCommandID("c_organise_hand"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		CPlayer@ player = getPlayerByNetworkId(id);
		if (player is null || player.isMyPlayer()) return;

		u16 oldIndex;
		if (!params.saferead_u16(oldIndex)) return;

		u16 newIndex;
		if (!params.saferead_u16(newIndex)) return;

		Hand@ hand = Hand::getHand(player);
		if (hand is null) return;

		Card@ card = hand.takeCard(oldIndex);
		hand.InsertCard(newIndex, card);
	}
}
