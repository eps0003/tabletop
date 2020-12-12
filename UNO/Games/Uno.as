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

	Stack@ drawPile = Stack("draw", screenCenter - Vec2f(100, 0));
	Stack@ discardPile = Stack("discard", screenCenter + Vec2f(100, 0));

	Deck@ deck = Deck::getDeck("uno");

	for (uint y = 0; y < 52; y += 13)
	{
		//1x zero
		drawPile.PushCard(Card(deck, y + 9, drawPile.position));

		for (uint x = 0; x < 9; x++)
		{
			for (uint i = 0; i < 2; i++)
			{
				//2x 1-9
				drawPile.PushCard(Card(deck, y + x, drawPile.position));
			}
		}

		for (uint x = 10; x < 13; x++)
		{
			for (uint i = 0; i < 2; i++)
			{
				//2x draw2 + skip + reverse
				drawPile.PushCard(Card(deck, y + x, drawPile.position));
			}
		}
	}

	for (uint i = 0; i < 4; i++)
	{
		//4x wild + draw4
		drawPile.PushCard(Card(deck, 53, drawPile.position));
		drawPile.PushCard(Card(deck, 54, drawPile.position));
	}

	drawPile.Shuffle();

	Card@ card = drawPile.popCard();
	card.Flip();
	discardPile.PushCard(card);

	Stack::AddStack(drawPile);
	Stack::AddStack(discardPile);
}
