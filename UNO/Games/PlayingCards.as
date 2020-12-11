#include "Stack.as"
#include "StackManager.as"

#define SERVER_ONLY

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	Vec2f screenCenter = getDriver().getScreenCenterPos();

	Stack@ drawPile = Stack(screenCenter - Vec2f(100, 0));
	Stack@ discardPile = Stack(screenCenter + Vec2f(100, 0));

	for (uint i = 0; i < 52; i++)
	{
		drawPile.PushCard(Card(i, drawPile.position));
	}

	drawPile.Shuffle();

	Card@ card = drawPile.popCard();
	card.Flip();
	discardPile.PushCard(card);

	Stack::AddStack("draw", @drawPile);
	Stack::AddStack("discard", @discardPile);
}
