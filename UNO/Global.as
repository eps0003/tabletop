#include "Stack.as"
#include "Hand.as"

void onInit(CRules@ this)
{
	this.addCommandID("s_sync");
	this.addCommandID("c_draw");
	this.addCommandID("c_discard");
	this.addCommandID("c_shuffle_draw_pile");
	this.addCommandID("c_organise_hand");
	this.addCommandID("c_reset");
	this.addCommandID("c_deal");
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	Stack@ drawPile;
	Stack@ discardPile;

	if (!this.get("draw_pile", @drawPile) || !this.get("discard_pile", @discardPile))
	{
		return;
	}

	if (cmd == this.getCommandID("c_draw"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		CPlayer@ player = getPlayerByNetworkId(id);
		if (player is null) return;

		Hand@ hand;
		if (!player.get("hand", @hand)) return;

		Card@ card = drawPile.popCard();
		hand.PushCard(card);
	}
	else if (cmd == this.getCommandID("c_discard"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		CPlayer@ player = getPlayerByNetworkId(id);
		if (player is null) return;

		Hand@ hand;
		if (!player.get("hand", @hand)) return;

		uint index;
		if (!params.saferead_u16(index)) return;

		// Card@ card = hand.takeCard(index);
		// discardPile.PushCard(card);
		hand.cards[index].Flip();
	}
	else if (cmd == this.getCommandID("c_shuffle_draw_pile"))
	{
		drawPile.Shuffle();
	}
}
