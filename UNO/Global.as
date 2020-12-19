#include "Stack.as"
#include "Hand.as"
#include "Grab.as"
#include "StackManager.as"
#include "HandManager.as"
#include "DeckManager.as"

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
	this.addCommandID("c_flip_card");

	Deck::AddDeck(Deck("cards", "playingCards.png", Vec2f(140, 190), 53));
	Deck::AddDeck(Deck("uno", "uno.png", Vec2f(164, 256), 52));
	Deck::AddDeck(Deck("exploding_kittens", "explodingKittens.png", Vec2f(409, 585), 52));
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

		string name;
		if (!params.saferead_string(name)) return;

		Stack@ stack = Stack::getStack(name);
		if (stack is null) return;

		Hand@ hand = Hand::getHand(player);
		if (hand is null) return;

		u8 count;
		if (!params.saferead_u8(count)) return;

		for (uint i = 0; i < count; i++)
		{
			Card@ card = stack.popCard();
			if (card is null) return;

			hand.PushCard(card);
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

		u16 index;
		if (!params.saferead_u16(index)) return;

		Card@ card = hand.takeCard(index);
		if (card is null) return;

		string stackName;
		if (!params.saferead_string(stackName)) return;

		Stack@ stack = Stack::getStack(stackName);
		if (stack is null) return;

		card.targetRotation = rand.NextFloat() * 20 - 10;
		stack.PushCard(card);

		if (isClient())
		{
			Sound::Play("cardPlace2.ogg");

			if (Grab::isGrabbing(card))
			{
				Grab::Drop();
			}
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
	else if (cmd == this.getCommandID("c_flip_card"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		CPlayer@ player = getPlayerByNetworkId(id);
		if (player is null || player.isMyPlayer()) return;

		u16 index;
		if (!params.saferead_u16(index)) return;

		Hand@ hand = Hand::getHand(player);
		if (hand is null) return;

		Card@ card = hand.getCard(index);
		if (card is null) return;

		card.Flip();
	}
}
