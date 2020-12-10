#include "Card.as"

shared void Grab(Card@ card)
{
	CRules@ rules = getRules();

	rules.set("grab_card", @card);

	Vec2f mousePos = getControls().getMouseScreenPos();
	rules.set_Vec2f("grab_offset", mousePos - card.position);
}

shared void Drop()
{
	getRules().set("grab_card", null);
}

shared Card@ getGrabbed()
{
	CRules@ rules = getRules();

	Card@ grabCard;
	rules.get("grab_card", @grabCard);
	return grabCard;
}

shared bool isGrabbing(Card@ card)
{
	CRules@ rules = getRules();

	Card@ grabCard;
	return rules.get("grab_card", @grabCard) && grabCard is card;
}


shared bool isGrabbing()
{
	CRules@ rules = getRules();

	Card@ grabCard;
	return rules.get("grab_card", @grabCard);
}
