#include "Card.as"

#define CLIENT_ONLY

Card@ card;

void onInit(CRules@ this)
{
	@card = Card(Vec2f(200, 200));
}

void onTick(CRules@ this)
{
	if (getLocalPlayer() is null) return;

	CControls@ controls = getControls();
	if (controls.isKeyPressed(KEY_LBUTTON))
	{
		card.targetPosition = controls.getMouseScreenPos();
	}
}

void onRender(CRules@ this)
{
	card.Render();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{

}
