#include "Stack.as"
#include "Hand.as"

#define CLIENT_ONLY

Stack@ drawPile;
Stack@ discardPile;
Hand@ hand;

void onInit(CRules@ this)
{
	Vec2f screenCenter = getDriver().getScreenCenterPos();

	@drawPile = Stack(screenCenter - Vec2f(100, 0));
	@discardPile = Stack(screenCenter + Vec2f(100, 0));
	@hand = Hand(getLocalPlayer());

	for (uint i = 0; i < 108; i++)
	{
		drawPile.PushCard(Card(drawPile.position));
	}
}

void onTick(CRules@ this)
{
	if (getLocalPlayer() is null) return;

	CControls@ controls = getControls();

	if (controls.isKeyJustPressed(KEY_LBUTTON))
	{
		Card@ card = drawPile.popCard();
		hand.PushCard(card);
	}

	if (controls.isKeyJustPressed(KEY_RBUTTON))
	{
		Card@ card = hand.takeCard(0);
		discardPile.PushCard(card);
	}

	if (controls.isKeyJustPressed(KEY_KEY_S))
	{
		drawPile.Shuffle();
	}
}

void onRender(CRules@ this)
{
	drawPile.Render();
	discardPile.Render();
	hand.Render();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{

}
