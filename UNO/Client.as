#include "Stack.as"

#define CLIENT_ONLY

Stack@ stack;

void onInit(CRules@ this)
{
	@stack = Stack(Vec2f(400, 400));
	stack.PushCard(Card(stack.position));
}

void onTick(CRules@ this)
{
	if (getLocalPlayer() is null) return;

	// CControls@ controls = getControls();
	// if (controls.isKeyPressed(KEY_LBUTTON))
	// {
	// 	card.targetPosition = controls.getMouseScreenPos();
	// }
}

void onRender(CRules@ this)
{
	stack.Render();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{

}
